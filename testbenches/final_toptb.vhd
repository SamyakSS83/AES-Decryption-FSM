library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity final_top_tb is
end final_top_tb;

architecture Behavioral of final_top_tb is
    -- Component Declaration
    component final_top
        Port (
            clk          : in  std_logic;
            rst          : in  std_logic;
            input_ready  : out std_logic;
            output_ready : out std_logic;
            output_array : out std_logic_vector(127 downto 0)
        );
    end component;

    -- Signal Declarations
    signal clk          : std_logic := '0';
    signal rst          : std_logic := '0';
    signal input_ready  : std_logic;
    signal output_ready : std_logic;
    signal output_array : std_logic_vector(127 downto 0);

    -- Clock period definition
    constant clk_period : time := 10 ns;

    -- Simulation signals
    signal sim_done : boolean := false;

begin
    -- Instantiate the Unit Under Test (UUT)
    uut: final_top 
        port map (
            clk          => clk,
            rst          => rst,
            input_ready  => input_ready,
            output_ready => output_ready,
            output_array => output_array
        );

    -- Clock process
    clk_process: process
    begin
        while not sim_done loop
            clk <= '0';
            wait for clk_period/2;
            clk <= '1';
            wait for clk_period/2;
        end loop;
        wait;
    end process;

    -- Stimulus process
    stim_proc: process
    begin
        -- Hold reset state for 100 ns
        rst <= '1';
        wait for 100 ns;
        rst <= '0';

        -- Wait for initial reading to start
        wait for clk_period*5;

        -- Wait for input_ready signal
        wait until input_ready = '1';
        wait for clk_period;
        
        -- Wait for processing to complete
        wait until output_ready = '1';
        
        -- Check if output is not all zeros (basic check)
--        assert output_array /= (output_array'range => '0')
--            report "Output array is all zeros - possible error"
--            severity warning;
            
        -- Print output for verification
--        report "Output Array Value: 0x" & to_hstring(output_array);
        
        -- Add some additional wait time to observe steady state
        wait for clk_period*20;
        
        -- End simulation
        sim_done <= true;
        wait for clk_period*2;
        
        report "Simulation Complete";
        wait;
    end process;

    -- Monitor process to track state changes
    monitor_proc: process
    begin
        wait until rising_edge(clk);
        if input_ready = '1' then
            report "Input Ready asserted";
        end if;
        if output_ready = '1' then
            report "Output Ready asserted";
        end if;
    end process;

end Behavioral;