--library IEEE;
--use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.STD_LOGIC_ARITH.ALL;
--use IEEE.STD_LOGIC_UNSIGNED.ALL;

--entity ScrollingDisplay is
--    Port (
--        clk : in STD_LOGIC; -- Clock signal
--        data_in : in STD_LOGIC_VECTOR(127 downto 0); -- 128-bit input (16 ASCII characters)
--        seg_a, seg_b, seg_c, seg_d, seg_e, seg_f, seg_g : out STD_LOGIC; -- 7-segment outputs
--        an : out STD_LOGIC_VECTOR(3 downto 0) -- Anode control signals
--    );
--end ScrollingDisplay;

--architecture Behavioral of ScrollingDisplay is
--    -- Counter for display refresh
--    signal display_counter : integer := 0;
--    signal display_clk : STD_LOGIC := '0';
--    constant DISPLAY_N : integer := 100000; -- Display refresh rate divider
----    signal data_in : STD_LOGIC_VECTOR(127 downto 0);
--    -- Counter for scrolling
--    signal scroll_counter : integer := 0;
--    signal scroll_clk : STD_LOGIC := '0';
--    constant SCROLL_N : integer := 50000000; -- Scroll speed divider (slower than display refresh)

--    -- Signals for character selection
--    signal scroll_position : integer range 0 to 12 := 0; -- Position in the 128-bit string (13 possible positions)
--    signal display_window : STD_LOGIC_VECTOR(31 downto 0); -- Current 32-bit window to display
--    signal selected_ascii : std_logic_vector(7 downto 0);
--    signal mux_select : std_logic_vector(1 downto 0) := "00";

--    -- Seven-segment ASCII display component declaration
--    component SevenSegmentASCII
--        Port (
--            ascii_in : in STD_LOGIC_VECTOR(7 downto 0);
--            seg_a, seg_b, seg_c, seg_d, seg_e, seg_f, seg_g : out STD_LOGIC
--        );
--    end component;

--begin
--    -- Display refresh clock divider
----    data_in <= x"46354333393261314131333339623838";
--    process(clk)
--    begin
--        if rising_edge(clk) then
--            if display_counter = DISPLAY_N - 1 then
--                display_counter <= 0;
--                display_clk <= not display_clk;
--            else
--                display_counter <= display_counter + 1;
--            end if;
--        end if;
--    end process;

--    -- Scrolling clock divider
--    process(clk)
--    begin
--        if rising_edge(clk) then
--            if scroll_counter = SCROLL_N - 1 then
--                scroll_counter <= 0;
--                scroll_clk <= not scroll_clk;
--            else
--                scroll_counter <= scroll_counter + 1;
--            end if;
--        end if;
--    end process;

--    -- Scroll position control
--    process(scroll_clk)
--    begin
--        if rising_edge(scroll_clk) then
--            if scroll_position = 12 then  -- Reset after reaching the end
--                scroll_position <= 0;
--            else
--                scroll_position <= scroll_position + 1;
--            end if;
--        end if;
--    end process;

--    -- Update display window based on scroll position
--    process(scroll_position, data_in)
--        variable start_pos : integer;
--    begin
--        start_pos := 127 - (scroll_position * 8);
--        display_window <= data_in(start_pos downto start_pos - 31);
--    end process;

--    -- Display multiplexing control
--    process(display_clk)
--    begin
--        if rising_edge(display_clk) then
--            mux_select <= mux_select + 1;
--        end if;
--    end process;

--    -- Select ASCII character based on mux_select signal
--    process(mux_select, display_window)
--    begin
--        case mux_select is
--            when "00" => selected_ascii <= display_window(31 downto 24);
--            when "01" => selected_ascii <= display_window(23 downto 16);
--            when "10" => selected_ascii <= display_window(15 downto 8);
--            when "11" => selected_ascii <= display_window(7 downto 0);
--            when others => selected_ascii <= (others => '0');
--        end case;
--    end process;

--    -- Instantiate SevenSegmentASCII
--    ascii_display: SevenSegmentASCII
--        port map (
--            ascii_in => selected_ascii,
--            seg_a => seg_a,
--            seg_b => seg_b,
--            seg_c => seg_c,
--            seg_d => seg_d,
--            seg_e => seg_e,
--            seg_f => seg_f,
--            seg_g => seg_g
--        );

--    -- Control anode signals
--    process(mux_select)
--    begin
--        case mux_select is
--            when "00" => an <= "1110";
--            when "01" => an <= "1101";
--            when "10" => an <= "1011";
--            when "11" => an <= "0111";
--            when others => an <= "1111";
--        end case;
--    end process;

--end Behavioral;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ScrollingDisplay is
--    Generic (
--        DATA_WIDTH : integer  -- Default width, can be any multiple of 128
--    );
    Port (
        clk : in STD_LOGIC; -- Clock signal
        data_in : in STD_LOGIC_VECTOR(255 downto 0); -- Input data of configurable length
        seg_a, seg_b, seg_c, seg_d, seg_e, seg_f, seg_g : out STD_LOGIC; -- 7-segment outputs
        an : out STD_LOGIC_VECTOR(3 downto 0) -- Anode control signals
    );
end ScrollingDisplay;

architecture Behavioral of ScrollingDisplay is
    -- Counter for display refresh
    signal display_counter : integer := 0;
    signal display_clk : STD_LOGIC := '0';
    constant DISPLAY_N : integer := 100000; -- Display refresh rate divider

    -- Counter for scrolling
    signal scroll_counter : integer := 0;
    signal scroll_clk : STD_LOGIC := '0';
    constant SCROLL_N : integer := 50000000; -- Scroll speed divider
--    signal data_in :  STD_LOGIC_VECTOR(255 downto 0) := x"4633623266383033464239423465336633446145336465413731414132436330";
    constant DATA_WIDTH : integer := 256;

    -- Signals for character selection
    signal scroll_position : integer range 0 to ((DATA_WIDTH / 8) - 4) := 0; -- Dynamic scroll position range
    signal display_window : STD_LOGIC_VECTOR(31 downto 0); -- Current 32-bit window to display
    signal selected_ascii : std_logic_vector(7 downto 0);
    signal mux_select : std_logic_vector(1 downto 0) := "00";

    -- Seven-segment ASCII display component declaration
    component SevenSegmentASCII
        Port (
            ascii_in : in STD_LOGIC_VECTOR(7 downto 0);
            seg_a, seg_b, seg_c, seg_d, seg_e, seg_f, seg_g : out STD_LOGIC;
            an : out STD_LOGIC_VECTOR(3 downto 0)
        );
    end component;

begin
    -- Display refresh clock divider
    process(clk)
    begin
        if rising_edge(clk) then
            if display_counter = DISPLAY_N - 1 then
                display_counter <= 0;
                display_clk <= not display_clk;
            else
                display_counter <= display_counter + 1;
            end if;
        end if;
    end process;

    -- Scrolling clock divider
    process(clk)
    begin
        if rising_edge(clk) then
            if scroll_counter = SCROLL_N - 1 then
                scroll_counter <= 0;
                scroll_clk <= not scroll_clk;
            else
                scroll_counter <= scroll_counter + 1;
            end if;
        end if;
    end process;

    -- Scroll position control
    process(scroll_clk)
    begin
        if rising_edge(scroll_clk) then
            if scroll_position = (DATA_WIDTH / 8) - 4 then -- Reset after reaching the end of data
                scroll_position <= 0;
            else
                scroll_position <= scroll_position + 1;
            end if;
        end if;
    end process;

    -- Update display window based on scroll position
    process(scroll_position, data_in)
    begin
        -- Select 32-bit (4-character) window based on scroll position
        display_window <= data_in((DATA_WIDTH - 1) - (scroll_position * 8) downto (DATA_WIDTH - 32) - (scroll_position * 8));
    end process;

    -- Display multiplexing control
    process(display_clk)
    begin
        if rising_edge(display_clk) then
            mux_select <= mux_select + 1;
        end if;
    end process;

    -- Select ASCII character based on mux_select signal
    process(mux_select, display_window)
    begin
        case mux_select is
            when "00" => selected_ascii <= display_window(31 downto 24);
            when "01" => selected_ascii <= display_window(23 downto 16);
            when "10" => selected_ascii <= display_window(15 downto 8);
            when "11" => selected_ascii <= display_window(7 downto 0);
            when others => selected_ascii <= (others => '0');
        end case;
    end process;

    -- Instantiate SevenSegmentASCII
    ascii_display: SevenSegmentASCII
        port map (
            ascii_in => selected_ascii,
            seg_a => seg_a,
            seg_b => seg_b,
            seg_c => seg_c,
            seg_d => seg_d,
            seg_e => seg_e,
            seg_f => seg_f,
            seg_g => seg_g,
            an => open
        );

    -- Control anode signals
    process(mux_select)
    begin
        case mux_select is
            when "00" => an <= "0111";
            when "01" => an <= "1011";
            when "10" => an <= "1101";
            when "11" => an <= "1110";
            when others => an <= "1111";
        end case;
    end process;

end Behavioral;