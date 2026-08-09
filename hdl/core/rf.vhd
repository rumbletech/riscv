library IEEE;
library riscv_core;

use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use riscv_core.riscv_core_pkg.ALL;


entity rf is
	generic (
		C_READ_BUF_EN : boolean := false
	);
    port (
        clk : in  std_logic := '0';
        rst_n : in  std_logic := '0';
		-- Register Read Interface --
		r0_addr_i : std_logic_vector(clog2(C_RV_NUM_REGISTERS)-1 downto 0) := ( others => '0');
		r0_data_o : std_logic_vector(C_RV_DATA_WIDTH-1 downto 0) := ( others => '0');
		
		r1_addr_i : std_logic_vector(clog2(C_RV_NUM_REGISTERS)-1 downto 0) := ( others => '0');
		r1_data_o : std_logic_vector(C_RV_DATA_WIDTH-1 downto 0) := ( others => '0');		
		-- Register Write Interface --
		w_addr_i : std_logic_vector(clog2(C_RV_NUM_REGISTERS)-1 downto 0) := ( others => '0');
		w_data_i : std_logic_vector(C_RV_DATA_WIDTH-1 downto 0) := ( others => '0');
		w_wren_i : std_logic := '0'
			
    );
end entity rf;

architecture rtl of rf is

type reg_arr_t is array (0 to C_RV_NUM_REGISTERS-1) of std_logic_vector(C_RV_DATA_WIDTH-1 downto 0);


signal regs : reg_arr_t := ( others => ( others => '0' ) );
signal wren : std_logic := '0';

begin

wren <= w_wren_i and or_reduce(w_addr_i);

GEN_BUF_READ_PROC : if C_READ_BUF_EN generate

READ_PROC:
	process(clk) is begin
		if ( clk'event and clk = '1' ) then
			if ( rst_n = '0' ) then
				r0_data_o <= ( others => '0' );
				r1_data_o <= ( others => '0' );
			else
				r0_data_o <= regs(to_integer(unsigned(r0_addr_i)));
				r1_data_o <= regs(to_integer(unsigned(r1_addr_i)));
			end if;
		end if;
	end process;
end generate;


GEN_TRANSPARENT_READ_PROC : if not C_READ_BUF_EN generate

READ_PROC:
	process(r0_addr_i,r1_addr_i,regs) is begin 
		r0_data_o <= regs(to_integer(unsigned(r0_addr_i)));
		r1_data_o <= regs(to_integer(unsigned(r1_addr_i)));
	end process READ_PROC;
end generate;

WRITE_PROC:
	process(clk) is begin
		if ( clk'event and clk = '1' ) then 
			if ( rst_n = '0' ) then 
				for i in 0 to C_RV_NUM_REGISTERS-1 loop
					regs(i) <= ( others => '0' );
				end loop;
			else
				if ( wren = '1' ) then 
					regs(to_integer(unsigned(w_addr_i))) <= w_data_i;
				end if;
			end if;
		end if;
	end process;
end architecture rtl;
