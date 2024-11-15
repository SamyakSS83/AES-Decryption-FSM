library ieee;
use ieee.std_logic_1164.all;
entity OR_gate is
Port ( a : in STD_LOGIC;
b : in STD_LOGIC;
c : out STD_LOGIC);
end OR_gate;
architecture Behavioral of OR_gate is
begin
c <= a or b;
end Behavioral;