library IEEE;
library riscv_core;

use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use riscv_core.riscv_core_pkg.ALL;


entity riscv_top is
    port (
        clk : in  std_logic := '0';
        rst_n : in  std_logic := '0';
		-- Processor Interface ( Data )--
		rv_dif_data_i : in std_logic_vector(C_RV_DATA_WIDTH-1 downto 0):= ( others => '0' );
		rv_dif_data_o : out std_logic_vector(C_RV_DATA_WIDTH-1 downto 0):= ( others => '0' );
		rv_dif_addr_o : out std_logic_vector(C_RV_ADDR_WIDTH-1 downto 0):= ( others => '0' );
		rv_dif_wr_o : out std_logic := '0';
		rv_dif_be_i : in std_logic := '0';
		rv_dif_be_o : out std_logic := '0';
		rv_dif_valid_o : out std_logic := '0';
		rv_dif_ready_i : in std_logic := '0';
		-- Processor Interface ( Instructions ) --
		-- Instruction Data Interface --
		rv_iif_valid_i : in std_logic := '0';
		rv_iif_ready_o : out std_logic := '0';
		rv_iif_data_i : in std_logic_vector(C_RV_DATA_WIDTH-1 downto 0):= ( others => '0' );
		-- Instruction Address Interface
		rv_iif_addr_o : out std_logic_vector(C_RV_ADDR_WIDTH-1 downto 0):= ( others => '0' );
		rv_iif_valid_o : out std_logic := '0';
		rv_iif_ready_i : in std_logic := '0';
		
    );
end entity riscv_top;

architecture rtl of riscv_top is


begin



fu_inst: entity riscv_core.fu
 port map(
	clk => clk,
	rst_n => rst_n,
	rv_dif_data_i => rv_dif_data_i,
	rv_dif_data_o => rv_dif_data_o,
	rv_dif_addr_o => rv_dif_addr_o,
	rv_dif_wr_o => rv_dif_wr_o,
	rv_dif_be_i => rv_dif_be_i,
	rv_dif_be_o => rv_dif_be_o,
	rv_dif_valid_o => rv_dif_valid_o,
	rv_dif_ready_i => rv_dif_ready_i,
	rv_iif_valid_i => rv_iif_valid_i,
	rv_iif_ready_o => rv_iif_ready_o,
	rv_iif_data_i => rv_iif_data_i,
	rv_iif_addr_o => rv_iif_addr_o,
	rv_iif_valid_o => rv_iif_valid_o,
	rv_iif_ready_i => rv_iif_ready_i
);



end architecture rtl;
