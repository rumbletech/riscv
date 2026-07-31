library IEEE;
library riscv_utils;

use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Generic 1 bit Full Adder --

entity gfadder is
    port (
		a_i : in std_logic;
		b_i : in std_logic;
		c_i : in std_logic;
		s_o : out std_logic;
		c_o : out std_logic
    );
end entity gfadder;

architecture rtl of gfadder is begin

s_o <= a_i xor b_i xor c_i;
c_o <= ( a_i and b_i ) or ( b_i and c_i ) or ( a_i and c_i );

end architecture rtl;
