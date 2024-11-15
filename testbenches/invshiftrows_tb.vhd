library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Testbench for control_InvShiftRows
entity tb_control_InvShiftRows is
end tb_control_InvShiftRows;

architecture Behavioral of tb_control_InvShiftRows is
    -- Component declaration for the unit under test (UUT)
    component control_InvShiftRows is
        Port (
            clk          : in  std_logic;
            rst          : in  std_logic;
            input_data   : in  std_logic_vector(127 downto 0);
            output_data  : out std_logic_vector(127 downto 0);
            done         : out std_logic
        );
    end component;

    -- Signals to connect to UUT
    signal clk          : std_logic := '0';
    signal rst          : std_logic := '0';
    signal input_data   : std_logic_vector(127 downto 0) := (others => '0');
    signal output_data  : std_logic_vector(127 downto 0);
    signal done         : std_logic;

    -- Clock period definition
    constant clk_period : time := 10 ns;

begin
    -- Instantiate the Unit Under Test (UUT)
    uut: control_InvShiftRows Port map (
        clk => clk,
        rst => rst,
        input_data => input_data,
        output_data => output_data,
        done => done
    );

    -- Clock generation
    clk_process : process
    begin
        clk <= '0';
        wait for clk_period / 2;
        clk <= '1';
        wait for clk_period / 2;
    end process;

    -- Stimulus process
    stimulus_process : process
    begin
        -- Reset the system
        rst <= '1';
        wait for clk_period;
        rst <= '0';
        
        -- Apply first test vector
        input_data <= x"63fb5b6fa2aa126367636a23d7638282";  -- Example input
--        wait for 50 ns;  -- Wait for the process to complete
        
        -- Check output
        wait until done = '1';
--        report "Test 1 completed. Output: " & std_logic_vector'IMAGE(output_data);
        
        -- Apply second test vector
--        rst <= '1';
--        wait for clk_period;
--        rst <= '0';
--        input_data <= x"ffeeddccbbaa99887766554433221100";  -- Another test input
--        wait for 50 ns;
        
--        -- Check output
--        wait until done = '1';
--        report "Test 2 completed. Output: " & std_logic_vector'IMAGE(output_data);
        
--        -- End simulation
        wait;
    end process;
end Behavioral;
