library IEEE;
library riscv_mem;

use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity mem_ctrl is 
generic (
    C_READ_LATENCY : integer := 1;
    C_WRITE_LATENCY : integer := 1;
    C_ADDR_WIDTH : positive := 32;
    C_DATA_WIDTH : positive := 32
);
port (
    clk : in std_logic;
    rst_n : in std_logic;
	-- Slave Wishbone Interface --
    wb_adr_i : in std_logic_vector(C_ADDR_WIDTH-1 downto 0):= (others =>'0');
    wb_dat_i : in std_logic_vector(C_DATA_WIDTH-1 downto 0):= (others =>'0');
    wb_we_i  : in std_logic := '0';
    wb_sel_i : in std_logic_vector(C_DATA_WIDTH/8-1 downto 0):= (others =>'0');
    wb_cyc_i : in std_logic := '0';
    wb_stb_i : in std_logic := '0';
    wb_dat_o : out  std_logic_vector(C_DATA_WIDTH-1 downto 0):= (others =>'0');
    wb_ack_o : out  std_logic := '0';
    wb_err_o : out  std_logic := '0';
    wb_rty_o : out  std_logic := '0';
    -- Dual Port Interface --
    -- Port A --
    pa_addr_o : out std_logic_vector(C_ADDR_WIDTH-1 downto 0):= (others =>'0');
    pa_we_o : out std_logic := '0';
    pa_data_o : out std_logic_vector(C_DATA_WIDTH-1 downto 0):= (others =>'0');
    pa_data_i : in std_logic_vector(C_DATA_WIDTH-1 downto 0):= (others =>'0')
);
end entity mem_ctrl;



architecture rtl of mem_ctrl is 


type pstate is (IDLE, WAIT_LATENCY);

signal pa_mem_lat_r : integer := 0;
signal pa_state_r : pstate := IDLE;
signal pa_we : std_logic := '0';


begin

pa_we_o <= pa_we;

process ( clk ) is begin 
    if ( clk'event and clk = '1' ) then 
        if ( rst_n = '0' ) then
            pa_state_r <= IDLE;
        else

            case pa_state_r is
                when IDLE =>
                    wb_ack_o <= '0';
                    wb_err_o <= '0';
                    wb_rty_o <= '0';
                    if ( wb_cyc_i = '1' and wb_stb_i = '1' ) then 
                        pa_state_r <= WAIT_LATENCY;
                        pa_addr_o <= wb_adr_i;
                        pa_we_o <= wb_we_i;
                        pa_we <= wb_we_i;
                        pa_data_o <= wb_dat_i;
                        pa_state_r <= WAIT_LATENCY;
                        pa_mem_lat_r <= 0;
                    end if;
                when WAIT_LATENCY =>
                    if ( pa_mem_lat_r =  C_READ_LATENCY and pa_we = '0' ) then 
                        pa_state_r <= IDLE;
                        wb_ack_o <= '1';
                        wb_dat_o <= pa_data_i;
                    elsif ( pa_mem_lat_r =  C_WRITE_LATENCY and pa_we = '1' ) then
                        pa_state_r <= IDLE;
                        wb_ack_o <= '1';                        
                    else 
                        pa_mem_lat_r <= pa_mem_lat_r + 1;
                    end if;
            end case;
        end if;
    end if;
end process;




            



end architecture rtl;