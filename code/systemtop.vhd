library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity SystemTop is
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
end SystemTop;

architecture Behavioral of SystemTop is
    component final_top is
        Port (
            clk          : in  STD_LOGIC;
            rst          : in  STD_LOGIC;
            input_ready  : out STD_LOGIC;
            output_ready : out STD_LOGIC;
            output_array : out STD_LOGIC_VECTOR(255 downto 0)
        );
    end component;

    component ScrollingDisplay is
--        Generic (
--            DATA_WIDTH : integer := 256
--        );
        Port (
            clk       : in  STD_LOGIC;
            data_in   : in  STD_LOGIC_VECTOR(255 downto 0);
            seg_a     : out STD_LOGIC;
            seg_b     : out STD_LOGIC;
            seg_c     : out STD_LOGIC;
            seg_d     : out STD_LOGIC;
            seg_e     : out STD_LOGIC;
            seg_f     : out STD_LOGIC;
            seg_g     : out STD_LOGIC;
            an        : out STD_LOGIC_VECTOR(3 downto 0)
        );
    end component;

    -- Signals to connect final_top to ScrollingDisplay
    signal input_ready_top  : STD_LOGIC;
    signal output_ready_top : STD_LOGIC;
    signal output_array_top : STD_LOGIC_VECTOR(255 downto 0);
    signal maybe_done       : std_logic := '0';
    signal data_in_reg      : STD_LOGIC_VECTOR(0 to 255) := (others => '0');
    
    -- New signals for delay counting
    signal delay_counter    : unsigned(5 downto 0) := "000000";  -- 3 bits for counting up to 5
    signal more_delay       : unsigned(4 downto 0) := "00000";
    signal counting_active  : std_logic := '0';
    signal data_temp       : STD_LOGIC_VECTOR(255 downto 0); -- Temporary storage for output_array_top

begin
    final_top_inst : final_top
        port map (
            clk          => clk,
            rst          => rst,
            input_ready  => input_ready_top,
            output_ready => output_ready_top,
            output_array => output_array_top
        );

    -- Modified process with 5-cycle delay
    data_latching_process : process(clk, rst)
    begin
        if rst = '1' then
            data_in_reg <= (others => '0');
            delay_counter <= "000000";
            counting_active <= '0';
            maybe_done <= '0';
            data_temp <= (others => '0');
        elsif rising_edge(clk) then
            if output_ready_top = '1' and counting_active = '0' then
                -- Start counting and store the data
                if more_delay = "11111" then  -- Count reached 5
                        counting_active <= '1';
                        data_temp <= output_array_top;
                        more_delay <= "00000";
                    
                else
                    more_delay <= more_delay + 1;
                end if;
                
            elsif counting_active = '1' then
                if delay_counter = "111111" then  -- Count reached 5
                    data_in_reg <= data_temp;
                    maybe_done <= '1';
                    counting_active <= '0';
                    delay_counter <= "000000";
                else
                    delay_counter <= delay_counter + 1;
                end if;
            end if;
        end if;
    end process;
    

    done <= maybe_done;

    scrolling_display_inst : ScrollingDisplay
--        generic map (
--            DATA_WIDTH => 256
--        )
        port map (
            clk       => clk,
            data_in   => data_in_reg,
            seg_a     => seg_a,
            seg_b     => seg_b,
            seg_c     => seg_c,
            seg_d     => seg_d,
            seg_e     => seg_e,
            seg_f     => seg_f,
            seg_g     => seg_g,
            an        => an
        );
end Behavioral;