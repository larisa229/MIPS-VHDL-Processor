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

-- 7-segment display
signal s_digits       : std_logic_vector(31 downto 0) := (others => '0');
signal s_digits_upper : std_logic_vector(15 downto 0) := (others => '0');
signal s_digits_lower : std_logic_vector(15 downto 0) := (others => '0');
  
-- instruction fetch
signal s_if_in_jump_address : std_logic_vector(15 downto 0) := x"0000";
signal s_if_out_instruction : std_logic_vector(15 downto 0) := x"0000";
signal s_if_out_pc_plus_one : std_logic_vector(15 downto 0) := x"0000";

-- main control
signal s_ctrl_reg_dst    : std_logic                    := '0';
signal s_ctrl_ext_op     : std_logic                    := '0';
signal s_ctrl_alu_src    : std_logic                    := '0';
signal s_ctrl_branch     : std_logic                    := '0';
signal s_ctrl_jump       : std_logic                    := '0';
signal s_ctrl_alu_op     : std_logic_vector(2 downto 0) := b"000";
signal s_ctrl_mem_write  : std_logic                    := '0';
signal s_ctrl_mem_to_reg : std_logic                    := '0';
signal s_ctrl_reg_write  : std_logic                    := '0';

-- instruction decode
signal s_id_in_reg_write : std_logic                     := '0';
signal s_id_in_wd        : std_logic_vector(15 downto 0) := x"0000";
signal s_id_out_ext_imm  : std_logic_vector(15 downto 0) := x"0000";
signal s_id_out_func     : std_logic_vector(2  downto 0) := b"000";
signal s_id_out_rd1      : std_logic_vector(15 downto 0) := x"0000";
signal s_id_out_rd2      : std_logic_vector(15 downto 0) := x"0000";
signal s_id_out_sa       : std_logic                     := '0';

-- execution unit
signal s_eu_out_alu_res : std_logic_vector(15 downto 0) := x"0000";
signal s_eu_out_bta     : std_logic_vector(15 downto 0) := x"0000";
signal s_eu_out_zero    : std_logic                     := '0';

-- memory unit
signal s_mu_in_mem_write : std_logic                     := '0';
signal s_mu_out_mem_data : std_logic_vector(15 downto 0) := x"0000";
signal s_mu_out_alu_res  : std_logic_vector(15 downto 0) := x"0000";

-- write back unit
signal s_wb_out_wd : std_logic_vector(15 downto 0) := x"0000";

signal s_branch : std_logic := '0';

-- registers
signal p_if_id : std_logic_vector(32 downto 0) := (others => '0');
signal p_id_ex : std_logic_vector(82 downto 0) := (others => '0');
-- 0-2 - rd: p_if_id(6 downto 4)
-- 3-5 - rt: p_if_id(9 downto 7)
-- 6-8 - func: p_if_id(2 downto 0)
-- 9 - sa: p_if_id(3)
-- 10-25 - ext_imm: s_id_out_ext_imm
-- 26-41 - rd2: s_id_out_rd2
-- 42-57 - rd2: s_id_out_rd1
-- 58-73 - pc+1: p_if_id(31 downrto 16)
-- 74 - regdst
-- 75 - alusrc
-- 76-78 - aluop
-- 79 - branch
-- 80 - memWrite
-- 81 - regWrite
-- 82 - memToReg

signal p_mu_wb : std_logic_vector(35 downto 0) := (others => '0');
-- 0-2 - mux_out: p_ex_mu(2 downto 0)
-- 3-18 - aluRes: p_ex_mu(34 downto 19)
-- 19-34 - memData: s_mu_out_mem_data
-- 35 - regWrite: p_ex_mu(54)
-- 36 - memToReg: p_ex_mu(55)

signal p_ex_mu : std_logic_vector(55 downto 0) := (others => '0');
-- 0-2 - rt or rd: s_mux_out_reg
-- 3-18 - rd2: p_id_ex(57 downto 42)
-- 19-34 - aluRes: s_eu_out_alu_res
-- 35 - zero: s_eu_out_zero
-- 36-51 - branch target address: s_eu_out_bta
-- 52 - branch: p_id_ex(79)
-- 53 - memWrite: p_id_ex(80)
-- 54 - regWrite: p_id_ex(81)
-- 55 - memToReg: p_id_ex(82)

signal s_mux_out_reg : std_logic_vector(2 downto 0) := (others => '0');

component inst_fetch is
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
end component;

component instr_decode is
  port (
    -- inputs
    clk       : in  std_logic;
    instr     : in  std_logic_vector(15 downto 0);
    wd        : in  std_logic_vector(15 downto 0);
    -- control signal based inputs
    ext_op    : in  std_logic;
    reg_dst   : in  std_logic;
    reg_write : in  std_logic;
    -- outputs
    ext_imm   : out std_logic_vector(15 downto 0);
    func      : out std_logic_vector(2  downto 0);
    rd1       : out std_logic_vector(15 downto 0);
    rd2       : out std_logic_vector(15 downto 0);        
    sa        : out std_logic
  );
end component;

component control_unit is
  port (
    -- inputs
    op_code : in std_logic_vector(2 downto 0);
    -- outputs
    reg_dst    : out std_logic;
    ext_op     : out std_logic;
    alu_src    : out std_logic;
    branch     : out std_logic;
    jump       : out std_logic;
    alu_op     : out std_logic_vector(2 downto 0);
    mem_write  : out std_logic;
    mem_to_reg : out std_logic;
    reg_write  : out std_logic 
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

component exec_unit
  port (
    ext_imm     : in  std_logic_vector(15 downto 0);
    func        : in  std_logic_vector(2  downto 0);
    rd1         : in  std_logic_vector(15 downto 0);
    rd2         : in  std_logic_vector(15 downto 0);
    pc_plus_one : in  std_logic_vector(15 downto 0);
    sa          : in  std_logic;
    alu_op      : in  std_logic_vector(2  downto 0);
    alu_src     : in  std_logic;
    alu_res     : out std_logic_vector(15 downto 0);
    bta         : out std_logic_vector(15 downto 0);
    zero        : out std_logic
  );
  end component;
  
component mem_unit is
port (
    -- inputs
    clk          : in std_logic;
    mem_write    : in std_logic;
    alu_res_in   : in std_logic_vector(15  downto 0);
    rd2          : in std_logic_vector(15 downto 0);        
    -- outputs
    mem_data      : out std_logic_vector(15 downto 0);
    alu_res_out   : out std_logic_vector(15 downto 0)
  );
end component;

begin

    debounce: MPG port map (clk => clk, btn => btn, enable => s_mpg_out);
    display : seven_seg_disp port map (clk => clk, digits => s_digits, an => an, cat => cat);
    inst_infe : inst_fetch
    port map (
    clk                    => clk,
    branch_target_address  => p_ex_mu(51 downto 36),
    jump_address           => s_if_in_jump_address,
    jump                   => s_ctrl_jump,
    pc_src                 => s_branch,
    pc_en                  => s_mpg_out(0),
    pc_reset               => s_mpg_out(1),
    instruction            => s_if_out_instruction,
    pc_plus_one            => s_if_out_pc_plus_one
  );
    
    inst_indcd : instr_decode
    port map (
    clk       => clk,
    instr     => p_if_id(15 downto 0),
    wd        => s_id_in_wd,
    ext_op    => s_ctrl_ext_op,
    reg_dst   => s_ctrl_reg_dst,
    reg_write => p_mu_wb(35),
    ext_imm   => s_id_out_ext_imm,
    func      => s_id_out_func,
    rd1       => s_id_out_rd1,
    rd2       => s_id_out_rd2,
    sa        => s_id_out_sa
  );
  
   inst_cu : control_unit
   port map (
    op_code    => p_if_id(15 downto 13),
    reg_dst    => s_ctrl_reg_dst,
    ext_op     => s_ctrl_ext_op,
    alu_src    => s_ctrl_alu_src,
    branch     => s_ctrl_branch,
    jump       => s_ctrl_jump,
    alu_op     => s_ctrl_alu_op,
    mem_write  => s_ctrl_mem_write,
    mem_to_reg => s_ctrl_mem_to_reg,
    reg_write  => s_ctrl_reg_write
  );
  
  inst_eu : exec_unit
  port map (
    ext_imm     => p_id_ex(25 downto 10),
    func        => p_id_ex(8 downto 6),
    rd1         => p_id_ex(57 downto 42),
    rd2         => p_id_ex(41 downto 26),
    pc_plus_one => p_id_ex(73 downto 58),
    sa          => p_id_ex(9),
    alu_op      => p_id_ex(78 downto 76),
    alu_src     => p_id_ex(75),
    alu_res     => s_eu_out_alu_res,
    bta         => s_eu_out_bta,
    zero        => s_eu_out_zero
  );
  
  inst_mu : mem_unit 
  port map (
  clk => clk, 
  mem_write => p_ex_mu(53), 
  alu_res_in => p_ex_mu(34 downto 19), 
  rd2 => p_ex_mu(18 downto 3), 
  mem_data => s_mu_out_mem_data, 
  alu_res_out => s_mu_out_alu_res);
  
  reg_if_id : process(clk)
  begin
    if rising_edge(clk) then
        if s_mpg_out(0) = '1' then
            p_if_id <= s_if_out_pc_plus_one & s_if_out_instruction;
        end if;
    end if;
  end process;
  
  reg_id_ex : process(clk)
  begin
    if rising_edge(clk) then
        if s_mpg_out(0) = '1' then
            p_id_ex <= s_ctrl_mem_to_reg & s_ctrl_reg_write & s_ctrl_mem_write & s_ctrl_branch
            & s_ctrl_alu_op & s_ctrl_alu_src & s_ctrl_reg_dst & p_if_id(31 downto 16) 
            & s_id_out_rd1 & s_id_out_rd2 & s_id_out_ext_imm & p_if_id(3) & p_if_id(2 downto 0) & p_if_id(9 downto 7)
            & p_if_id(6 downto 4);
        end if;
    end if;
  end process;
  
  reg_ex_mu : process(clk)
  begin
    if rising_edge(clk) then
        if s_mpg_out(0) = '1' then
            p_ex_mu <= p_id_ex(82 downto 79) & s_eu_out_bta & s_eu_out_zero &
                 s_eu_out_alu_res & p_id_ex(57 downto 42) & s_mux_out_reg;
        end if;
    end if;
  end process;
  
  reg_mu_wb : process(clk)
  begin
    if rising_edge(clk) then
        if s_mpg_out(0) = '1' then
        p_mu_wb <= p_ex_mu(55) & p_ex_mu(54) &  
                 s_mu_out_mem_data & p_ex_mu(34 downto 19) & p_ex_mu(2 downto 0);
        end if;
    end if;
    end process;

  
  process (sw(11 downto 9), s_if_out_pc_plus_one, s_if_out_instruction, s_id_out_rd1, s_id_out_rd2, s_id_in_wd)
  begin
    case sw(11 downto 9) is
      when "000"  => s_digits_upper <= p_if_id(15 downto 0);
      when "001"  => s_digits_upper <= p_if_id(31 downto 16);
      when "010"  => s_digits_upper <= s_id_out_rd1;
      when "011"  => s_digits_upper <= s_id_out_rd2;
      when "100"  => s_digits_upper <= s_id_out_ext_imm;
      when "101"  => s_digits_upper <= s_eu_out_alu_res;
      when "110"  => s_digits_upper <= s_mu_out_mem_data;
      when "111"  => s_digits_upper <= s_wb_out_wd;
    end case;
  end process;

  -- MUX for 7-segment display right side (15 downto 0)
  process (sw(6 downto 4), s_if_out_pc_plus_one, s_if_out_instruction, s_id_out_rd1, s_id_out_rd2, s_id_in_wd)
  begin
    case sw(6 downto 4) is
     when "000"  => s_digits_lower <= p_if_id(15 downto 0);
      when "001"  => s_digits_lower <= p_if_id(31 downto 16);
      when "010"  => s_digits_lower <= s_id_out_rd1;
      when "011"  => s_digits_lower <= s_id_out_rd2;
      when "100"  => s_digits_lower <= s_id_out_ext_imm;
      when "101"  => s_digits_lower <= s_eu_out_alu_res;
      when "110"  => s_digits_lower <= s_mu_out_mem_data;
      when "111"  => s_digits_lower <= s_wb_out_wd;
    end case;
  end process;

  s_digits <= s_digits_upper & s_digits_lower;
  s_branch <= p_ex_mu(52) and p_ex_mu(35);

  -- LED with signals from Main Control Unit
  led <= s_ctrl_alu_op     & 
         b"0000_0"         & -- Unused               12:8
         s_ctrl_reg_dst    & -- Register destination 7
         s_ctrl_ext_op     & -- Extend operation     6
         s_ctrl_alu_src    & -- ALU source           5
         s_ctrl_branch     & -- Branch               4
         s_ctrl_jump       & -- Jump                 3
         s_ctrl_mem_write  & -- Memory write         2
         s_ctrl_mem_to_reg & -- Memory to register   1
         s_ctrl_reg_write;   -- Register write       0
  
  s_id_in_reg_write <= s_mpg_out(0) and s_ctrl_reg_write;
  s_mu_in_mem_write <= s_ctrl_mem_write and s_mpg_out(0);
  s_wb_out_wd <= p_mu_wb(34 downto 19) when p_mu_wb(36) = '1' else p_mu_wb(18 downto 3);
  s_if_in_jump_address <= x"00" & p_if_id(7 downto 0);
  s_id_in_wd <= s_wb_out_wd;
  s_mux_out_reg <= p_id_ex(2 downto 0) when p_id_ex(75) = '1' else p_id_ex(5 downto 3);
 
end Behavioral;
