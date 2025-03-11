library IEEE;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;


entity MPG is
  Port (   clk : in STD_LOGIC;
           btn : in  std_logic_vector(4  downto 0);
           enable : out std_logic_vector(4  downto 0)

  );
end MPG;

architecture Behavioral of MPG is

signal cnt: STD_LOGIC_VECTOR(15 downto 0):= (others => '0');
signal en: STD_LOGIC := '0';
signal q1, q2, q3: STD_LOGIC_VECTOR(4 downto 0) := (others =>'0');

begin
    counter: process (clk)
    begin
        if rising_edge(clk) then
            cnt <= cnt + 1;
        end if;
    end process counter;
    
    en <= '1' when cnt = x"000F" else '0';
    
    process(clk)
    begin
        if rising_edge(clk) then
            if en = '1' then
                q1 <= btn;
            end if;
        end if;
    end process;
    
    process(clk)
    begin
        if rising_edge(clk) then
            q2 <= q1;
        end if;
    end process;
    
    process(clk)
    begin
        if rising_edge(clk) then
            q3 <= q2;
         end if;
    end process;
    
    enable <= q2 and (not q3);

end Behavioral;
