--============================================================
-- Package Declaration
-- File    : riscv_core_pkg.vhd
-- Purpose : Common types, constants, functions, and procedures
--============================================================

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

package riscv_core_pkg is

constant C_RV_DATA_WIDTH : positive := 32;
constant C_RV_ADDR_WIDTH : positive := 32;
constant C_RV_PC_WIDTH : positive := 32;
constant C_RV_PC_STEP_SIZE : positive := 4;

constant C_RV_NUM_REGISTERS : positive := 32;
constant C_ALU_OP_LEN : positive := 5;


constant C_RV32I_OP_CODE_R : std_logic_vector(6 downto 0) := "0000000";
constant C_RV32I_OP_CODE_RN : std_logic_vector(6 downto 0) := "0000000";

constant C_RV32I_FUNCT3_R : std_logic_vector(14 downto 12) := "000";
constant C_RV32I_FUNCT3_RN : std_logic_vector(2 downto 0) := "000";



constant C_RV32I_FUNCT3_ADD : std_logic_vector(2 downto 0) := "000";
constant C_RV32I_FUNCT3_SLL : std_logic_vector(2 downto 0) := "001";
constant C_RV32I_FUNCT3_SLT : std_logic_vector(2 downto 0) := "010";
constant C_RV32I_FUNCT3_SLTU : std_logic_vector(2 downto 0) := "011";
constant C_RV32I_FUNCT3_XOR : std_logic_vector(2 downto 0) := "101";
constant C_RV32I_FUNCT3_SRL : std_logic_vector(2 downto 0) := "101";
constant C_RV32I_FUNCT3_OR : std_logic_vector(2 downto 0) := "110";
constant C_RV32I_FUNCT3_AND : std_logic_vector(2 downto 0) := "111";

constant C_RV32I_OP_IMM : std_logic_vector(6 downto 0) := "0010011";



end package riscv_core_pkg;

--============================================================
-- Package Body
--============================================================

package body riscv_core_pkg is

function clog2(n : positive) return natural is
    variable v : natural := n - 1;
    variable r : natural := 0;
begin
    while v > 0 loop
        v := v / 2;
        r := r + 1;
    end loop;
    return r;
end function;

function or_reduce(input : std_logic_vector) return std_logic is
    variable result : std_logic := '0';
begin
    for i in 0 to input'high loop
		result := result or input(i);
    end loop;
    return result;
end function;



end package body riscv_core_pkg;
