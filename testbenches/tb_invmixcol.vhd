library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_control_inverseMixColumns is
end entity tb_control_inverseMixColumns;

architecture test of tb_control_inverseMixColumns is
    -- Component declaration
    component control_inverseMixColumns
        port (
            clk       : in  std_logic;
            rst       : in  std_logic;
            state_in  : in  std_logic_vector(127 downto 0);
            state_out : out std_logic_vector(127 downto 0);
            done      : out std_logic
        );
    end component;

    -- Testbench signals
    signal clk       : std_logic := '0';
    signal rst       : std_logic := '0';
    signal state_in  : std_logic_vector(127 downto 0) := (others => '0');
    signal state_out : std_logic_vector(127 downto 0);
    signal done      : std_logic;

    -- Clock period definition
    constant clk_period : time := 10 ns;

begin
    -- DUT instantiation
    uut: control_inverseMixColumns
        port map (
            clk       => clk,
            rst       => rst,
            state_in  => state_in,
            state_out => state_out,
            done      => done
        );

    -- Clock process definition
    clk_process : process
    begin
        clk <= '0';
        wait for clk_period / 2;
        clk <= '1';
        wait for clk_period / 2;
    end process;

    -- Stimulus process
    stim_proc: process
    begin
        -- Apply reset
        rst <= '1';
        wait for clk_period;
        rst <= '0';

        -- Apply first test vector
        state_in <= x"8B0C68DA4270434E6D3000D7D51F8AEE";
--        state_in <= x"112233445566778899aabbccddeeff00";
         -- Example input state
--        wait for clk_period * 10; -- Wait for computation to complete

        -- Check result and done signal
        wait until done = '1';
--        assert state_out = expected_value_1
--        report "Test failed for input x'1b2e3d4c5a6978776675443322110ffe'" severity error;

        -- Apply second test vector
        wait for 100 ns;
        rst <= '1';
--        wait for clk_period;
--        rst <= '0';
--        state_in <= x"ff2233445566778899aabbccddeeff01"; -- Another test input
----        wait for clk_period * 10; -- Wait for computation to complete

----        -- Check result and done signal
--        wait until done = '1';
--        assert state_out = expected_value_2
--        report "Test failed for input x'ff2233445566778899aabbccddeeff01'" severity error;

        -- Test complete
        wait;
    end process;
end architecture test;
