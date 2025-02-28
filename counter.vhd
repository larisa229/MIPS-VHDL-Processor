
library IEEE;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;


entity counter is
    Port ( clk : in STD_LOGIC;
           btn : in  std_logic_vector(4  downto 0);
           sw  : in  std_logic_vector(15 downto 0);
           led : out std_logic_vector(15 downto 0);
           an  : out std_logic_vector(7  downto 0);
           cat : out std_logic_vector(6  downto 0)
           );
end counter;

architecture Behavioral of counter is

signal cnt: STD_LOGIC_VECTOR(15 downto 0):= (others => '0');
signal en: STD_LOGIC;

begin
    process (clk)
    begin
        if rising_edge(clk) then
          if btn(0) = '1' then 
            cnt <= cnt + 1;
          end if;
        end if;
    end process;
    
led(15 downto 0) <= cnt(15 downto 0);

end Behavioral;
