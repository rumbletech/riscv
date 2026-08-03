library IEEE;
library riscv_tb;
library riscv_core;
library riscv_bus;
library riscv_mem;


use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use riscv_core.riscv_core_pkg.ALL;


entity riscv_top_tb is
-- Testbenches do not have ports
end entity riscv_top_tb;

architecture sim of riscv_top_tb is

    constant C_CLK_PERIOD      : time     := 10 ns; -- 100 MHz Clock

    -- Simulation Clock and Reset Signals
    signal clk   : std_logic := '0';
    signal rst_n : std_logic := '0';

    -- Native Processor Instruction Interface Wires
    signal rv_iif_data_s  : std_logic_vector(C_RV_DATA_WIDTH-1 downto 0) := ( others => '0' );
    signal rv_iif_addr_s  : std_logic_vector(C_RV_ADDR_WIDTH-1 downto 0):= ( others => '0' );
    signal rv_iif_rq_valid_s : std_logic := '0';
    signal rv_iif_rp_valid_s : std_logic := '0';

    -- Wishbone Instruction Bus Interface Wires
    signal wb_iif_adr : std_logic_vector(C_RV_ADDR_WIDTH-1 downto 0):= ( others => '0' );
    signal wb_iif_dat_w : std_logic_vector(C_RV_DATA_WIDTH-1 downto 0):= ( others => '0' );
    signal wb_iif_we  : std_logic := '0';
    signal wb_iif_sel : std_logic_vector(C_RV_DATA_WIDTH/8-1 downto 0):= ( others => '0' );
    signal wb_iif_cyc : std_logic := '0';
    signal wb_iif_stb : std_logic := '0';
    signal wb_iif_dat_r : std_logic_vector(C_RV_DATA_WIDTH-1 downto 0):= ( others => '0' );
    signal wb_iif_ack : std_logic := '0';
    signal wb_iif_err : std_logic := '0';
    signal wb_iif_rty : std_logic := '0';

    signal mem_pa_data_i : std_logic_vector(C_RV_DATA_WIDTH-1 downto 0):= ( others => '0' );
    signal mem_pa_addr : std_logic_vector(C_RV_ADDR_WIDTH-1 downto 0):= ( others => '0' );
    signal mem_pa_we : std_logic := '0';
    signal mem_pa_data_o : std_logic_vector(C_RV_DATA_WIDTH-1 downto 0):= ( others => '0' );

begin

    uut_clk : process
    begin
		clk <= '0';
		wait for C_CLK_PERIOD / 2;
		clk <= '1';
		wait for C_CLK_PERIOD / 2;
    end process;

	uut_riscv : entity riscv_core.riscv_top
		port map (
			clk            => clk,
            rst_n          => rst_n,
            rv_iif_data_i  => rv_iif_data_s,
            rv_iif_addr_o  => rv_iif_addr_s,
            rv_iif_valid_o => rv_iif_rq_valid_s,
            rv_iif_valid_i => rv_iif_rp_valid_s
        );

    ---------------------------------------------------------------------
    -- UUT 2: Wishbone Bus Interface Unit (BIU)
    ---------------------------------------------------------------------
    uut_biu : entity riscv_bus.wishbone_biu
        generic map (
            C_ADDR_WIDTH => C_RV_ADDR_WIDTH,
            C_DATA_WIDTH => C_RV_DATA_WIDTH
        )
        port map (
            clk            => clk,
            rst_n          => rst_n,
                      
            -- Core Instruction Connections
            rv_iif_data_o  => rv_iif_data_s,
            rv_iif_addr_i  => rv_iif_addr_s,
            rv_iif_valid_i => rv_iif_rq_valid_s,
            rv_iif_valid_o => rv_iif_rp_valid_s,
            
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
            wb_iif_rty_i   => wb_iif_rty
        );
    ---------------------------------------------------------------------
    -- UUT 3: Memory Controller
    ---------------------------------------------------------------------
    uut_mem_ctrl: entity riscv_mem.mem_ctrl  
    generic map(
        C_READ_LATENCY => 1,
        C_WRITE_LATENCY => 1,
        C_ADDR_WIDTH => C_RV_ADDR_WIDTH,
        C_DATA_WIDTH => C_RV_DATA_WIDTH
    )
    port map (
        clk => clk,
        rst_n => rst_n,
	-- Slave Wishbone Interface --
        wb_adr_i => wb_iif_adr,
        wb_dat_i => wb_iif_dat_w,
        wb_we_i => wb_iif_we,
        wb_sel_i => wb_iif_sel,
        wb_cyc_i => wb_iif_cyc,
        wb_stb_i => wb_iif_stb,
        wb_dat_o => wb_iif_dat_r,
        wb_ack_o => wb_iif_ack,
        wb_err_o => wb_iif_err,
        wb_rty_o => wb_iif_rty,
    -- Dual Port Interface --
        pa_addr_o => mem_pa_addr,
        pa_we_o => mem_pa_we,
        pa_data_o => mem_pa_data_i,
        pa_data_i => mem_pa_data_o
);


    ---------------------------------------------------------------------
    -- UUT 4: Dual-Port Wishbone Block RAM Model
    ---------------------------------------------------------------------
    uut_memory : entity riscv_tb.wishbone_dual_port_ram
     generic map(
        C_READ_LATENCY => 1,
        C_WRITE_LATENCY => 1,
        C_ADDR_WIDTH => 32,
        C_DATA_WIDTH => 32,
        C_RAM_DEPTH => 2048,
        C_INIT_FILE => "memory_init.txt"
    )
     port map(
        clk => clk,
        rst_n => rst_n,
        PA_DATA_I => mem_pa_data_i,
        PA_DATA_O => mem_pa_data_o,
        PA_ADDR_I => mem_pa_addr,
        PA_WE_I => mem_pa_we,
        PB_DATA_I => ( others => '0'),
        PB_DATA_O => open,
        PB_ADDR_I => ( others => '0'),
        PB_WE_I => '0'
    );
        
stim_proc : process is


    procedure proc_reset is
    begin
        rst_n <= '0';
        for i in 1 to 50 loop
            wait until rising_edge(clk);
        end loop;
        rst_n <= '1';        
    end procedure;

begin

    proc_reset;
    wait;
end process;        

end architecture sim;
