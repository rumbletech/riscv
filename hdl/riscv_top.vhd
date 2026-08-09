library IEEE;
library riscv_core;

use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use riscv_core.riscv_core_pkg.ALL;


entity riscv_top is
    port (
        clk : in  std_logic := '0';
        rst_n : in  std_logic := '0';
		-- Processor Interface ( Instructions ) --
		-- Instruction Data Interface --
		rv_iif_valid_i : in std_logic := '0';
		rv_iif_data_i : in std_logic_vector(C_RV_DATA_WIDTH-1 downto 0):= ( others => '0' );
		-- Instruction Address Interface
		rv_iif_addr_o : out std_logic_vector(C_RV_ADDR_WIDTH-1 downto 0):= ( others => '0' );
		rv_iif_valid_o : out std_logic := '0'
    );
end entity riscv_top;

architecture rtl of riscv_top is

signal rv_dec_data_valid : std_logic := '0';
signal rv_dec_data : std_logic_vector(C_RV_DATA_WIDTH-1 downto 0):= ( others => '0' );


begin

inst_fetch : entity riscv_core.fu
 port map(
	clk => clk,
	rst_n => rst_n,
	rv_dec_data_valid_o => rv_dec_data_valid,
	rv_dec_data_o => rv_dec_data,
	rv_iif_valid_i => rv_iif_valid_i,
	rv_iif_data_i => rv_iif_data_i,
	rv_iif_addr_o => rv_iif_addr_o,
	rv_iif_valid_o => rv_iif_valid_o
);





end architecture rtl;
