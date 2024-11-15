library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_add_round_keys is
--  This is an empty entity as it's only used for simulation
end tb_add_round_keys;

architecture Behavioral of tb_add_round_keys is

    -- Component Declaration for the Unit Under Test (UUT)
    component add_round_keys
        Port ( 
               rst        : in  std_logic;
               clk        : in  std_logic;
               state_in   : in std_logic_vector(127 downto 0);
               i          : in  integer range 0 to 9;
               state_out  : out std_logic_vector(127 downto 0);
               done       : out std_logic
             );
    end component;
    
    -- Signals to connect to UUT
    signal rst       : std_logic := '1';
    signal clk       : std_logic := '0';
    signal state_in  : std_logic_vector(127 downto 0);
    signal i         : integer range 0 to 9 := 0;
    signal state_out : std_logic_vector(127 downto 0);
    signal done      : std_logic;
    
    -- Clock period definition
    constant clk_period : time := 10 ns;

begin


    -- Instantiate the Unit Under Test (UUT)
    uut: add_round_keys
        Port map (
        
            rst        => rst,
            clk        => clk,
            state_in  => state_in,
            i          => i,
            state_out  => state_out,
            done       => done
        );

    -- Clock process definitions
    clk_process :process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;
    
    -- Stimulus process
    stim_proc: process
    begin
        -- Initialize Inputs
        rst <= '0';  -- De-assert reset after 20 ns
        
        -- Test Round 0
       
        state_in <= x"00000000000000000000000000000000";
        i <= 0;   
        
             
             
        wait until done = '1'; -- Wait enough time for operation to complete
--        assert done = '1' report "Done signal not asserted for round 0" severity error;
--        report "Round 0 complete. State_out: " & to_hstring(state_out);
        wait for 20 ns;
        -- Test Round 5
        rst <= '1';  -- Assert reset
        wait for 20 ns;
        rst <= '0';  -- De-assert reset
        i <= 5;
        
         state_in <= x"00000000000000000000000000000000";
--        wait for 500 ns;
----        assert done = '1' report "Done signal not asserted for round 5" severity error;
----        report "Round 5 complete. State_out: " & to_hstring(state_out);
        
--        -- Test Round 9
--        rst <= '1';  -- Assert reset
--        wait for 20 ns;
--        rst <= '0';  -- De-assert reset
--        i <= 9;
--        wait for 500 ns;
----        assert done = '1' report "Done signal not asserted for round 9" severity error;
--        report "Round 9 complete. State_out: " & to_hstring(state_out);
        
        -- End simulation
        wait;
    end process;

end Behavioral;