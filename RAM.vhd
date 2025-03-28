library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity ram is
     Port ( clk : in std_logic;
            we : in STD_LOGIC;
            addr : in std_logic_vector (3 downto 0);
            di : in STD_LOGIC_VECTOR (31 downto 0);
            do : out STD_LOGIC_VECTOR (31 downto 0)
            );
end ram;

architecture Behavioral of ram is

type ram_array is array (0 to 15) of std_logic_vector(31 downto 0);
signal ram : ram_array := (
  (others => '0'),
  x"0000_0001",  
  x"0000_0002",
  x"0000_0003",
  others => (others => '0'));

begin
    process(clk)
    begin
        if rising_edge(clk) then
            if we = '1' then
                ram(conv_integer(addr)) <= di;
                do <= di;
            else
                do <= ram(conv_integer(addr));
            end if;
        end if;
    end process;
   
end Behavioral;
