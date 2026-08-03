library IEEE;
library riscv_tb;

use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use std.textio.all; -- Required for file reading capabilities

entity wishbone_dual_port_ram is
    generic (
        C_READ_LATENCY : integer := 0;
        C_WRITE_LATENCY : integer := 0;
        C_ADDR_WIDTH : positive := 32;
        C_DATA_WIDTH : positive := 32;
        C_RAM_DEPTH  : positive := 2048; -- 2048 words * 4 bytes = 8 KB RAM
        C_INIT_FILE  : string   := "memory_init.txt"
    );
    port (
        clk   : in std_logic;
        rst_n : in std_logic;

        -- PORT A --
        PA_DATA_I : in  std_logic_vector(C_DATA_WIDTH-1 downto 0);
        PA_ADDR_I : in  std_logic_vector(C_ADDR_WIDTH-1 downto 0);
        PA_WE_I   : in  std_logic;
        PA_DATA_O : out std_logic_vector(C_DATA_WIDTH-1 downto 0);

        -- PORT B --
        PB_DATA_I : in  std_logic_vector(C_DATA_WIDTH-1 downto 0);
        PB_ADDR_I : in  std_logic_vector(C_ADDR_WIDTH-1 downto 0);
        PB_WE_I   : in  std_logic;
        PB_DATA_O : out std_logic_vector(C_DATA_WIDTH-1 downto 0)
    );
end entity wishbone_dual_port_ram;

architecture rtl of wishbone_dual_port_ram is

    -- Define the memory types
    type ram_type is array (0 to C_RAM_DEPTH-1) of std_logic_vector(C_DATA_WIDTH-1 downto 0);
    type read_latency is array ( 0 to C_READ_LATENCY ) of std_logic_vector(C_ADDR_WIDTH-1 downto 0);

    -- Helper function to convert a hex character to std_logic_vector
    function hex_char_to_slv(c : character) return std_logic_vector is
    begin
        case c is
            when '0' => return x"0"; when '1' => return x"1"; when '2' => return x"2"; when '3' => return x"3";
            when '4' => return x"4"; when '5' => return x"5"; when '6' => return x"6"; when '7' => return x"7";
            when '8' => return x"8"; when '9' => return x"9"; when 'a'|'A' => return x"A"; when 'b'|'B' => return x"B";
            when 'c'|'C' => return x"C"; when 'd'|'D' => return x"D"; when 'e'|'E' => return x"E"; when 'f'|'F' => return x"F";
            when others => return x"0";
        end case;
    end function;

    -- File Parser function executed only during synthesis/simulation boot
    impure function init_ram_from_file(file_name : in string) return ram_type is
        file temp_file     : text is in file_name;
        variable temp_line : line;
        variable temp_word : string(1 to 8); -- Fits exactly 8 hex chars (32-bits)
        variable ram_data  : ram_type := (others => (others => '0'));
    begin
        for i in 0 to C_RAM_DEPTH-1 loop
            if not endfile(temp_file) then
                readline(temp_file, temp_line);
                read(temp_line, temp_word);
                -- Pack characters into standard logic vectors
                for j in 0 to 7 loop
                    ram_data(i)((31 - j*4) downto (28 - j*4)) := hex_char_to_slv(temp_word(j+1));
                end loop;
            else
                exit; -- Stop if file runs out of text lines early
            end if;
        end loop;
        return ram_data;
    end function;

    -- Signal instantiation pre-populated by file parser
    signal ram_block : ram_type := init_ram_from_file(C_INIT_FILE);

    -- Attributes to force Vivado to utilize Block RAM (BRAM) 
    attribute ram_style : string;
    attribute ram_style of ram_block : signal is "block";

    signal pa_addr_delay : read_latency := ( others => ( others => '0' ));
    signal pb_addr_delay : read_latency := ( others => ( others => '0' ));

begin


TRANSPARENT_READ_PROC: if C_READ_LATENCY = 0 generate
 
process(PA_ADDR_I, PA_WE_I, PA_DATA_I,rst_n)
        variable word_addr_i : integer;
    begin
        if rst_n = '0' then
            PA_DATA_O <= (others => '0');
        else               
            word_addr_i := to_integer(unsigned(PA_ADDR_I(C_ADDR_WIDTH-1 downto 2))) mod C_RAM_DEPTH;
            PA_DATA_O <= ram_block(word_addr_i);
        end if;
end process;


process(PB_ADDR_I, PB_WE_I, PB_DATA_I,rst_n)
        variable word_addr_i : integer;
    begin
        if rst_n = '0' then
            PB_DATA_O <= (others => '0');
        else               
            word_addr_i := to_integer(unsigned(PB_ADDR_I(C_ADDR_WIDTH-1 downto 2))) mod C_RAM_DEPTH;
            PB_DATA_O <= ram_block(word_addr_i);
        end if;
end process;

end generate;

NON_TRANSPARENT_READ_PROC: if C_READ_LATENCY > 0 generate 

process(clk)
        variable word_addr_i : integer;
begin
    if rising_edge(clk) then
        if rst_n = '0' then
            PA_DATA_O <= (others => '0');
        else 
            -- Delay Read by at least 1 cycle --
            pa_addr_delay(0) <= PA_ADDR_I;
            for i in 0 to C_READ_LATENCY-1 loop
                pa_addr_delay(i+1) <= pa_addr_delay(i);
            end loop;
            
            word_addr_i := to_integer(unsigned(pa_addr_delay(C_READ_LATENCY-1)(C_ADDR_WIDTH-1 downto 2))) mod C_RAM_DEPTH;
            PA_DATA_O <= ram_block(word_addr_i);
        end if;
    end if;
end process;


process(clk)
        variable word_addr_i : integer;
begin
    if rising_edge(clk) then
        if rst_n = '0' then
            PB_DATA_O <= (others => '0');
        else 
            -- Delay Read by at least 1 cycle --
            pb_addr_delay(0) <= PB_ADDR_I;
            for i in 0 to C_READ_LATENCY-1 loop
                pb_addr_delay(i+1) <= pb_addr_delay(i);
            end loop;
            
            word_addr_i := to_integer(unsigned(pb_addr_delay(C_READ_LATENCY-1)(C_ADDR_WIDTH-1 downto 2))) mod C_RAM_DEPTH;
            PB_DATA_O <= ram_block(word_addr_i);
        end if;
    end if;
end process;

end generate;


end architecture rtl;
