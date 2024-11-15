library ieee;
use ieee.std_logic_1164.all;

entity mux_4x1_vector1 is
    Port (
        d0 : in STD_LOGIC_VECTOR(7 downto 0);
        d1 : in STD_LOGIC_VECTOR(7 downto 0);
        d2 : in STD_LOGIC_VECTOR(7 downto 0);
        d3 : in STD_LOGIC_VECTOR(7 downto 0);
        s0 : in STD_LOGIC; -- Select signal bit 0
        s1 : in STD_LOGIC; -- Select signal bit 1
        o : out STD_LOGIC_VECTOR(7 downto 0) -- 8-bit output
    );
end mux_4x1_vector1;

architecture structural of mux_4x1_vector1 is
    component mux_2x1
        Port (
            d0 : in STD_LOGIC;
            d1 : in STD_LOGIC;
            s  : in STD_LOGIC;
            o  : out STD_LOGIC
        );
    end component;

    -- Intermediate signals for 2x1 multiplexers (4 for each 8-bit signal)
    signal mux1_out : STD_LOGIC_VECTOR(7 downto 0);
    signal mux2_out : STD_LOGIC_VECTOR(7 downto 0);

begin
    -- Instantiate 2x1 multiplexers for each bit of the 4-bit vectors

    -- MUX1 for d0, d1
    MUX1_0: mux_2x1 port map (d0 => d0(0), d1 => d1(0), s => s0, o => mux1_out(0));
    MUX1_1: mux_2x1 port map (d0 => d0(1), d1 => d1(1), s => s0, o => mux1_out(1));
    MUX1_2: mux_2x1 port map (d0 => d0(2), d1 => d1(2), s => s0, o => mux1_out(2));
    MUX1_3: mux_2x1 port map (d0 => d0(3), d1 => d1(3), s => s0, o => mux1_out(3));
    MUX1_4: mux_2x1 port map (d0 => d0(4), d1 => d1(4), s => s0, o => mux1_out(4));
    MUX1_5: mux_2x1 port map (d0 => d0(5), d1 => d1(5), s => s0, o => mux1_out(5));
    MUX1_6: mux_2x1 port map (d0 => d0(6), d1 => d1(6), s => s0, o => mux1_out(6));
    MUX1_7: mux_2x1 port map (d0 => d0(7), d1 => d1(7), s => s0, o => mux1_out(7));

    -- MUX2 for d2, d3
    MUX2_0: mux_2x1 port map (d0 => d2(0), d1 => d3(0), s => s0, o => mux2_out(0));
    MUX2_1: mux_2x1 port map (d0 => d2(1), d1 => d3(1), s => s0, o => mux2_out(1));
    MUX2_2: mux_2x1 port map (d0 => d2(2), d1 => d3(2), s => s0, o => mux2_out(2));
    MUX2_3: mux_2x1 port map (d0 => d2(3), d1 => d3(3), s => s0, o => mux2_out(3));
    MUX2_4: mux_2x1 port map (d0 => d2(4), d1 => d3(4), s => s0, o => mux2_out(4));
    MUX2_5: mux_2x1 port map (d0 => d2(5), d1 => d3(5), s => s0, o => mux2_out(5));
    MUX2_6: mux_2x1 port map (d0 => d2(6), d1 => d3(6), s => s0, o => mux2_out(6));
    MUX2_7: mux_2x1 port map (d0 => d2(7), d1 => d3(7), s => s0, o => mux2_out(7));
    
    -- MUX3 to select between the output of MUX1 and MUX2 for each bit
    MUX3_0: mux_2x1 port map (d0 => mux1_out(0), d1 => mux2_out(0), s => s1, o => o(0));
    MUX3_1: mux_2x1 port map (d0 => mux1_out(1), d1 => mux2_out(1), s => s1, o => o(1));
    MUX3_2: mux_2x1 port map (d0 => mux1_out(2), d1 => mux2_out(2), s => s1, o => o(2));
    MUX3_3: mux_2x1 port map (d0 => mux1_out(3), d1 => mux2_out(3), s => s1, o => o(3));    
    MUX3_4: mux_2x1 port map (d0 => mux1_out(4), d1 => mux2_out(4), s => s1, o => o(4)); 
    MUX3_5: mux_2x1 port map (d0 => mux1_out(5), d1 => mux2_out(5), s => s1, o => o(5));
    MUX3_6: mux_2x1 port map (d0 => mux1_out(6), d1 => mux2_out(6), s => s1, o => o(6));
    MUX3_7: mux_2x1 port map (d0 => mux1_out(7), d1 => mux2_out(7), s => s1, o => o(7));

end structural;


