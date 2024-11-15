library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity final_top is
    Port (
        clk          : in  std_logic;
        rst          : in  std_logic;
        input_ready  : out std_logic;
        output_ready : out std_logic;
        output_array : out std_logic_vector(255 downto 0) -- For N=2 blocks
    );
end final_top;

architecture Behavioral of final_top is
    constant N_BLOCKS : integer := 2;
    
    component input_2561 is
        Port (
            clka  : in  std_logic;
            ena   : in  std_logic;
            addra : in  std_logic_vector(4 downto 0);
            douta : out std_logic_vector(7 downto 0)
        );
    end component;

    component aes_top_decrypt is
        Port (
            clk      : in  std_logic;
            rst      : in  std_logic;
            enable   : in  std_logic;
            input    : in  std_logic_vector(127 downto 0);
            output   : out std_logic_vector(127 downto 0);
            complete : out std_logic
        );
    end component;

    type state_type is (IDLE, READING, READ_WAIT, STORE_BYTE, TRANSPOSE, AES_PROCESS, BLOCK_COMPLETE);
    signal current_state : state_type := IDLE;
    
--    signal output_array : std_logic_vector(127 downto 0);

    signal rom_ena     : std_logic := '1';
    signal rom_addra   : std_logic_vector(4 downto 0) := (others => '0');
    signal rom_douta   : std_logic_vector(7 downto 0);

    signal transposed_data  : std_logic_vector(127 downto 0) := (others => '0');
    signal temp_data       : std_logic_vector(127 downto 0) := (others => '0');
    signal output_data     : std_logic_vector(127 downto 0);
    signal output_array_temp : std_logic_vector(255 downto 0) := (others => '0');
    signal aes_enable      : std_logic := '0';
    signal aes_complete    : std_logic;
    signal input_ready_sig : std_logic := '0';
    signal output_ready_sig: std_logic := '0';
    signal transposed_output_data : std_logic_vector(127 downto 0);

    signal cycle_counter   : integer range 0 to 10 := 0;
    signal byte_counter   : integer range 0 to 15 := 0;
    signal block_counter  : integer range 0 to N_BLOCKS := 0;
    
    signal current_block_base : std_logic_vector(4 downto 0);
    signal internal_rst      : std_logic := '0';
    signal combined_reset    : std_logic;

begin
    combined_reset <= rst or internal_rst;

    rom_inst : input_2561
        port map (
            clka  => clk,
            ena   => rom_ena,
            addra => rom_addra,
            douta => rom_douta
        );

    aes_inst : aes_top_decrypt
        port map (
            clk      => clk,
            rst      => combined_reset,
            enable   => aes_enable,
            input    => transposed_data,
            output   => output_data,
            complete => aes_complete
        );

    current_block_base <= std_logic_vector(to_unsigned(block_counter * 16, 5));

    process(clk, rst)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                current_state <= IDLE;
                rom_addra <= (others => '0');
                temp_data <= (others => '0');
                transposed_data <= (others => '0');
                output_array_temp <= (others => '0');
                cycle_counter <= 0;
                block_counter <= 0;
                byte_counter <= 0;
                input_ready_sig <= '0';
                output_ready_sig <= '0';
                aes_enable <= '0';
                internal_rst <= '0';

            else
                case current_state is
                    when IDLE =>
                        internal_rst <= '0';
                        if block_counter < N_BLOCKS then
                            current_state <= READING;
                            rom_addra <= current_block_base;
                            cycle_counter <= 0;
                        end if;

                    when READING =>
                        if cycle_counter < 9 then
                            cycle_counter <= cycle_counter + 1;
                        else
                            cycle_counter <= 0;
                            current_state <= STORE_BYTE;
                        end if;

                    when STORE_BYTE =>
                        temp_data(127 - byte_counter*8 downto 120 - byte_counter*8) <= rom_douta;
                        if byte_counter < 15 then
                            byte_counter <= byte_counter + 1;
                            rom_addra <= rom_addra + 1;
                            current_state <= READING;
                        else
                            byte_counter <= 0;
                            current_state <= TRANSPOSE;
                        end if;

                    when TRANSPOSE =>
                        for i in 0 to 3 loop
                            for j in 0 to 3 loop
                                transposed_data(127 - (i*32) - (j*8) downto 120 - (i*32) - (j*8)) <= 
                                    temp_data(127 - (j*32) - (i*8) downto 120 - (j*32) - (i*8));
                            end loop;
                        end loop;
                        input_ready_sig <= '1';
                        aes_enable <= '1';
                        current_state <= AES_PROCESS;

                    when AES_PROCESS =>
                        input_ready_sig <= '0';
                        aes_enable <= '0';
                        if aes_complete = '1' then
                            output_array_temp((block_counter + 1) * 128 - 1 downto block_counter * 128) <= 
                                output_data(127 downto 120) &    -- Byte 0
                                output_data(95 downto 88) &      -- Byte 4
                                output_data(63 downto 56) &      -- Byte 8
                                output_data(31 downto 24) &      -- Byte 12
                                output_data(119 downto 112) &    -- Byte 1
                                output_data(87 downto 80) &      -- Byte 5
                                output_data(55 downto 48) &      -- Byte 9
                                output_data(23 downto 16) &      -- Byte 13
                                output_data(111 downto 104) &    -- Byte 2
                                output_data(79 downto 72) &      -- Byte 6
                                output_data(47 downto 40) &      -- Byte 10
                                output_data(15 downto 8) &       -- Byte 14
                                output_data(103 downto 96) &     -- Byte 3
                                output_data(71 downto 64) &      -- Byte 7
                                output_data(39 downto 32) &      -- Byte 11
                                output_data(7 downto 0);         -- Byte 15

                            if block_counter < N_BLOCKS - 1 then
                                block_counter <= block_counter + 1;
                                current_state <= IDLE;
                            else
                                current_state <= BLOCK_COMPLETE;
                            end if;
                        end if;

                    when BLOCK_COMPLETE =>
                        output_ready_sig <= '1';
                        -- Stay in this state until external reset
                    when others =>
                    
                end case;
            end if;
        end if;
    end process;

    input_ready <= input_ready_sig;
    output_ready <= output_ready_sig;
    output_array <= output_array_temp;

end Behavioral;