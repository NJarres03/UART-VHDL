library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_rx is
    port(
        clk       : in std_logic;
        rst       : in std_logic;
        os_tick   : in std_logic;
        rx_serial : in std_logic;
        rx_data   : out std_logic_vector(7 downto 0);
        rx_valid  : out std_logic;
        frame_err : out std_logic
    );
end entity uart_rx;

architecture rtl of uart_rx is

    type rx_state_t is (IDLE, START, DATA, STOP);
    signal state : rx_state_t;

    signal os_cnt    : unsigned(3 downto 0);
    signal shift_reg : std_logic_vector(7 downto 0);
    signal bit_cnt   : unsigned(2 downto 0);

    signal rx_sync1, rx_sync2       : std_logic;
    attribute ASYNC_REG             : string;
    attribute ASYNC_REG of rx_sync1 : signal is "TRUE";
    attribute ASYNC_REG of rx_sync2 : signal is "TRUE";

begin
    sync : process(clk)
    begin
        if rising_edge(clk) then
            if (rst = '1') then
                rx_sync1 <= '1';
                rx_sync2 <= '1';
            else 
                rx_sync1 <= rx_serial;
                rx_sync2 <= rx_sync1;
            end if;
        end if;
    end process sync;

    rx : process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                state     <= IDLE;
                os_cnt    <= (others => '0');
                bit_cnt   <= (others => '0');
                shift_reg <= (others => '0');
                rx_data   <= (others => '0');
                rx_valid  <= '0';
                frame_err <= '0';
            else
                rx_valid  <= '0';
                frame_err <= '0';

                case state is

                    when IDLE =>
                        if (rx_sync2 = '0') then
                            os_cnt <= (others => '0');
                            state <= START;
                        end if;

                    when START =>
                        if (os_tick = '1') then
                            if (os_cnt = 7) then
                                os_cnt <= (others => '0');
                                if (rx_sync2 = '0') then
                                    bit_cnt <= (others => '0');
                                    state <= DATA;
                                else
                                    state <= IDLE;
                                end if;
                            else
                                os_cnt <= os_cnt + 1;
                            end if;
                        end if;

                    when DATA =>
                        if (os_tick = '1') then
                            if (os_cnt = 15) then
                                os_cnt <= (others => '0');
                                shift_reg <= rx_sync2 & shift_reg(7 downto 1);
                                if (bit_cnt = 7) then
                                    state <= STOP;
                                else 
                                    bit_cnt <= bit_cnt + 1;
                                end if;
                            else
                                os_cnt <= os_cnt + 1;
                            end if;
                        end if;
                
                    when STOP => 
                        if (os_tick = '1') then
                            if (os_cnt = 15) then
                                os_cnt <= (others => '0');
                                if (rx_sync2 = '1') then
                                    rx_data  <= shift_reg;
                                    rx_valid <= '1';
                                else 
                                    frame_err <= '1';
                                end if;
                                state <= IDLE;
                            else
                                os_cnt <= os_cnt + 1;
                            end if;
                        end if;
            
                end case;
            end if;
        end if;
    end process rx;

end architecture rtl;