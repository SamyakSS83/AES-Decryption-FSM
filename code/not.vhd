library ieee;
use ieee.std_logic_1164.all;
entity NOT_gate is
Port ( a : in STD_LOGIC;

b : out STD_LOGIC);
end NOT_gate;
architecture Behavioral of NOT_gate is
begin
b <= not a ;
end Behavioral;