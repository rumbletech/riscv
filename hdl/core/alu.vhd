library IEEE;
library riscv_core;

use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use riscv_core.riscv_core_pkg.ALL;


entity du is
    port (
        clk : in  std_logic := '0';
        rst_n : in  std_logic := '0';
		-- Operands --
		arg0_i : std_logic_vector(C_RV_DATA_WIDTH-1 downto 0) := ( others => '0' );
		arg1_i : std_logic_vector(C_RV_DATA_WIDTH-1 downto 0) := ( others => '0' );
		op_i : std_logic_vector(5 downto 0) := ( others => '0' );
		res_o : std_logic_vector(C_RV_DATA_WIDTH-1 downto 0) := ( others => '0' )
    );
end entity du;

architecture rtl of du is



begin


end architecture rtl;
