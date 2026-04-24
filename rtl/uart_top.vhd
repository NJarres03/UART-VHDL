library ieee;
use ieee.std_logic_1164.all;

entity uart_top is
    generic (
        CLK_FREQ_HZ : integer := 100_000_000;
        BAUD_RATE   : integer := 115_200
    );
    port (
        clk       : in  std_logic;
        rst       : in  std_logic;
        tx_data   : in  std_logic_vector(7 downto 0);
        tx_valid  : in  std_logic;
        tx_ready  : out std_logic;
        rx_data   : out std_logic_vector(7 downto 0);
        rx_valid  : out std_logic;
        frame_err : out std_logic;
        tx_serial : out std_logic;
        rx_serial : in  std_logic
    );
end entity uart_top;

architecture structural of uart_top is

    signal baud_tick : std_logic;
    signal os_tick   : std_logic;

begin
    baud : entity work.baud_gen
        generic map (
            CLK_FREQ_HZ => CLK_FREQ_HZ,
            BAUD_RATE   => BAUD_RATE
        )
        port map (
            clk       => clk,
            rst       => rst,
            baud_tick => baud_tick,
            os_tick   => os_tick
        );

    tx : entity work.uart_tx
        port map (
            clk       => clk,
            rst       => rst,
            baud_tick => baud_tick,
            tx_data   => tx_data,
            tx_valid  => tx_valid,
            tx_ready  => tx_ready,
            tx_serial => tx_serial
        );
    rx : entity work.uart_rx
        port map (
            clk       => clk,
            rst       => rst,
            os_tick   => os_tick,
            rx_serial => rx_serial,
            rx_data   => rx_data,
            rx_valid  => rx_valid,
            frame_err => frame_err
        );

end architecture structural;