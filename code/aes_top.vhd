library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity aes_top_decrypt is
    port (  
        clk      : in  std_logic;                      -- Clock
        rst      : in  std_logic;                      -- Reset
        enable   : in  std_logic;                      -- Enable
        input    : in  std_logic_vector(127 downto 0); -- Ciphertext input
        output   : out std_logic_vector(127 downto 0); -- Plaintext output
        complete : out std_logic                       -- Complete signal
    );
end aes_top_decrypt;

architecture Behavioral of aes_top_decrypt is

    -- State machine for the top-level module.
    type top_state is (idle, decrypt);
    signal current_state_top : top_state := idle;
--    signal input : std_logic_vector(127 downto 0);
--    signal output : std_logic_vector(127 downto 0);
    

    -- State machine for each round.
    type round_state is (intermediary_wait, pre_round, sub_bytes, shift_rows, mix_columns, add_round_key, get_result);
    signal current_state_round : round_state := pre_round;
    signal next_state_round    : round_state;

    -- Reset counter
    signal reset_counter : integer range 0 to 1 := 0;

    -- Operation in progress
    signal process_busy : std_logic := '0';

    -- Components declarations
    component control_InvShiftRows is
        port (  
            clk         : in  std_logic;
            rst         : in  std_logic;
            input_data  : in  std_logic_vector(127 downto 0);
            output_data : out std_logic_vector(127 downto 0);
            done        : out std_logic
        );
    end component;

    component add_round_keys is 
        port (
            clk       : in  std_logic;
            rst       : in  std_logic;
            i         : in  integer range 0 to 9;
            state_in  : in  std_logic_vector(127 downto 0);
            state_out : out std_logic_vector(127 downto 0);
            done      : out std_logic
        );
    end component;

    component integrated_InvSubBytes is
        port (  
            clk       : in  std_logic;
            rst       : in  std_logic;
            state_in  : in  std_logic_vector(127 downto 0);
            state_out : out std_logic_vector(127 downto 0);
            done      : out std_logic
        );
    end component;

    component control_inverseMixColumns is
        port (  
            clk       : in  std_logic;
            rst       : in  std_logic;
            state_in  : in  std_logic_vector(127 downto 0);
            state_out : out std_logic_vector(127 downto 0);
            done      : out std_logic
        );
    end component;

    -- Track round number and operation completion.
    signal current_round : integer range 0 to 9;
    signal finished      : std_logic := '0';

    -- Signals to hold the state throughout rounds.
    signal round_result : std_logic_vector(127 downto 0) := (others => '0');

    -- Signals for operation controls and statuses.
    signal add_round_key_rst    : std_logic := '0';
    signal add_round_key_done   : std_logic;
    signal sub_bytes_rst        : std_logic := '0';
    signal sub_bytes_done       : std_logic;
    signal shift_rows_rst       : std_logic := '0';
    signal shift_rows_done      : std_logic;
    signal mix_columns_rst      : std_logic := '0';
    signal mix_columns_done     : std_logic;

    -- Signals for AddRoundKey operation.
    signal add_round_key_state, add_round_key_result : std_logic_vector(127 downto 0);

    -- Signals for InvSubBytes operation.
    signal sub_bytes_state, sub_bytes_result : std_logic_vector(127 downto 0);

    -- Signals for InvShiftRows operation.
    signal shift_rows_state, shift_rows_result : std_logic_vector(127 downto 0);

    -- Signals for InvMixColumns operation.
    signal mix_columns_state, mix_columns_result : std_logic_vector(127 downto 0);

begin
--        input <= x"5a5af5fd86d4f39280cb9b886411886b";

    -- Instantiate components
    operation_add_round_key : add_round_keys port map (
        clk       => clk,
        rst       => add_round_key_rst,
        i         => current_round,
        state_in  => add_round_key_state,
        state_out => add_round_key_result,
        done      => add_round_key_done
    );

    operation_sub_bytes : integrated_InvSubBytes port map (
        clk       => clk,
        rst       => sub_bytes_rst,
        state_in  => sub_bytes_state,
        state_out => sub_bytes_result,
        done      => sub_bytes_done
    );

    operation_shift_rows : control_InvShiftRows port map (
        clk         => clk,
        rst         => shift_rows_rst,
        input_data  => shift_rows_state,
        output_data => shift_rows_result,
        done        => shift_rows_done
    );

    operation_mix_columns : control_inverseMixColumns port map (
        clk       => clk,
        rst       => mix_columns_rst,
        state_in  => mix_columns_state,
        state_out => mix_columns_result,
        done      => mix_columns_done
    );

    -- Merged process
    process(clk, rst)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                -- Reset all signals
                current_state_top    <= idle;
                current_state_round  <= pre_round;
                next_state_round     <= pre_round;
                current_round        <= 9;
                finished             <= '0';
                reset_counter        <= 0;
                process_busy         <= '0';
                add_round_key_rst    <= '0';
                sub_bytes_rst        <= '0';
                shift_rows_rst       <= '0';
                mix_columns_rst      <= '0';
                round_result         <= (others => '0');
            else
                case current_state_top is
                    when idle =>
                        if enable = '1' and finished = '0' then
                            current_state_top <= decrypt;
                        end if;

                    when decrypt =>
                        -- Round counter logic
                        if current_state_round = get_result then
                            if current_round > 0 then
                                current_round <= current_round - 1;
                            end if;
                        end if;

                        -- Decryption process state machine
                        case current_state_round is

                            when intermediary_wait =>
                                current_state_round <= next_state_round;

                            when pre_round =>
                                next_state_round    <= add_round_key;
                                current_state_round <= intermediary_wait;

                            when add_round_key =>
                                if process_busy = '0' then
                                    reset_counter     <= 1;
                                    process_busy      <= '1';
                                    add_round_key_rst <= '1';
                                elsif reset_counter = 1 then
                                    reset_counter     <= 0;
                                    add_round_key_rst <= '0';
                                    if current_round = 9 then
                                        add_round_key_state <= input;
                                        next_state_round    <= shift_rows;
                                    elsif current_round = 0 then
                                        add_round_key_state <= sub_bytes_result;
                                        next_state_round    <= get_result;
                                    else
                                        add_round_key_state <= round_result;
                                        next_state_round    <= mix_columns;
                                    end if;
                                else
                                    if add_round_key_done = '1' then
                                        process_busy        <= '0';
                                        current_state_round <= next_state_round;
                                    end if;
                                end if;

                            when sub_bytes =>
                                if process_busy = '0' then
                                    reset_counter  <= 1;
                                    process_busy   <= '1';
                                    sub_bytes_rst  <= '1';
                                elsif reset_counter = 1 then
                                    reset_counter   <= 0;
                                    sub_bytes_rst   <= '0';
                                    sub_bytes_state <= shift_rows_result;
                                    if current_round = 0 then
                                        next_state_round <= add_round_key;
                                    else
                                        next_state_round <= get_result;
                                    end if;
                                else
                                    if sub_bytes_done = '1' then
                                        process_busy        <= '0';
                                        current_state_round <= next_state_round;
                                    end if;
                                end if;

                            when shift_rows =>
                                if process_busy = '0' then
                                    reset_counter    <= 1;
                                    process_busy     <= '1';
                                    shift_rows_rst   <= '1';
                                elsif reset_counter = 1 then
                                    reset_counter     <= 0;
                                    shift_rows_rst    <= '0';
                                    if current_round = 9 then
                                        shift_rows_state <= add_round_key_result;
                                    else
                                        shift_rows_state <= mix_columns_result;
                                    end if;
                                    next_state_round <= sub_bytes;
                                else
                                    if shift_rows_done = '1' then
                                        process_busy        <= '0';
                                        current_state_round <= next_state_round;
                                    end if;
                                end if;

                            when mix_columns =>
                                if process_busy = '0' then
                                    reset_counter     <= 1;
                                    process_busy      <= '1';
                                    mix_columns_rst   <= '1';
                                elsif reset_counter = 1 then
                                    reset_counter      <= 0;
                                    mix_columns_rst    <= '0';
                                    mix_columns_state  <= add_round_key_result;
                                    next_state_round   <= shift_rows;
                                else
                                    if mix_columns_done = '1' then
                                        process_busy        <= '0';
                                        current_state_round <= next_state_round;
                                    end if;
                                end if;

                            when get_result =>
                                if current_round = 0 then
                                    round_result       <= add_round_key_result;
                                    finished           <= '1';
                                    current_state_top  <= idle;  -- Go back to idle after completion
                                else
                                    round_result        <= sub_bytes_result;
                                    next_state_round    <= add_round_key;
                                    current_state_round <= intermediary_wait;
                                end if;

                            when others =>
                                -- Do nothing
                                null;
                        end case;

                    when others =>
                        -- Do nothing
                        null;
                end case;
            end if;
        end if;
    end process;

    -- Output assignments
    output   <= round_result;
    complete <= finished;

end Behavioral;