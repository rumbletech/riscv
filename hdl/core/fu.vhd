library IEEE;
library riscv_core;

use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use riscv_core.riscv_core_pkg.ALL;


entity fu is
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
        -- To Decode and Execute --
        rv_dec_data_valid_o : out std_logic := '0';
        rv_dec_data_o : out std_logic_vector(C_RV_DATA_WIDTH-1 downto 0):= ( others => '0' );
		-- Instruction Data Interface --
		rv_iif_valid_i : in std_logic := '0';
		rv_iif_data_i : in std_logic_vector(C_RV_DATA_WIDTH-1 downto 0):= ( others => '0' );
		-- Instruction Address Interface --
		rv_iif_addr_o : out std_logic_vector(C_RV_ADDR_WIDTH-1 downto 0):= ( others => '0' );
		rv_iif_valid_o : out std_logic := '0';
		
    );
end entity fu;

architecture rtl of fu is

signal pc_incr : std_logic := '0';
signal pc_load : std_logic := '0';
signal cnt_to_pc : std_logic_vector(C_RV_PC_WIDTH-1 downto 0) := ( others => '0' );
signal cnt_from_pc : std_logic_vector(C_RV_PC_WIDTH-1 downto 0) := ( others => '0' );
signal instr_rq_valid : std_logic := '0';

begin

rv_iif_addr_o <= cnt_from_pc;
rv_iif_valid_o <= instr_rq_valid;

pc_incr <= rv_iif_valid_i;

rv_dec_data_o <= rv_iif_data_i;
rv_dec_data_valid_o <= rv_iif_valid_i;

process ( clk ) is begin
    if ( clk'event and clk = '1' ) then
        if ( rst_n = '0' ) then 
            instr_rq_valid <= '1';
        else
            if ( rv_iif_valid_i = '1' ) then
                instr_rq_valid <= '1';
            else
                instr_rq_valid <= '0';
            end if;

        end if;
    end if;
end process;


u_pc : entity riscv_core.pc
		generic map (
			C_WIDTH => C_RV_PC_WIDTH,
			C_CNT_STEP => C_RV_PC_STEP_SIZE
		)
        port map (
			clk => clk,
			rst_n => rst_n,
			incr_i => pc_incr,
			pc_load_i => pc_load,
			pc_cnt_i => cnt_to_pc,
			pc_cnt_o => cnt_from_pc
        );
		
end architecture rtl;
