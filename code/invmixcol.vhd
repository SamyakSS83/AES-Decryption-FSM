library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity control_inverseMixColumns is
    port (
        clk       : in  std_logic;
        rst       : in  std_logic;
        state_in  : in  std_logic_vector(127 downto 0);
        state_out : out std_logic_vector(127 downto 0);
        done      : out std_logic
    );
end entity control_inverseMixColumns;

architecture rtl of control_inverseMixColumns is
    -- Internal signals
    signal temp       : std_logic_vector(127 downto 0);
    signal temp_out   : std_logic_vector(127 downto 0);
    signal write_complete : std_logic := '0';
    signal cycle_counter  : integer := 0;
    signal final_done     : std_logic := '0';

    -- Function to multiply by {02} n-times
    function multiply(x : std_logic_vector(7 downto 0); n : integer) 
    return std_logic_vector is
        variable result : std_logic_vector(7 downto 0);
        variable temp : std_logic_vector(7 downto 0);
    begin
        temp := x;
        for i in 0 to n-1 loop
            if temp(7) = '1' then
                temp := std_logic_vector(shift_left(unsigned(temp), 1)) xor x"1b";
            else
                temp := std_logic_vector(shift_left(unsigned(temp), 1));
            end if;
        end loop;
        return temp;
    end function;

    -- Functions for multiplication
    function mb0e(x : std_logic_vector(7 downto 0)) return std_logic_vector is
    begin
        return multiply(x, 3) xor multiply(x, 2) xor multiply(x, 1);
    end function;

    function mb0d(x : std_logic_vector(7 downto 0)) return std_logic_vector is
    begin
        return multiply(x, 3) xor multiply(x, 2) xor x;
    end function;

    function mb0b(x : std_logic_vector(7 downto 0)) return std_logic_vector is
    begin
        return multiply(x, 3) xor multiply(x, 1) xor x;
    end function;

    function mb09(x : std_logic_vector(7 downto 0)) return std_logic_vector is
    begin
        return multiply(x, 3) xor x;
    end function;

begin
    -- Process for transposing and setting done signal
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                -- Resetting all signals
                temp <= (others => '0');
                temp_out <= (others => '0');
                write_complete <= '0';
                cycle_counter <= 0;
                final_done <= '0';
            else
                -- Transpose state_in to temp
                temp(127 downto 120) <= state_in(127 downto 120);
                temp(119 downto 112) <= state_in(95 downto 88);
                temp(111 downto 104) <= state_in(63 downto 56);
                temp(103 downto 96)  <= state_in(31 downto 24);
                temp(95 downto 88)   <= state_in(119 downto 112);
                temp(87 downto 80)   <= state_in(87 downto 80);
                temp(79 downto 72)   <= state_in(55 downto 48);
                temp(71 downto 64)   <= state_in(23 downto 16);
                temp(63 downto 56)   <= state_in(111 downto 104);
                temp(55 downto 48)   <= state_in(79 downto 72);
                temp(47 downto 40)   <= state_in(47 downto 40);
                temp(39 downto 32)   <= state_in(15 downto 8);
                temp(31 downto 24)   <= state_in(103 downto 96);
                temp(23 downto 16)   <= state_in(71 downto 64);
                temp(15 downto 8)    <= state_in(39 downto 32);
                temp(7 downto 0)     <= state_in(7 downto 0);

                -- Generate columns
                for i in 0 to 3 loop
                    -- Row 0
                    temp_out((i*32 + 31) downto (i*32 + 24)) <= 
                        mb0e(temp((i*32 + 31) downto (i*32 + 24))) xor 
                        mb0b(temp((i*32 + 23) downto (i*32 + 16))) xor 
                        mb0d(temp((i*32 + 15) downto (i*32 + 8))) xor 
                        mb09(temp((i*32 + 7) downto i*32));

                    -- Row 1
                    temp_out((i*32 + 23) downto (i*32 + 16)) <= 
                        mb09(temp((i*32 + 31) downto (i*32 + 24))) xor 
                        mb0e(temp((i*32 + 23) downto (i*32 + 16))) xor 
                        mb0b(temp((i*32 + 15) downto (i*32 + 8))) xor 
                        mb0d(temp((i*32 + 7) downto i*32));

                    -- Row 2
                    temp_out((i*32 + 15) downto (i*32 + 8)) <= 
                        mb0d(temp((i*32 + 31) downto (i*32 + 24))) xor 
                        mb09(temp((i*32 + 23) downto (i*32 + 16))) xor 
                        mb0e(temp((i*32 + 15) downto (i*32 + 8))) xor 
                        mb0b(temp((i*32 + 7) downto i*32));

                    -- Row 3
                    temp_out((i*32 + 7) downto i*32) <= 
                        mb0b(temp((i*32 + 31) downto (i*32 + 24))) xor 
                        mb0d(temp((i*32 + 23) downto (i*32 + 16))) xor 
                        mb09(temp((i*32 + 15) downto (i*32 + 8))) xor 
                        mb0e(temp((i*32 + 7) downto i*32));
                end loop;
                
                

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

    -- Final assignment
    -- Transpose temp_out to get the final state_out
    state_out(127 downto 120) <= temp_out(127 downto 120);
    state_out(95 downto 88)   <= temp_out(119 downto 112);
    state_out(63 downto 56)   <= temp_out(111 downto 104);
    state_out(31 downto 24)   <= temp_out(103 downto 96);
    
    state_out(119 downto 112) <= temp_out(95 downto 88);
    state_out(87 downto 80)   <= temp_out(87 downto 80);
    state_out(55 downto 48)   <= temp_out(79 downto 72);
    state_out(23 downto 16)   <= temp_out(71 downto 64);
    
    state_out(111 downto 104) <= temp_out(63 downto 56);
    state_out(79 downto 72)   <= temp_out(55 downto 48);
    state_out(47 downto 40)   <= temp_out(47 downto 40);
    state_out(15 downto 8)    <= temp_out(39 downto 32);
    
    state_out(103 downto 96)  <= temp_out(31 downto 24);
    state_out(71 downto 64)   <= temp_out(23 downto 16);
    state_out(39 downto 32)   <= temp_out(15 downto 8);
    state_out(7 downto 0)     <= temp_out(7 downto 0);

    -- Done signal assignment
    done <= final_done;

end architecture rtl;
