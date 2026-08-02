library IEEE;
library riscv_bus;

use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity wishbone_biu is
	generic ( 
		C_ADDR_WIDTH : positive := 32;
		C_DATA_WIDTH : positive := 32
	
	);
    port (
        clk : in  std_logic := '0';
        rst_n : in  std_logic := '0';
		-- Processor Interface ( Data )--
		rv_dif_data_i : in std_logic_vector(C_DATA_WIDTH-1 downto 0):= (others =>'0');
		rv_dif_data_o : out std_logic_vector(C_DATA_WIDTH-1 downto 0):= (others =>'0');
		rv_dif_addr_i : in std_logic_vector(C_ADDR_WIDTH-1 downto 0):= (others =>'0');
		rv_dif_wr_i : in std_logic := '0';
		rv_dif_be_i : in std_logic_vector(C_DATA_WIDTH/8-1 downto 0):= (others =>'0');
		rv_dif_valid_i : in std_logic := '0';
		rv_dif_ready_o : out std_logic := '0';
		-- Processor Interface ( Instructions ) --
		rv_iif_data_o : out std_logic_vector(C_DATA_WIDTH-1 downto 0):= (others =>'0');
		rv_iif_addr_i : in std_logic_vector(C_ADDR_WIDTH-1 downto 0):= (others =>'0');
		rv_iif_valid_i : in std_logic := '0';
		rv_iif_ready_o : out std_logic := '0';
		-- Master Wishbone Interface ( Instructions ) --
        wb_iif_adr_o : out std_logic_vector(C_ADDR_WIDTH-1 downto 0):= (others =>'0');
        wb_iif_dat_o : out std_logic_vector(C_DATA_WIDTH-1 downto 0):= (others =>'0');
        wb_iif_we_o  : out std_logic := '0';
        wb_iif_sel_o : out std_logic_vector(C_DATA_WIDTH/8-1 downto 0):= (others =>'0');
        wb_iif_cyc_o : out std_logic := '0';
        wb_iif_stb_o : out std_logic := '0';
        wb_iif_dat_i : in  std_logic_vector(C_DATA_WIDTH-1 downto 0):= (others =>'0');
        wb_iif_ack_i : in  std_logic := '0';
        wb_iif_err_i : in  std_logic := '0';
        wb_iif_rty_i : in  std_logic := '0';
		-- Master WishBone Interface ( Data ) --
        wb_dif_adr_o : out std_logic_vector(C_ADDR_WIDTH-1 downto 0):= (others =>'0');
        wb_dif_dat_o : out std_logic_vector(C_DATA_WIDTH-1 downto 0):= (others =>'0');
        wb_dif_we_o  : out std_logic := '0';
        wb_dif_sel_o : out std_logic_vector(C_DATA_WIDTH/8-1 downto 0):= (others =>'0');
        wb_dif_cyc_o : out std_logic := '0';
        wb_dif_stb_o : out std_logic := '0';
        wb_dif_dat_i : in  std_logic_vector(C_DATA_WIDTH-1 downto 0):= (others =>'0');
        wb_dif_ack_i : in  std_logic := '0';
        wb_dif_err_i : in  std_logic := '0';
        wb_dif_rty_i : in  std_logic := '0'
    );
end entity wishbone_biu;

architecture rtl of wishbone_biu is


begin



rv_iif_data_o <= wb_iif_dat_i;
rv_iif_ready_o <= wb_iif_ack_i;

wb_iif_adr_o <= rv_iif_addr_i;
wb_iif_dat_o <= wb_iif_dat_i;
wb_iif_we_o <= '0';
wb_iif_sel_o <= (wb_iif_sel_o'range => '1' );
wb_iif_cyc_o <= rv_iif_valid_i;
wb_iif_stb_o <= rv_iif_valid_i;


rv_dif_data_o <= wb_dif_dat_i;
rv_dif_ready_o <= wb_dif_ack_i;

wb_dif_adr_o <= rv_dif_addr_i;
wb_dif_dat_o <= rv_dif_data_i;
wb_dif_we_o <= rv_dif_wr_i;
wb_dif_sel_o <= rv_dif_be_i;
wb_dif_cyc_o <= rv_dif_valid_i;
wb_dif_stb_o <= rv_dif_valid_i;


		
end architecture rtl;
