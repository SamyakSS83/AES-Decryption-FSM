library ieee;
use ieee.std_logic_1164.all;

entity mux_2x1 is
    Port ( d0 : in STD_LOGIC;
           d1 : in STD_LOGIC;
           s : in STD_LOGIC;
           o : out STD_LOGIC);
end mux_2x1;

architecture structural of mux_2x1 is
    component AND_gate
        Port ( a : in STD_LOGIC;
               b : in STD_LOGIC;
               c : out STD_LOGIC);
    end component;

    component OR_gate
        Port ( a : in STD_LOGIC;
               b : in STD_LOGIC;
               c : out STD_LOGIC);
    end component;

    component NOT_gate
        Port ( a : in STD_LOGIC;
               b : out STD_LOGIC);
    end component;

    signal not_s, and1_out, and2_out : STD_LOGIC;

begin
    NOT1: NOT_gate port map (a => s, b => not_s);
    AND1: AND_gate port map (a => not_s, b => d0, c => and1_out);
    AND2: AND_gate port map (a => s, b => d1, c => and2_out);
    OR1: OR_gate port map (a => and1_out, b => and2_out, c => o);
end structural;