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
		rv_iif_data_i : in std_logic_vector(C_RV_DATA_WIDTH-1 downto 0):= ( others => '0' );
		rv_iif_addr_o : out std_logic_vector(C_RV_ADDR_WIDTH-1 downto 0):= ( others => '0' );
		rv_iif_valid_o : out std_logic := '0';
		rv_iif_ready_i : in std_logic := '0'	
    );
end entity riscv_top;

architecture rtl of riscv_top is

signal pc_halt : std_logic := '0';
signal pc_load : std_logic := '0';
signal cnt_to_pc : std_logic_vector(C_RV_PC_WIDTH-1 downto 0) := ( others => '0' );
signal cnt_from_pc : std_logic_vector(C_RV_PC_WIDTH-1 downto 0) := ( others => '0' );

begin


u_pc : entity riscv_core.pc
		generic map (
			C_WIDTH => C_RV_PC_WIDTH,
			C_CNT_STEP => C_RV_PC_STEP_SIZE
		)
        port map (
			clk => clk,
			rst_n => rst_n,
			halt_i => pc_halt,
			pc_load_i => pc_load,
			pc_cnt_i => cnt_to_pc,
			pc_cnt_o => cnt_from_pc
        );
		
end architecture rtl;
