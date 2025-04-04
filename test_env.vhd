library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity test_env is
    Port ( clk : in STD_LOGIC;
           btn : in  std_logic_vector(4  downto 0);
           sw  : in  std_logic_vector(15 downto 0);
           led : out std_logic_vector(15 downto 0);
           an  : out std_logic_vector(7  downto 0);
           cat : out std_logic_vector(6  downto 0)
           );
end test_env;

architecture Behavioral of test_env is

signal s_mpg_out : std_logic_vector(4 downto 0) := (others => '0');
signal s_digits : std_logic_vector(31 downto 0) := (others => '0');

component inst_fetch is
  port (
    -- inputs
    clk                   : in  std_logic;
    branch_target_address : in  std_logic_vector(15 downto 0);
    jump_address          : in  std_logic_vector(15 downto 0);
    pc_en                 : in  std_logic;
    pc_reset              : in  std_logic;
    -- control signals
    ctrl_jump             : in  std_logic;
    ctrl_pc_src           : in  std_logic;
    -- outputs
    instruction           : out std_logic_vector(15 downto 0);
    pc_plus_one           : out std_logic_vector(15 downto 0)
  );
end component;

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

    debounce: MPG port map (clk => clk, btn => btn, enable => s_mpg_out);
    display : seven_seg_disp port map (clk => clk, digits => s_digits, an => an, cat => cat);
    inst_infe : inst_fetch
    port map (
    clk                    => clk,
    branch_target_address  => x"0002",
    jump_address           => x"0000",
    ctrl_jump              => sw(0),
    ctrl_pc_src            => sw(1),
    pc_en                  => s_mpg_out(0),
    pc_reset               => s_mpg_out(1),
    instruction            => s_digits(15 downto 0),
    pc_plus_one            => s_digits(31 downto 16)
  );
    
  
end Behavioral;
