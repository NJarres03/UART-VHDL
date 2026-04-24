library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_tb is
end entity uart_tb;

architecture sim of uart_tb is

    -- Clock and reset
    signal clk : std_logic := '0';
    signal rst : std_logic := '1';

    -- TX interface
    signal tx_data  : std_logic_vector(7 downto 0) := (others => '0');
    signal tx_valid : std_logic := '0';
    signal tx_ready : std_logic;

    -- RX interface
    signal rx_data  : std_logic_vector(7 downto 0);
    signal rx_valid : std_logic;
    signal frame_err: std_logic;

    -- The loopback wire
    signal serial_loop : std_logic;

begin

    -- 100 MHz clock: toggle every 5 ns = 10 ns period
    clk <= not clk after 5 ns;

    dut : entity work.uart_top
        generic map (
            CLK_FREQ_HZ => 100_000_000,
            BAUD_RATE   => 115_200
        )
        port map (
            clk       => clk,
            rst       => rst,
            tx_data   => tx_data,
            tx_valid  => tx_valid,
            tx_ready  => tx_ready,
            rx_data   => rx_data,
            rx_valid  => rx_valid,
            frame_err => frame_err,
            tx_serial => serial_loop,   -- TX output...
            rx_serial => serial_loop    -- ...feeds straight into RX input
        );
    
    stim : process
    begin
        -- Hold reset for 10 cycles
        rst <= '1';
        wait for 100 ns;
        rst <= '0';
        wait for 100 ns;

        -- Test 1: 0x55
        wait until rising_edge(clk);
        tx_data  <= x"55";
        tx_valid <= '1';
        wait until rising_edge(clk);
        tx_valid <= '0';
        wait until rx_valid = '1';
        wait until rising_edge(clk);
        assert rx_data = x"55"
            report "FAIL test 1: expected 0x55, got " &
                   integer'image(to_integer(unsigned(rx_data)))
            severity error;
        report "PASS test 1: 0x55" severity note;

        -- Test 2: 0x00
        wait until tx_ready = '1';
        wait until rising_edge(clk);
        tx_data  <= x"00";
        tx_valid <= '1';
        wait until rising_edge(clk);
        tx_valid <= '0';
        wait until rx_valid = '1';
        wait until rising_edge(clk);
        assert rx_data = x"00"
            report "FAIL test 2: expected 0x00"
            severity error;
        report "PASS test 2: 0x00" severity note;

        -- Test 3: 0xFF
        wait until tx_ready = '1';
        wait until rising_edge(clk);
        tx_data  <= x"FF";
        tx_valid <= '1';
        wait until rising_edge(clk);
        tx_valid <= '0';
        wait until rx_valid = '1';
        wait until rising_edge(clk);
        assert rx_data = x"FF"
            report "FAIL test 3: expected 0xFF"
            severity error;
        report "PASS test 3: 0xFF" severity note;

        -- Test 4: 0xA3
        wait until tx_ready = '1';
        wait until rising_edge(clk);
        tx_data  <= x"A3";
        tx_valid <= '1';
        wait until rising_edge(clk);
        tx_valid <= '0';
        wait until rx_valid = '1';
        wait until rising_edge(clk);
        assert rx_data = x"A3"
            report "FAIL test 4: expected 0xA3"
            severity error;
        report "PASS test 4: 0xA3" severity note;

        report "ALL TESTS PASSED" severity note;
        wait;
    end process stim;

end architecture sim;