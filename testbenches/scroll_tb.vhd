library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_ScrollingDisplay is
    -- Testbench has no ports
end tb_ScrollingDisplay;

architecture Behavioral of tb_ScrollingDisplay is
    -- Component Declaration for the Unit Under Test (UUT)
    component ScrollingDisplay
--        Generic (
--            DATA_WIDTH : integer := 256  -- Updated to 256 bits
--        );
        Port (
            clk : in STD_LOGIC; -- Clock signal
            data_in : in STD_LOGIC_VECTOR(127 downto 0); -- Input data of configurable length
            seg_a, seg_b, seg_c, seg_d, seg_e, seg_f, seg_g : out STD_LOGIC; -- 7-segment outputs
            an : out STD_LOGIC_VECTOR(3 downto 0) -- Anode control signals
        );
    end component;

    -- Signals to connect to UUT
    signal clk_tb : STD_LOGIC := '0';
    signal data_in_tb : STD_LOGIC_VECTOR(127 downto 0) := (others => '0'); -- 256-bit input
    signal seg_a_tb, seg_b_tb, seg_c_tb, seg_d_tb, seg_e_tb, seg_f_tb, seg_g_tb : STD_LOGIC;
    signal an_tb : STD_LOGIC_VECTOR(3 downto 0);

    -- Clock period definition
    constant CLK_PERIOD : time := 10 ps;

begin
    -- Instantiate the Unit Under Test (UUT)
    uut: ScrollingDisplay
--        generic map (
--            DATA_WIDTH => 256  -- Set DATA_WIDTH to 256 bits
--        )
        port map (
            clk => clk_tb,
            data_in => data_in_tb,
            seg_a => seg_a_tb,
            seg_b => seg_b_tb,
            seg_c => seg_c_tb,
            seg_d => seg_d_tb,
            seg_e => seg_e_tb,
            seg_f => seg_f_tb,
            seg_g => seg_g_tb,
            an => an_tb
        );

    -- Clock Generation Process
    clk_process : process
    begin
        clk_tb <= '0';
        wait for CLK_PERIOD / 2;
        clk_tb <= '1';
        wait for CLK_PERIOD / 2;
    end process;

    -- Stimulus Process
    stimulus: process
    begin
        
        data_in_tb <= X"30313233343536373839414243444546";
        

        wait for 1000 us; -- Let the simulation run for sufficient time to observe scrolling

        wait; -- End of simulation
    end process;

end Behavioral;