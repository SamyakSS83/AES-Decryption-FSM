library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Entity declaration for InvShiftRows
entity control_InvShiftRows is
    Port (
        clk       : in  std_logic;
        rst       : in  std_logic;
        input_data : in std_logic_vector(127 downto 0);  -- 128-bit input data
        output_data : out std_logic_vector(127 downto 0); -- 128-bit output data
        done      : out std_logic
        );
end control_InvShiftRows;

-- Architecture definition for InvShiftRows
architecture Behavioral of control_InvShiftRows is

    

    -- Component declaration for rotate_right
    component rotate_right is
        Port (
            s0, s1 : in std_logic;
            d0, d1, d2, d3 : in std_logic_vector(7 downto 0);  -- 8-bit input data
            result0, result1, result2, result3 : out std_logic_vector(7 downto 0)  -- 8-bit output data
        );
    end component;

    signal row0, row1, row2, row3 : std_logic_vector(31 downto 0);  -- Temporary 32-bit segments
    signal result0, result1, result2, result3 : std_logic_vector(31 downto 0);
    signal temp : std_logic_vector(127 downto 0);
    signal write_complete : std_logic := '0';
    signal cycle_counter  : integer := 0;
    signal final_done     : std_logic := '0';
begin


                row0 <= input_data(127 downto 96);  -- First 32 bits
                row1 <= input_data(95 downto 64);   -- Next 32 bits
                row2 <= input_data(63 downto 32);   -- Next 32 bits
                row3 <= input_data(31 downto 0);    -- Last 32 bits

                -- Rotate the first row with select signals 00 (s0 = '0', s1 = '0')
                ROTATE_ROW0: rotate_right port map (
                    s0 => '0',
                    s1 => '0',
                    d0 => row0(7 downto 0), 
                    d1 => row0(15 downto 8), 
                    d2 => row0(23 downto 16), 
                    d3 => row0(31 downto 24),
                    result0 => result0(7 downto 0), 
                    result1 => result0(15 downto 8), 
                    result2 => result0(23 downto 16), 
                    result3 => result0(31 downto 24)
                );

                -- Rotate the second row with select signals 01 (s0 = '0', s1 = '1')
                ROTATE_ROW1: rotate_right port map (
                    s0 => '1',
                    s1 => '1',
                    d0 => row1(7 downto 0), 
                    d1 => row1(15 downto 8), 
                    d2 => row1(23 downto 16), 
                    d3 => row1(31 downto 24),
                    result0 => result1(7 downto 0), 
                    result1 => result1(15 downto 8), 
                    result2 => result1(23 downto 16), 
                    result3 => result1(31 downto 24)
                );

                -- Rotate the third row with select signals 10 (s0 = '1', s1 = '0')
                ROTATE_ROW2: rotate_right port map (
                    s0 => '0',
                    s1 => '1',
                    d0 => row2(7 downto 0), 
                    d1 => row2(15 downto 8), 
                    d2 => row2(23 downto 16), 
                    d3 => row2(31 downto 24),
                    result0 => result2(7 downto 0), 
                    result1 => result2(15 downto 8), 
                    result2 => result2(23 downto 16), 
                    result3 => result2(31 downto 24)
                );

                -- Rotate the fourth row with select signals 11 (s0 = '1', s1 = '1')
                ROTATE_ROW3: rotate_right port map (
                    s0 => '1',
                    s1 => '0',
                    d0 => row3(7 downto 0), 
                    d1 => row3(15 downto 8), 
                    d2 => row3(23 downto 16), 
                    d3 => row3(31 downto 24),
                    result0 => result3(7 downto 0), 
                    result1 => result3(15 downto 8), 
                    result2 => result3(23 downto 16), 
                    result3 => result3(31 downto 24)
                );
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                cycle_counter <= 0;
                final_done <= '0';
                write_complete <= '0';
                temp <= x"00000000000000000000000000000000";
            else
                
            temp <= result0 & result1 & result2 & result3;
            -- Set write_complete and cycle_counter
            if write_complete = '0' then
                write_complete <= '1';
                cycle_counter <= 1;
            elsif write_complete = '1' and cycle_counter < 10 then
                cycle_counter <= cycle_counter + 1;
            elsif write_complete = '1' and cycle_counter = 10 then
                final_done <= '1';
            end if;
        end if;
    end if;
end process;


    -- Concatenate the rotated rows to form the output
    output_data <= temp;
    done <= final_done;

end Behavioral;
