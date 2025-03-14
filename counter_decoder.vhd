
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
signal cnt : STD_LOGIC_VECTOR(1 downto 0) := (others => '0');
signal s_digits : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
signal in1, in2, in3 : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
signal out1, out2, out3, out4 : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');

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
    display : seven_seg_disp port map (clk => clk, digits => s_digits, an => an, cat => cat);
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

    led(1 downto 0) <= cnt;
    in1 <= (31 downto 8 => '0')&sw(7 downto 0);
    in2 <= (31 downto 8 => '0')&sw(15 downto 8);
    in3 <= (31 downto 16 => '0')&sw(15 downto 0);
    
    process (in1, in2) 
    begin
        out1 <= in1 + in2;
    end process;
    
    process (in1, in2) 
    begin
        out2 <= in1 - in2;
    end process;
    
    process (in3) 
    begin
        out3 <= in3(29 downto 0)&"00";
        out4 <= "00"&in3(31 downto 2);
    end process;
    
    process (cnt)
    begin
      case cnt is
        when "00"  => s_digits <= out1;
        when "01"  => s_digits <= out2;
        when "10"  => s_digits <= out3;
        when others => s_digits <= out4;
      end case;
    end process;
    
    led(7) <= '1' when s_digits = x"00000000" else '0';
   
end Behavioral;
