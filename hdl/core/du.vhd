library IEEE;
library riscv_core;

use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use riscv_core.riscv_core_pkg.ALL;


entity du is
    port (
        clk : in  std_logic := '0';
        rst_n : in  std_logic := '0';
		-- IFU Signals --
		instr_data_i : in std_logic_vector(C_RV_DATA_WIDTH-1 downto 0) := ( others => '0' );
		instr_valid_i : in std_logic := '0';
		-- DFU Signals --
		dfu_valid_o : out std_logic := '0';
		dfu_addr_muxsel_o : out std_logic_vector(C_RV_DATA_WIDTH-1 downto 0) := ( others => '0' );
		dfu_wr_o : out std_logic := '0';
		-- ALU Control Signals --
		alu_arg0_muxsel_o : out std_logic_vector(C_RV_DATA_WIDTH-1 downto 0) := ( others => '0' );
		alu_arg1_muxsel_o : out std_logic_vector(C_RV_DATA_WIDTH-1 downto 0) := ( others => '0' );
		alu_op_o : out std_logic_vector(C_ALU_OP_LEN-1 downto 0) := ( others => '0' );	
		-- RegisterFile Control Signals --
		rf_raddr0_o : out std_logic_vector(clog2(C_RV_NUM_REGISTERS)-1 downto 0) := ( others => '0' );
		rf_raddr1_o : out std_logic_vector(clog2(C_RV_NUM_REGISTERS)-1 downto 0) := ( others => '0' );
		rf_waddr_o : out std_logic_vector(clog2(C_RV_NUM_REGISTERS)-1 downto 0) := ( others => '0' );
		rf_wren_o : out std_logic := '0';
		rf_wr_muxsel_o : out std_logic_vector(C_RV_DATA_WIDTH-1 downto 0) := ( others => '0' )
    );
end entity du;

architecture rtl of du is

signal instr : std_logic_vector(C_RV_DATA_WIDTH-1 downto 0) := ( others => '0' );
signal alu_arg0_muxsel : std_logic_vector(C_RV_DATA_WIDTH-1 downto 0) := ( others => '0' );
signal alu_arg1_muxsel : std_logic_vector(C_RV_DATA_WIDTH-1 downto 0) := ( others => '0' );
signal alu_op : std_logic_vector(C_ALU_OP_LEN-1 downto 0) := ( others => '0' );	
signal rf_raddr0 : std_logic_vector(clog2(C_RV_NUM_REGISTERS)-1 downto 0) := ( others => '0' );
signal rf_raddr1 : std_logic_vector(clog2(C_RV_NUM_REGISTERS)-1 downto 0) := ( others => '0' );
signal rf_waddr : std_logic_vector(clog2(C_RV_NUM_REGISTERS)-1 downto 0) := ( others => '0' );
signal rf_wren : std_logic := '0'

begin

	instr <= instr_data_i;
	
	process( clk ) is begin 
		if ( clk'event and clk = '1' ) then 
			if ( rst_n = '0' ) then 
		
		
			else
				case instr(C_RV32I_OP_CODE_R'range) is 
				
				
				when C_RV32I_OP_IMM => 
					
					case instr(C_RV32I_FUNCT3_R) is
										
					when C_RV32I_FUNCT3_ADD =>
						alu_arg0_muxsel <= "000"; -- Select Immediate --
						alu_arg1_muxsel <= "001"; -- Select Register Operand 1 --
						
						rf_raddr0 <= "001"; -- Select the correct Register output to Register Operand 1 --
						
						rf_waddr <= "001"; -- selects RD destination reggy --
						rf_wren <= '1';
					
					
					when C_RV32I_FUNCT3_SLL =>
					when C_RV32I_FUNCT3_SLT =>
					when C_RV32I_FUNCT3_SLTU =>
					when C_RV32I_FUNCT3_XOR =>
					when C_RV32I_FUNCT3_SRL =>
					when C_RV32I_FUNCT3_OR =>
					when C_RV32I_FUNCT3_AND =>
						
						
						
						
						
					
					


end architecture rtl;
