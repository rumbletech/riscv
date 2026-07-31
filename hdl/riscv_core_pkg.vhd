--============================================================
-- Package Declaration
-- File    : riscv_core_pkg.vhd
-- Purpose : Common types, constants, functions, and procedures
--============================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package riscv_core_pkg is

constant C_RV_DATA_WIDTH : positive := 32;
constant C_RV_ADDR_WIDTH : positive := 32;
constant C_RV_PC_WIDTH : positive := 32;
constant C_RV_PC_STEP_SIZE : positive := 4;


end package riscv_core_pkg;

--============================================================
-- Package Body
--============================================================

package body riscv_core_pkg is



end package body riscv_core_pkg;
