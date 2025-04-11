library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_arith.all;
  use ieee.std_logic_unsigned.all;

entity inst_fetch is
  port (
    -- inputs
    clk                   : in  std_logic;
    branch_target_address : in  std_logic_vector(15 downto 0);
    jump_address          : in  std_logic_vector(15 downto 0);
    pc_en                 : in  std_logic;
    pc_reset              : in  std_logic;
    -- control signals
    jump                  : in  std_logic;
    pc_src                : in  std_logic;
    -- outputs
    instruction           : out std_logic_vector(15 downto 0);
    pc_plus_one           : out std_logic_vector(15 downto 0)
  );
end inst_fetch;

architecture Behavioral of inst_fetch is

signal s_pc_out : std_logic_vector(15 downto 0) := (others => '0');
signal s_mux_jump_out, s_adder_out, s_mux_branch_out, s_rom_data : std_logic_vector(15 downto 0) := (others => '0');

type t_rom is array (0 to 255) of std_logic_vector(15 downto 0);
signal s_rom : t_rom := (
    b"000_001_010_011_0_000", 
    b"000_110_100_010_0_001", 
    x"1234",                 
    x"abcd",                 
    x"1337",                
    x"d00d",                  
    others => (others => '1')
  );
begin

    D_FF: process(clk)
    begin
        if rising_edge(clk) then
            if pc_reset = '1' then
                s_pc_out <= (others => '0');
            elsif pc_en = '1' then
                s_pc_out <= s_mux_jump_out;
            end if;
         end if;
    end process;
    
    s_rom_data <= s_rom(conv_integer(s_pc_out(7 downto 0)));
    s_adder_out <= s_pc_out + 1;
    s_mux_branch_out <= s_adder_out when pc_src = '0' else  branch_target_address;
    s_mux_jump_out <= s_mux_branch_out when jump = '0' else jump_address;
    
    pc_plus_one <= s_adder_out;
    instruction <= s_rom_data;

end Behavioral;
