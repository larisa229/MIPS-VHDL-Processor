
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity counter_decoder is
    Port ( clk : in STD_LOGIC;
           btn : in  std_logic_vector(4  downto 0);
           sw  : in  std_logic_vector(15 downto 0);
           led : out std_logic_vector(15 downto 0);
           an  : out std_logic_vector(7  downto 0);
           cat : out std_logic_vector(6  downto 0)
           );
end counter_decoder;

architecture Behavioral of counter_decoder is

signal en : STD_LOGIC_VECTOR(4 downto 0) := (others => '0');
signal cnt : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');

component MPG is
  Port (   clk : in STD_LOGIC;
           btn : in  std_logic_vector(4  downto 0);
           enable : out std_logic_vector(4  downto 0)
  );
end component;

component seven_seg_disp is
  port (
    clk    : in  std_logic;
    digits : in  std_logic_vector(31 downto 0);   
    an     : out std_logic_vector(7  downto 0);
    cat    : out std_logic_vector(6  downto 0)
  );
end component;

begin
    debounce: MPG port map (clk => clk, btn => btn, enable => en);
    display : seven_seg_disp port map (clk => clk, digits => x"1234_5678", an => an, cat => cat);

    process(clk, en)
    begin
        if rising_edge(clk) then
            if en(2) = '1' then
                cnt <= (others => '0');
            elsif en(0) = '1' then
                cnt <= cnt + 1;
            end if;
        end if;
       
    end process;

    led <= cnt;
    
end Behavioral;
