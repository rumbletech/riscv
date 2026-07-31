library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity riscv_top_tb is
-- Testbenches do not have ports
end entity riscv_top_tb;

architecture sim of riscv_top_tb is

    constant C_CLK_PERIOD      : time     := 10 ns; -- 100 MHz Clock

    -- Simulation Clock and Reset Signals
    signal clk   : std_logic := '0';
    signal rst_n : std_logic := '0';

    -- Native Processor Instruction Interface Wires
    signal rv_iif_data_s  : std_logic_vector(C_RV_DATA_WIDTH-1 downto 0);
    signal rv_iif_addr_s  : std_logic_vector(C_RV_ADDR_WIDTH-1 downto 0);
    signal rv_iif_valid_s : std_logic;
    signal rv_iif_ready_s : std_logic;

    -- Native Processor Data Interface Wires
    signal rv_dif_data_to_core   : std_logic_vector(C_RV_DATA_WIDTH-1 downto 0);
    signal rv_dif_data_from_core : std_logic_vector(C_RV_DATA_WIDTH-1 downto 0);
    signal rv_dif_addr_s         : std_logic_vector(C_RV_ADDR_WIDTH-1 downto 0);
    signal rv_dif_wr_s           : std_logic;
    signal rv_dif_be_in_s        : std_logic := '1'; -- Default dummy byte enable input
    signal rv_dif_be_out_s       : std_logic;
    signal rv_dif_valid_s        : std_logic;
    signal rv_dif_ready_s        : std_logic;

    -- Wishbone Instruction Bus Interface Wires
    signal wb_iif_adr : std_logic_vector(C_RV_ADDR_WIDTH-1 downto 0);
    signal wb_iif_dat_w : std_logic_vector(C_RV_DATA_WIDTH-1 downto 0);
    signal wb_iif_we  : std_logic;
    signal wb_iif_sel : std_logic_vector(C_RV_DATA_WIDTH/8-1 downto 0);
    signal wb_iif_cyc : std_logic;
    signal wb_iif_stb : std_logic;
    signal wb_iif_dat_r : std_logic_vector(C_RV_DATA_WIDTH-1 downto 0);
    signal wb_iif_ack : std_logic;
    signal wb_iif_err : std_logic := '0';
    signal wb_iif_rty : std_logic := '0';

    -- Wishbone Data Bus Interface Wires
    signal wb_dif_adr : std_logic_vector(C_RV_ADDR_WIDTH-1 downto 0);
    signal wb_dif_dat_w : std_logic_vector(C_RV_DATA_WIDTH-1 downto 0);
    signal wb_dif_we  : std_logic;
    signal wb_dif_sel : std_logic_vector(C_RV_DATA_WIDTH/8-1 downto 0);
    signal wb_dif_cyc : std_logic;
    signal wb_dif_stb : std_logic;
    signal wb_dif_dat_r : std_logic_vector(C_RV_DATA_WIDTH-1 downto 0);
    signal wb_dif_ack : std_logic;
    signal wb_dif_err : std_logic;
    signal wb_dif_rty : std_logic := '0';

    -- Fixed wrapper for the Byte-Enable vector needed by Wishbone
    signal biu_dif_be_vector : std_logic_vector(3 downto 0);
	
	signal sim_done : std_logic := '0'

begin

    uut_clk : process
    begin
		clk <= '0';
		wait for CLK_PERIOD / 2;
		clk <= '1';
		wait for CLK_PERIOD / 2;
    end process;



	uut_riscv : entity work.riscv_top
		port map (
			clk            => clk,
            rst_n          => rst_n,
            rv_dif_data_i  => rv_dif_data_to_core,
            rv_dif_data_o  => rv_dif_data_from_core,
            rv_dif_addr_o  => rv_dif_addr_s,
            rv_dif_wr_o    => rv_dif_wr_s,
            rv_dif_be_i    => rv_dif_be_in_s,
            rv_dif_be_o    => rv_dif_be_out_s,
            rv_dif_valid_o => rv_dif_valid_s,
            rv_dif_ready_i => rv_dif_ready_s,
            rv_iif_data_i  => rv_iif_data_s,
            rv_iif_addr_o  => rv_iif_addr_s,
            rv_iif_valid_o => rv_iif_valid_s,
            rv_iif_ready_i => rv_iif_ready_s
        );

    ---------------------------------------------------------------------
    -- UUT 2: Wishbone Bus Interface Unit (BIU)
    ---------------------------------------------------------------------
    uut_biu : entity work.wishbone_biu
        generic map (
            C_ADDR_WIDTH => C_RV_ADDR_WIDTH,
            C_DATA_WIDTH => C_RV_DATA_WIDTH
        )
        port map (
            clk            => clk,
            rst_n          => rst_n,
            
            -- Core Data Connections
            rv_dif_data_i  => rv_dif_data_from_core,
            rv_dif_data_o  => rv_dif_data_to_core,
            rv_dif_addr_i  => rv_dif_addr_s,
            rv_dif_wr_i    => rv_dif_wr_s,
            rv_dif_be_i    => biu_dif_be_vector,
            rv_dif_valid_i => rv_dif_valid_s,
            rv_dif_ready_o => rv_dif_ready_s,
            
            -- Core Instruction Connections
            rv_iif_data_o  => rv_iif_data_s,
            rv_iif_addr_i  => rv_iif_addr_s,
            rv_iif_valid_i => rv_iif_valid_s,
            rv_iif_ready_o => rv_iif_ready_s,
            
            -- Master Wishbone Interface (Instructions)
            wb_iif_adr_o   => wb_iif_adr,
            wb_iif_dat_o   => wb_iif_dat_w,
            wb_iif_we_o    => wb_iif_we,
            wb_iif_sel_o   => wb_iif_sel,
            wb_iif_cyc_o   => wb_iif_cyc,
            wb_iif_stb_o   => wb_iif_stb,
            wb_iif_dat_i   => wb_iif_dat_r,
            wb_iif_ack_i   => wb_iif_ack,
            wb_iif_err_i   => wb_iif_err,
            wb_iif_rty_i   => wb_iif_rty,
            
            -- Master Wishbone Interface (Data)
            wb_dif_adr_o   => wb_dif_adr,
            wb_dif_dat_o   => wb_dif_dat_w,
            wb_dif_we_o    => wb_dif_we,
            wb_dif_sel_o   => wb_dif_sel,
            wb_dif_cyc_o   => wb_dif_cyc,
            wb_dif_stb_o   => wb_dif_stb,
            wb_dif_dat_i   => wb_dif_dat_r,
            wb_dif_ack_i   => wb_dif_ack,
            wb_dif_err_i   => wb_dif_err,
            wb_dif_rty_i   => wb_dif_rty
        );

    ---------------------------------------------------------------------
    -- UUT 3: Dual-Port Wishbone Block RAM Model
    ---------------------------------------------------------------------
    uut_memory : entity work.wishbone_dual_port_ram
        generic map (
            C_ADDR_WIDTH => C_RV_ADDR_WIDTH,
            C_DATA_WIDTH => C_RV_DATA_WIDTH,
            C_RAM_DEPTH  => 1024,
            C_INIT_FILE  => "memory_init.txt"
        )
        port map (
            clk          => clk,
            rst_n        => rst_n,
            
            -- Memory Instruction Port (Slave A)
            wb_iif_adr_i => wb_iif_adr,
            wb_iif_dat_i => wb_iif_dat_w,
            wb_iif_we_i  => wb_iif_we,
            wb_iif_sel_i => wb_iif_sel,
            wb_iif_cyc_i => wb_iif_cyc,
            wb_iif_stb_i => wb_iif_stb,
            wb_iif_dat_o => wb_iif_dat_r,
            wb_iif_ack_o => wb_iif_ack,
            
            -- Memory Data Port (Slave B)
            wb_dif_adr_i => wb_dif_adr,
            wb_dif_dat_i => wb_dif_dat_w,
            wb_dif_we_i  => wb_dif_we,
            wb_dif_sel_i => wb_dif_sel,
            wb_dif_cyc_i => wb_dif_cyc,
            wb_dif_stb_i => wb_dif_stb,
            wb_dif_dat_o => wb_dif_dat_r,
            wb_dif_ack_o => wb_dif_ack,
            wb_dif_err_o => wb_dif_err
        );

end architecture sim;
