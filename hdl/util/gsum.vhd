library IEEE;
library lib_riscv_util;


use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Generic Sum Op --

entity gsum is
    generic (
		C_OP_A_WIDTH : positive := 9; -- Operand A'length must be greater than or equal to operand B'length --
		C_OP_B_WIDTH : positive := 8
    );
    port (
		op_a_i : in std_logic_vector(C_OP_A_WIDTH-1 downto 0);
		op_b_i : in std_logic_vector(C_OP_B_WIDTH-1 downto 0);
		res_o : out std_logic_vector(C_OP_A_WIDTH downto 0)
    );
end entity gsum;

architecture rtl of gsum is

    signal op_b_ex : std_logic_vector(C_OP_A_WIDTH-1 downto 0) := ( others => '0' );
	signal carry : std_logic_vector(C_OP_A_WIDTH downto 0) := ( others => '0' );

begin

op_b_ex(C_OP_B_WIDTH-1 downto 0) <= op_b_i;

gen_op_b_ex : if C_OP_A_WIDTH > C_OP_B_WIDTH generate 
	op_b_ex(C_OP_A_WIDTH-1 downto C_OP_B_WIDTH ) <= ( others => '0' );
end generate;

carry(0) <= '0';

gen_fa : for i in 0 to C_OP_A_WIDTH-1 generate

u_fa_inst : entity lib_riscv_util.gfadder
        port map (
            a_i => op_a_i(i),
            b_i => op_b_ex(i),
            c_i => carry(i),
            s_o => res_o(i),
            c_o => carry(i+1)
        );

end generate gen_fa;


res_o(C_OP_A_WIDTH) <= carry(C_OP_A_WIDTH);
	
end architecture rtl;
