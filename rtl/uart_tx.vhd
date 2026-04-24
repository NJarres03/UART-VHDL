library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_tx is
    port(
        clk       :in std_logic;
        rst       : in std_logic;
        baud_tick : in std_logic;
        tx_data   : in std_logic_vector(7 downto 0);
        tx_valid  : in std_logic;
        tx_ready  : out std_logic;
        tx_serial : out std_logic
    );
    end entity uart_tx;

architecture rtl of uart_tx is

    type tx_state_t is (IDLE, START, DATA, STOP);
    signal state : tx_state_t;

    signal shift_reg : std_logic_vector(7 downto 0);
    signal bit_cnt   : unsigned(2 downto 0);

begin
    process(clk)
    begin
        if rising_edge(clk) then
            if (rst = '1') then
                state <= IDLE;
                tx_serial <= '1';
                tx_ready <= '1';
                shift_reg <= (others => '0');
                bit_cnt <= (others => '0');
            else
                case state is 

                    when IDLE =>
                        tx_serial <= '1';
                        tx_ready  <= '1';
                        if (tx_valid = '1') then
                            shift_reg <= tx_data;
                            tx_ready <= '0';
                            state <= START;
                        end if;

                    when START =>
                        tx_serial <= '0';
                        tx_ready  <= '0';
                        if (baud_tick = '1') then
                            bit_cnt <= (others => '0');
                            state <= DATA;
                        end if;

                    when DATA => 
                        tx_serial <= shift_reg(0);
                        tx_ready <= '0';
                        if (baud_tick = '1') then
                            shift_reg <= '0' & shift_reg (7 downto 1);
                            if (bit_cnt = 7) then
                                state <= STOP;
                            else
                                bit_cnt <= bit_cnt + 1;
                            end if;
                        end if;
                        
                    when STOP => 
                        tx_serial <= '1';
                        tx_ready  <= '0';
                        if (baud_tick = '1') then
                            tx_ready <= '1';
                            state <= IDLE;
                        end if;

                end case;
            end if;
        end if;
    end process;

end architecture rtl;

