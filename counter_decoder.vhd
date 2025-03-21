library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity register_file is
    Port ( clk : in STD_LOGIC;
           btn : in  std_logic_vector(4  downto 0);
           sw  : in  std_logic_vector(15 downto 0);
           led : out std_logic_vector(15 downto 0);
           an  : out std_logic_vector(7  downto 0);
           cat : out std_logic_vector(6  downto 0)
           );
end register_file;

architecture Behavioral of register_file is

signal en : STD_LOGIC_VECTOR(4 downto 0) := (others => '0');
signal cnt : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
signal s_digits : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
signal s_rd1, s_rd2 : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');

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

component reg_file is
     Port ( clk : in std_logic;
            ra1 : in std_logic_vector (3 downto 0);
            ra2 : in std_logic_vector (3 downto 0);
            wa : in std_logic_vector (3 downto 0);
            wd : in std_logic_vector (31 downto 0);
            wen : in std_logic;
            rd1 : out std_logic_vector (31 downto 0);
            rd2 : out std_logic_vector (31 downto 0)
            );
end component;

begin
    debounce: MPG port map (clk => clk, btn => btn, enable => en);
    display : seven_seg_disp port map (clk => clk, digits => s_digits, an => an, cat => cat);
    register_file: reg_file port map (clk => clk, ra1 => cnt, ra2 => cnt, wa => cnt, wd => s_digits, wen => en(3), rd1 => s_rd1, rd2 => s_rd2);
  
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
    
    process(s_rd1, s_rd2)
    begin
        s_digits <= s_rd1 + s_rd2;
    end process;

    led <= x"000" & cnt;
   
end Behavioral;
