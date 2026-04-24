library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity baud_gen is

    generic (

        CLK_FREQ_HZ : integer := 100_000_000;
        BAUD_RATE   : integer := 115_200
    );

    port (
        clk       : in std_logic;
        rst       : in std_logic;
        baud_tick : out std_logic;
        os_tick   : out std_logic

    );

end entity baud_gen;

architecture rtl of BAUD_gen is

    constant BAUD_DIV : integer := CLK_FREQ_HZ/BAUD_RATE;
    constant OS_DIV   : integer :=  CLK_FREQ_HZ/(BAUD_RATE * 16);
    
    signal baud_cnt : unsigned(9 downto 0);
    signal os_cnt   : unsigned(9 downto 0);

begin

    process(clk)
    begin

        if rising_edge(clk) then

            if (rst = '1') then
                baud_cnt <= (others => '0');
                baud_tick <= '0';
            elsif (baud_cnt = BAUD_DIV - 2) then
                baud_cnt <= (others => '0');
                baud_tick <= '1';
            else
                baud_cnt <= baud_cnt + 1;
                baud_tick <= '0';
            end if;

        end if;
    end process;

    process(clk)
    begin
        if rising_edge(clk) then

            if (rst = '1') then
                os_cnt <= (others => '0');
                os_tick <= '0';
            elsif (os_cnt = OS_DIV - 2) then
                os_cnt <= (others => '0');
                os_tick <= '1';
            else 
                os_cnt <= os_cnt + 1;
                os_tick <= '0';
            end if;

        end if;
    end process;

end architecture rtl;


        




