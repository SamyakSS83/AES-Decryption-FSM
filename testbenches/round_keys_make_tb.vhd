library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity round_keys_make_tb is
end round_keys_make_tb;

architecture Behavioral of round_keys_make_tb is

    -- Signal declarations to connect to the DUT (Device Under Test)
    signal clk     : std_logic := '0';
    signal ena     : std_logic := '0';
    signal i       : integer range 0 to 9 := 0;
    signal dout    : std_logic_vector(127 downto 0);

    -- Instance of the DUT
    component round_keys_make
        Port (
            clk     : in  std_logic;
            ena     : in  std_logic;
            i       : in  integer range 0 to 9;
            dout    : out std_logic_vector(127 downto 0)
        );
    end component;

begin
    -- Instantiate the DUT
    DUT: round_keys_make
        port map (
            clk  => clk,
            ena  => ena,
            i    => i,
            dout => dout
        );

    -- Clock generation process
    clk_process : process
    begin
        clk <= '0';
        wait for 10 ns;
        clk <= '1';
        wait for 10 ns;
    end process;

    -- Test stimulus process
    stimulus_process: process
    begin
        -- Enable the ROM and assign test values to 'i'
        ena <= '1';

        -- Test each block index (0 to 9) and observe output
        for idx in 0 to 9 loop
            i <= idx;
            wait for 20 ns;  -- Wait for one clock cycle
--            report "Testing with i = " & integer'image(idx) & " -> dout = " & std_logic_vector'image(dout);
        end loop;

        -- Disable the enable signal
        ena <= '0';
        wait for 20 ns;
        
        -- End the simulation
--        report "Test completed.";
        wait;
    end process;

end Behavioral;
