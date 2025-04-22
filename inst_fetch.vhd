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
    -- R-Type Instructions
    b"000_001_010_011_0_000", -- add r3, r1, r2
    b"000_110_100_010_0_001", -- sub r2, r6, r4
    b"000_000_001_010_1_010", -- sll r2, r0, r1
    b"000_011_100_101_1_011", -- srl r5, r3, r4
    b"000_010_001_110_0_100", -- and r6, r2, r1
    b"000_100_101_111_0_101", -- or r7, r4, r5
    b"000_111_110_000_0_110", -- xor r0, r7, r6
    b"000_011_010_001_1_111", -- sra r1, r3, r2

    -- I-Type Instructions
    b"000_001_010_001_000_0", -- addi r2, r1, #8
    b"001_010_011_000_100_1", -- lw r3, r2, #9
    b"010_011_100_000_110_0", -- sw r4, r3, #12
    b"011_100_101_000_000_1", -- beq r4, r5, #1
    b"100_110_111_000_011_1", -- andi r7, r6, #7
    b"101_000_001_000_010_0", -- bne r0, r1, #4

    -- J-Type Instruction
    b"111_0000000000011",     -- j #3 (jump to address 3)

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
