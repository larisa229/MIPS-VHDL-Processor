library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity ram is
     Port ( clk  : in std_logic;
            wen  : in STD_LOGIC;
            addr : in std_logic_vector (3 downto 0);
            di   : in STD_LOGIC_VECTOR (15 downto 0);
            do   : out STD_LOGIC_VECTOR (15 downto 0)
            );
end ram;

architecture Behavioral of ram is

type t_ram is array (0 to 15) of std_logic_vector(15 downto 0);
signal s_ram : t_ram := (
  (others => '0'),
  x"0001",  
  x"0002",
  x"0003",
  others => (others => '0'));

begin
    process(clk)
    begin
        if rising_edge(clk) then
            if wen = '1' then
                s_ram(conv_integer(addr)) <= di;
                do <= di;
            end if;
        end if;
    end process;
    
    do <= s_ram(conv_integer(addr));
   
end Behavioral;
