library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity add_round_keys is
    Port (
        clk       : in  std_logic;
        rst       : in  std_logic;
        i         : in  integer range 0 to 9;
        state_in  : in  std_logic_vector(127 downto 0);
        state_out : out std_logic_vector(127 downto 0);
        done      : out std_logic
    );
end add_round_keys;

architecture Behavioral of add_round_keys is
    -- Component declaration for round_keys_make
    component round_keys_make
        Port (
            clk  : in  std_logic;
            ena  : in  std_logic;
            i    : in  integer range 0 to 9;
            dout : out std_logic_vector(127 downto 0)
        );
    end component;

    -- Internal signals
    signal round_key    : std_logic_vector(127 downto 0);
    
    signal temp    : std_logic_vector(127 downto 0);
    signal enable       : std_logic := '0';
    signal wait_counter : integer range 0 to 9 := 0;
    signal done_reg     : std_logic := '0';
    signal done_wait    : integer range 0 to 150 := 0;
    signal state        : integer range 0 to 4 := 0;  -- Expanded state range to include the new state

begin

    -- Instantiate round_keys_make
    round_keys_inst : round_keys_make
        port map (
            clk  => clk,
            ena  => enable,
            i    => i,
            dout => round_key
        );

    -- Process to control the operation
    process(clk, rst)
    begin
        if rst = '1' then
            -- Reset internal signals
            state <= 0;
            enable <= '0';
            wait_counter <= 0;
            done_wait <= 0;
--            state_out <= (others => '0');
            done_reg <= '0';
        elsif rising_edge(clk) then
            case state is
                when 0 =>  -- Start state
                    enable <= '1';
                    wait_counter <= 0;
                    done_reg <= '0';
                    done_wait <= 0;
                    state <= 1;
                when 1 =>  -- Wait for 5 clock cycles
                    enable <= '1';
                    if wait_counter < 9 then
                        wait_counter <= wait_counter + 1;
                    else
                        state <= 2;
                    end if;
                when 2 =>  -- Perform XOR operation
                    temp <= state_in xor round_key;
                    state <= 3;
                when 3 =>  -- Wait for one clock cycle to ensure state_out is updated
                    state <= 4;
                when 4 =>  -- Set done signal after state_out is updated
                    done_reg <= '1';
                    state <= 4;  -- Remain in done state
                when others =>
                    state <= 0;
            end case;
        end if;
    end process;
    state_out <= temp;

    done <= done_reg;

end Behavioral;