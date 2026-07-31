library IEEE;
library riscv_utils;

use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Program Counter --

entity pc is
    generic (
		C_WIDTH : positive := 8;
		C_CNT_STEP : positive := 4 
    );
    port (
        clk : in  std_logic;
        rst_n : in  std_logic;
		halt_i : in std_logic;
		pc_load_i : in std_logic;
		pc_cnt_i : in std_logic_vector(C_WIDTH-1 downto 0);
		pc_cnt_o : out std_logic_vector(C_WIDTH-1 downto 0)
    );
end entity pc;

architecture rtl of pc is

signal cnt_ovf : std_logic := '0';
signal cnt_en : std_logic := '0';
	

begin
	
cnt_en <= not halt_i;

u_gcounter_inst : entity riscv_utils.gcounter
		generic map (
			C_WIDTH => C_WIDTH,
			C_CNT_STEP => C_CNT_STEP
		)
        port map (
			clk => clk,
			rst_n => rst_n,
			cnt_i => pc_cnt_i,
			load_i => pc_load_i,
			incr_i => cnt_en,	
			cnt_o => pc_cnt_o,
			ovf_o => cnt_ovf
        );
		
end architecture rtl;
