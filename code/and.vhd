-- AND GATE
library ieee;
use ieee.std_logic_1164.all;

entity AND_gate is
    Port ( a : in STD_LOGIC;
           b : in STD_LOGIC;
           c : out STD_LOGIC);
end AND_gate;
architecture Behavioral of AND_gate is

begin
    c <= a and b;
end Behavioral;
