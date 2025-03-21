library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity random_access_memory is
    Port ( clk : in STD_LOGIC;
           btn : in  std_logic_vector(4  downto 0);
           sw  : in  std_logic_vector(15 downto 0);
           led : out std_logic_vector(15 downto 0);
           an  : out std_logic_vector(7  downto 0);
           cat : out std_logic_vector(6  downto 0)
           );
end random_access_memory;

architecture Behavioral of random_access_memory is

signal en : STD_LOGIC_VECTOR(4 downto 0) := (others => '0');
signal cnt : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
signal s_digits : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
signal s_do : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');

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

component ram is
     Port ( clk : in std_logic;
            we : in STD_LOGIC;
            addr : in std_logic_vector (3 downto 0);
            di : in STD_LOGIC_VECTOR (31 downto 0);
            do : out STD_LOGIC_VECTOR (31 downto 0)
            );
end component;

begin
    debounce: MPG port map (clk => clk, btn => btn, enable => en);
    display : seven_seg_disp port map (clk => clk, digits => s_digits, an => an, cat => cat);
    ram_memory: ram port map (clk => clk, we => en(1), addr => cnt, di => s_digits, do => s_do);
  
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
    
    process(s_do)
    begin
        s_digits <= s_do(29 downto 0) & "00";
    end process;

    led <= x"000" & cnt;
   
end Behavioral;
