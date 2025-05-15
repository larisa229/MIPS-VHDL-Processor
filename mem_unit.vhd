library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_arith.all;
  use ieee.std_logic_unsigned.all;
  
entity mem_unit is
port (
    -- inputs
    clk         : in std_logic;
    mem_write   : in std_logic;
    alu_res     : in std_logic_vector(15  downto 0);
    rd2         : in std_logic_vector(15 downto 0);        
    -- outputs
    mem_data      : out std_logic_vector(15 downto 0);
    alu_res_out   : out std_logic_vector(15 downto 0)
  );
end mem_unit;

architecture Behavioral of mem_unit is

component ram is
     Port ( clk  : in std_logic;
            wen  : in STD_LOGIC;
            addr : in std_logic_vector (3 downto 0);
            di   : in STD_LOGIC_VECTOR (15 downto 0);
            do   : out STD_LOGIC_VECTOR (15 downto 0)
            );
end component;

begin
    inst_ram: ram port map (clk => clk, wen => mem_write, addr => alu_res, di => rd2, do => mem_data);
    alu_res_out <= alu_res;

end Behavioral;
