library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;  -- Added this library

entity round_keys_make is
    Port ( 
           clk     : in  std_logic;                    -- Clock input
           ena     : in  std_logic;                    -- Enable signal for ROM
           i       : in  integer range 0 to 9;        -- Block index (1-10 for 160 values)
           dout    : out std_logic_vector(127 downto 0) -- 128-bit data output
         );
end round_keys_make;

architecture Behavioral of round_keys_make is
    -- Keep the original ROM component name
    component round_keys
        Port (
            clka  : in  std_logic;                    -- Clock input for ROM
            ena   : in  std_logic;                    -- Enable signal
            addra : in  std_logic_vector(7 downto 0); -- 9-bit address input for ROM
            douta : out std_logic_vector(7 downto 0)  -- 8-bit data output from ROM
        );
    end component;

    signal temp_data : std_logic_vector(127 downto 0);  -- Temporary 128-bit block storage
    type rom_data_array is array (0 to 15) of std_logic_vector(7 downto 0);
    signal rom_data : rom_data_array;     -- Array to hold ROM outputs
    
begin
    -- Generate 16 ROM instances
    gen_roms: for j in 0 to 15 generate
        rom_inst: round_keys
            port map (
                clka  => clk,
                ena   => ena,
                addra => conv_std_logic_vector((i) * 16 + j, 8),
                douta => rom_data(j)
            );
    end generate;

    -- Process to manually assign values from rom_data to temp_data
    process(clk)
    begin
        if rising_edge(clk) then
            if ena = '1' then
                -- Manually assign each byte from rom_data into temp_data
                temp_data(127 downto 120) <= rom_data(0);
                temp_data(119 downto 112) <= rom_data(1);
                temp_data(111 downto 104) <= rom_data(2);
                temp_data(103 downto  96) <= rom_data(3);
                temp_data( 95 downto  88) <= rom_data(4);
                temp_data( 87 downto  80) <= rom_data(5);
                temp_data( 79 downto  72) <= rom_data(6);
                temp_data( 71 downto  64) <= rom_data(7);
                temp_data( 63 downto  56) <= rom_data(8);
                temp_data( 55 downto  48) <= rom_data(9);
                temp_data( 47 downto  40) <= rom_data(10);
                temp_data( 39 downto  32) <= rom_data(11);
                temp_data( 31 downto  24) <= rom_data(12);
                temp_data( 23 downto  16) <= rom_data(13);
                temp_data( 15 downto   8) <= rom_data(14);
                temp_data(  7 downto   0) <= rom_data(15);

                  dout <= temp_data;
            end if;
        end if;
    end process;

end Behavioral;
