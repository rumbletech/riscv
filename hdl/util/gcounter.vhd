library IEEE;
library lib_riscv_util;

use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Generic Counter --

entity gcounter is
    generic (
		C_WIDTH : positive := 8;
		C_CNT_STEP : positive := 4 
    );
    port (
        clk : in  std_logic;
        rst_n : in  std_logic;
		cnt_o : out std_logic_vector(C_WIDTH-1 downto 0);
		incr_i : in std_logic;
		ovf_o  : out std_logic
    );
end entity gcounter;

architecture rtl of gcounter is

    signal counter_r : std_logic_vector(C_WIDTH-1 downto 0) := ( others => '0' );
	signal counter_pp_r : std_logic_vector(C_WIDTH downto 0) := ( others => '0' );
	signal count_step_r : std_logic_vector(C_WIDTH-1 downto 0) := ( others => '0' );
	signal ovf_r : std_logic := '0';
	

begin
	
count_step_r <= std_logic_vector(to_unsigned(C_CNT_STEP, counter_r'length));

u_sum_inst : entity lib_riscv_util.gsum
		generic map (
			C_OP_A_WIDTH => C_WIDTH,
			C_OP_B_WIDTH =>	C_WIDTH	
		)
        port map (
			op_a_i => counter_r,
			op_b_i => count_step_r,
			res_o => counter_pp_r
        );

process ( clk ) is begin 
	if ( clk'event and clk = '1' ) then 
		if ( rst_n = '0' ) then 
			counter_r <= ( counter_r'range => '0' );
			ovf_r <= '0';
		else 
			if ( incr_i = '1' ) then 
				counter_r <= counter_pp_r(C_WIDTH-1 downto 0);
				ovf_r <= counter_pp_r(C_WIDTH);
			else 
				ovf_r <= '0';
			end if;
		end if;
	end if;
end process;

ovf_o <= ovf_r;
cnt_o <= counter_r;

end architecture rtl;
