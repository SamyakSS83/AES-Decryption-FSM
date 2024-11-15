library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity SevenSegmentASCII is
    Port (
        ascii_in : in STD_LOGIC_VECTOR(7 downto 0);  -- 8-bit ASCII input
        seg_a, seg_b, seg_c, seg_d, seg_e, seg_f, seg_g : out STD_LOGIC;  -- 7-segment outputs
        an : out STD_LOGIC_VECTOR(3 downto 0)  -- Anodes for 7-segment display
    );
end SevenSegmentASCII;

architecture Behavioral of SevenSegmentASCII is
begin
    -- Enable only the first digit (anode 0)
--    an <= "0111";

    -- Process the ASCII input to display corresponding character on the 7-segment
    process(ascii_in)
    begin
        case ascii_in is
            -- Digits 0 to 9
            when "00110000" =>  -- '0'
                seg_a <= '0'; seg_b <= '0'; seg_c <= '0'; seg_d <= '0';
                seg_e <= '0'; seg_f <= '0'; seg_g <= '1';
            when "00110001" =>  -- '1'
                seg_a <= '1'; seg_b <= '0'; seg_c <= '0'; seg_d <= '1';
                seg_e <= '1'; seg_f <= '1'; seg_g <= '1';
            when "00110010" =>  -- '2'
                seg_a <= '0'; seg_b <= '0'; seg_c <= '1'; seg_d <= '0';
                seg_e <= '0'; seg_f <= '1'; seg_g <= '0';
            when "00110011" =>  -- '3'
                seg_a <= '0'; seg_b <= '0'; seg_c <= '0'; seg_d <= '0';
                seg_e <= '1'; seg_f <= '1'; seg_g <= '0';
            when "00110100" =>  -- '4'
                seg_a <= '1'; seg_b <= '0'; seg_c <= '0'; seg_d <= '1';
                seg_e <= '1'; seg_f <= '0'; seg_g <= '0';
            when "00110101" =>  -- '5'
                seg_a <= '0'; seg_b <= '1'; seg_c <= '0'; seg_d <= '0';
                seg_e <= '1'; seg_f <= '0'; seg_g <= '0';
            when "00110110" =>  -- '6'
                seg_a <= '0'; seg_b <= '1'; seg_c <= '0'; seg_d <= '0';
                seg_e <= '0'; seg_f <= '0'; seg_g <= '0';
            when "00110111" =>  -- '7'
                seg_a <= '0'; seg_b <= '0'; seg_c <= '0'; seg_d <= '1';
                seg_e <= '1'; seg_f <= '1'; seg_g <= '1';
            when "00111000" =>  -- '8'
                seg_a <= '0'; seg_b <= '0'; seg_c <= '0'; seg_d <= '0';
                seg_e <= '0'; seg_f <= '0'; seg_g <= '0';
            when "00111001" =>  -- '9'
                seg_a <= '0'; seg_b <= '0'; seg_c <= '0'; seg_d <= '0';
                seg_e <= '1'; seg_f <= '0'; seg_g <= '0';

            -- Letters A to F (case-insensitive)
            when "01000001" | "01100001" =>  -- 'A' or 'a'
                seg_a <= '0'; seg_b <= '0'; seg_c <= '0'; seg_d <= '1';
                seg_e <= '0'; seg_f <= '0'; seg_g <= '0';
            when "01000010" | "01100010" =>  -- 'B' or 'b'
                seg_a <= '1'; seg_b <= '1'; seg_c <= '0'; seg_d <= '0';
                seg_e <= '0'; seg_f <= '0'; seg_g <= '0';
            when "01000011" | "01100011" =>  -- 'C' or 'c'
                seg_a <= '0'; seg_b <= '1'; seg_c <= '1'; seg_d <= '0';
                seg_e <= '0'; seg_f <= '0'; seg_g <= '1';
            when "01000100" | "01100100" =>  -- 'D' or 'd'
                seg_a <= '1'; seg_b <= '0'; seg_c <= '0'; seg_d <= '0';
                seg_e <= '0'; seg_f <= '1'; seg_g <= '0';
            when "01000101" | "01100101" =>  -- 'E' or 'e'
                seg_a <= '0'; seg_b <= '1'; seg_c <= '1'; seg_d <= '0';
                seg_e <= '0'; seg_f <= '0'; seg_g <= '0';
            when "01000110" | "01100110" =>  -- 'F' or 'f'
                seg_a <= '0'; seg_b <= '1'; seg_c <= '1'; seg_d <= '1';
                seg_e <= '0'; seg_f <= '0'; seg_g <= '0';

            -- Default case for invalid characters (display '-')
            when others =>
                seg_a <= '1'; seg_b <= '1'; seg_c <= '1'; seg_d <= '1';
                seg_e <= '1'; seg_f <= '1'; seg_g <= '0';
        end case;
    end process;
end Behavioral;
