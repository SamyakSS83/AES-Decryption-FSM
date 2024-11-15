library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity tb_integrated_InvSubBytes is
end tb_integrated_InvSubBytes;

architecture Behavioral of tb_integrated_InvSubBytes is
    -- Component Declaration
    component integrated_InvSubBytes
        Port ( 
            clk       : in  std_logic;
            rst       : in  std_logic;
            state_in  : in  std_logic_vector(127 downto 0);
            state_out : out std_logic_vector(127 downto 0);
            done      : out std_logic
        );
    end component;
    
    -- Signal declarations
    signal clk        : std_logic := '0';
    signal rst        : std_logic := '1';
    signal state_in   : std_logic_vector(127 downto 0);
    signal state_out  : std_logic_vector(127 downto 0);
    signal done       : std_logic;
    
    -- Constants
    constant CLK_PERIOD : time := 10 ns;
    
begin
    -- Instantiate the Unit Under Test (UUT)
    UUT: integrated_InvSubBytes 
        port map (
            clk       => clk,
            rst       => rst,
            state_in  => state_in,
            state_out => state_out,
            done      => done
        );
    
    -- Clock process
    process
    begin
        wait for CLK_PERIOD/2;
        clk <= not clk;
    end process;
    
    -- Stimulus process
    process
    begin
        -- Initialize input with the specified value
        -- 63 F9 5B 6F 63 A2 AA 12 6A 23 67 63 63 82 82 D7
        state_in <= x"63F95B6F63A2AA126A236763638282D7";
        
        
        -- Hold reset for 5 clock cycles
        wait for 5 * CLK_PERIOD;
        rst <= '0';
        
        -- Wait for done signal
        wait until done = '1';
        
        -- Print the output in hexadecimal format
        -- report "Transformation complete!" severity note;
        -- report "Input state:  " & to_hstring(state_in) severity note;
        -- report "Output state: " & to_hstring(state_out) severity note;
        
        -- Wait for some time to observe the output
        wait for 5 * CLK_PERIOD;
        
        -- Test reset again
        rst <= '1';
        wait for 2 * CLK_PERIOD;
        rst <= '0';
        
        -- Wait for some more time
        wait for 10 * CLK_PERIOD;
        
        -- End simulation
        -- report "Simulation completed successfully!" severity note;
        wait;
    end process;
    
   
    
end Behavioral;