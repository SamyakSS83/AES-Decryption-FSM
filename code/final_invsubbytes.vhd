library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity integrated_InvSubBytes is
    Port ( 
           clk       : in  std_logic;
           rst       : in  std_logic;
           state_in  : in  std_logic_vector(127 downto 0);
           state_out : out std_logic_vector(127 downto 0);
           done      : out std_logic
         );
end integrated_InvSubBytes;

architecture Behavioral of integrated_InvSubBytes is
    -- Component declaration for the ROM
    component inv_sbox
        Port (
            clka  : in  std_logic;
            ena   : in  std_logic;
            addra : in  std_logic_vector(7 downto 0);
            douta : out std_logic_vector(7 downto 0)
        );
    end component;

    -- Types and signals for byte processing
    type byte_array is array (0 to 15) of std_logic_vector(7 downto 0);
    signal bytes_in      : byte_array;
    signal bytes_out     : byte_array;
    signal mapped_addr   : byte_array;
    
    -- Control signals
    signal ena          : std_logic := '1';
    signal process_done : std_logic := '0';
    signal cycle_count  : integer range 0 to 15 := 0;
    signal delay_count1 : integer range 0 to 10 := 0;
    signal delay_count2 : integer range 0 to 10 := 0;
    signal state_reg    : std_logic_vector(127 downto 0);
    
    -- State machine type and signal
    type state_type is (IDLE, PROCESSING, DELAY1, DELAY2, COMPLETE);
    signal current_state : state_type := IDLE;

begin
    -- Split input into bytes process
    process(state_in)
    begin
        for i in 0 to 15 loop
            bytes_in(i) <= state_in(127-i*8 downto 120-i*8);
        end loop;
    end process;

    -- Address mapping for each byte
    gen_addr_map: for i in 0 to 15 generate
        mapped_addr(i) <= bytes_in(i)(3 downto 0) & bytes_in(i)(7 downto 4);
    end generate;

    -- Generate 16 instances of inv_sbox
    gen_sbox: for i in 0 to 15 generate
        sbox_inst: inv_sbox
            port map (
                clka  => clk,
                ena   => ena,
                addra => mapped_addr(i),
                douta => bytes_out(i)
            );
    end generate;

    -- Main control process
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                current_state <= IDLE;
                cycle_count <= 0;
                delay_count1 <= 0;
                delay_count2 <= 0;
                process_done <= '0';
                state_reg <= (others => '0');
            else
                case current_state is
                    when IDLE =>
                        if ena = '1' then
                            current_state <= PROCESSING;
                            cycle_count <= 0;
                        end if;

                    when PROCESSING =>
                        if cycle_count < 15 then
                            cycle_count <= cycle_count + 1;
                        else
                            -- Combine output bytes into state_reg
                            for i in 0 to 15 loop
                                state_reg(127-i*8 downto 120-i*8) <= bytes_out(i);
                            end loop;
                            current_state <= DELAY1;
                            delay_count1 <= 0;
                        end if;

                    when DELAY1 =>
                        if delay_count1 < 10 then
                            delay_count1 <= delay_count1 + 1;
                        else
                            current_state <= DELAY2;
                            delay_count2 <= 0;
                        end if;

                    when DELAY2 =>
                        if delay_count2 < 10 then
                            delay_count2 <= delay_count2 + 1;
                        else
                            current_state <= COMPLETE;
                            process_done <= '1';
                        end if;

                    when COMPLETE =>
                        if ena = '0' then
                            current_state <= IDLE;
                            process_done <= '0';
                        end if;
                end case;
            end if;
        end if;
    end process;

    -- Output assignments
    state_out <= state_reg when current_state = COMPLETE else (others => '0');
    done <= process_done;

end Behavioral;