library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_arith.all;
  use ieee.std_logic_unsigned.all;

entity prob1 is
  port (
    btn : in  std_logic_vector(4  downto 0);
    sw  : in  std_logic_vector(15 downto 0);
    led : out std_logic_vector(15 downto 0);
    an  : out std_logic_vector(7  downto 0);
    cat : out std_logic_vector(6  downto 0)
  );
end entity prob1;

architecture behavioral of prob1 is  

begin

  led <= sw;
  an  <= "000" & btn(4 downto 0);
  cat <= (others => '0');

end architecture behavioral; 