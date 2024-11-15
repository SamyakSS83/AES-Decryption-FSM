library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Entity declaration
entity rotate_right is
    Port (
        s0, s1 : in std_logic;
        d0, d1, d2, d3 : in std_logic_vector(7 downto 0);  -- 8-bit input data
        result0, result1, result2, result3 : out std_logic_vector(7 downto 0)  -- 8-bit output data
    );
end rotate_right;

-- Architecture definition
architecture Behavioral of rotate_right is

    -- Multiplexer component declaration
    component mux_4x1_vector1 is
        Port (
        d0 : in STD_LOGIC_VECTOR(7 downto 0);
        d1 : in STD_LOGIC_VECTOR(7 downto 0);
        d2 : in STD_LOGIC_VECTOR(7 downto 0);
        d3 : in STD_LOGIC_VECTOR(7 downto 0);
        s0 : in STD_LOGIC; -- Select signal bit 0
        s1 : in STD_LOGIC; -- Select signal bit 1
        o : out STD_LOGIC_VECTOR(7 downto 0) -- 8-bit output
        );
    end component;

begin

    -- Right rotation logic:
    -- result0 should get d1, result1 should get d2, result2 should get d3, and result3 should get d0.

    MUX0: mux_4x1_vector1 port map (
        d0 => d0, d1 => d3, d2 => d2, d3 => d1,
        s0 => s0,
        s1 => s1,
        o => result0
    );

    MUX1: mux_4x1_vector1 port map (
        d0 => d1, d1 => d0, d2 => d3, d3 => d2,
        s0 => s0,
        s1 => s1,
        o => result1
    );

    MUX2: mux_4x1_vector1 port map (
        d0 => d2, d1 => d1, d2 => d0, d3 => d3,
        s0 => s0,
        s1 => s1,
        o => result2
    );

    MUX3: mux_4x1_vector1 port map (
        d0 => d3, d1 => d2, d2 => d1, d3 => d0,
        s0 => s0,
        s1 => s1,
        o => result3
    );

end Behavioral;
