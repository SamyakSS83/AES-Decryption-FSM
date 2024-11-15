library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity SystemTop_tb is
end SystemTop_tb;


architecture Behavioral of SystemTop_tb is
    -- Component Declaration
    
    component SystemTop
        Port (
            clk       : in  STD_LOGIC;
            rst       : in  STD_LOGIC;
            seg_a     : out STD_LOGIC;
            seg_b     : out STD_LOGIC;
            seg_c     : out STD_LOGIC;
            seg_d     : out STD_LOGIC;
            seg_e     : out STD_LOGIC;
            seg_f     : out STD_LOGIC;
            seg_g     : out STD_LOGIC;
            an        : out STD_LOGIC_VECTOR(3 downto 0);
            done      : out std_logic
        );
    end component;

    -- Signal declarations
    signal clk        : std_logic := '0';
    signal rst        : std_logic := '1';
    signal seg_a      : std_logic;
    signal seg_b      : std_logic;
    signal seg_c      : std_logic;
    signal seg_d      : std_logic;
    signal seg_e      : std_logic;
    signal seg_f      : std_logic;
    signal seg_g      : std_logic;
    signal an         : std_logic_vector(3 downto 0);
    signal done       : std_logic;

    -- Clock period definition
    constant clk_period : time := 10 ns;

begin
    -- Instantiate the Unit Under Test (UUT)
    uut: SystemTop port map (
        clk    => clk,
        rst    => rst,
        seg_a  => seg_a,
        seg_b  => seg_b,
        seg_c  => seg_c,
        seg_d  => seg_d,
        seg_e  => seg_e,
        seg_f  => seg_f,
        seg_g  => seg_g,
        an     => an,
        done   => done
    );

    -- Clock process
    clk_process: process
    begin
        while now < 10000000 ns loop  -- Run simulation for 1000 ns
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
        
        -- Release reset
        
        rst <= '0';
--        wait for 800 ns;  -- Let it run for a while
        
        -- End simulation
        wait;
    end process;

end Behavioral;