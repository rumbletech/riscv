library IEEE;
library riscv_tb;

use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use std.textio.all; -- Required for file reading capabilities

entity wishbone_dual_port_ram is
    generic (
        C_ADDR_WIDTH : positive := 32;
        C_DATA_WIDTH : positive := 32;
        C_RAM_DEPTH  : positive := 2048; -- 2048 words * 4 bytes = 8 KB RAM
        C_INIT_FILE  : string   := "memory_init.txt"
    );
    port (
        clk   : in std_logic;
        rst_n : in std_logic;

        -- Wishbone Slave Interface (Instructions)
        wb_iif_adr_i : in  std_logic_vector(C_ADDR_WIDTH-1 downto 0);
        wb_iif_dat_i : in  std_logic_vector(C_DATA_WIDTH-1 downto 0);
        wb_iif_we_i  : in  std_logic;
        wb_iif_sel_i : in  std_logic_vector(C_DATA_WIDTH/8-1 downto 0);
        wb_iif_cyc_i : in  std_logic;
        wb_iif_stb_i : in  std_logic;
        wb_iif_dat_o : out std_logic_vector(C_DATA_WIDTH-1 downto 0);
        wb_iif_ack_o : out std_logic;

        -- Wishbone Slave Interface (Data)
        wb_dif_adr_i : in  std_logic_vector(C_ADDR_WIDTH-1 downto 0);
        wb_dif_dat_i : in  std_logic_vector(C_DATA_WIDTH-1 downto 0);
        wb_dif_we_i  : in  std_logic;
        wb_dif_sel_i : in  std_logic_vector(C_DATA_WIDTH/8-1 downto 0);
        wb_dif_cyc_i : in  std_logic;
        wb_dif_stb_i : in  std_logic;
        wb_dif_dat_o : out std_logic_vector(C_DATA_WIDTH-1 downto 0);
        wb_dif_ack_o : out std_logic;
        wb_dif_err_o : out std_logic
    );
end entity wishbone_dual_port_ram;

architecture rtl of wishbone_dual_port_ram is

    -- Define the memory types
    type ram_type is array (0 to C_RAM_DEPTH-1) of std_logic_vector(C_DATA_WIDTH-1 downto 0);

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

begin

    -- Force Error signal low for clean transactions
    wb_dif_err_o <= '0';

    ---------------------------------------------------------
    -- Port A: Dedicated Instruction Memory Port (Read Only)
    ---------------------------------------------------------
    process(clk)
        variable word_addr_i : integer;
    begin
        if rising_edge(clk) then
            if rst_n = '0' then
                wb_iif_ack_o <= '0';
                wb_iif_dat_o <= (others => '0');
            else
                -- Traditional synchronous single-cycle pipelining 
                wb_iif_ack_o <= wb_iif_cyc_i and wb_iif_stb_i;
                
                -- Shift address right by 2 to convert byte addressing to word addressing
                word_addr_i := to_integer(unsigned(wb_iif_adr_i(C_ADDR_WIDTH-1 downto 2))) mod C_RAM_DEPTH;
                wb_iif_dat_o <= ram_block(word_addr_i);
            end if;
        end if;
    end process;


    ---------------------------------------------------------
    -- Port B: Dedicated Data Memory Port (Read/Write)
    ---------------------------------------------------------
    process(clk)
        variable word_addr_d : integer;
    begin
        if rising_edge(clk) then
            if rst_n = '0' then
                wb_dif_ack_o <= '0';
                wb_dif_dat_o <= (others => '0');
            else
                wb_dif_ack_o <= wb_dif_cyc_i and wb_dif_stb_i;
                
                -- Convert byte-level address boundary down to word indexes
                word_addr_d := to_integer(unsigned(wb_dif_adr_i(C_ADDR_WIDTH-1 downto 2))) mod C_RAM_DEPTH;
                
                if (wb_dif_cyc_i = '1' and wb_dif_stb_i = '1') then
                    if wb_dif_we_i = '1' then
                        -- Handle Byte-Enable writes (wb_dif_sel_i / rv_dif_be_i)
                        if wb_dif_sel_i(0) = '1' then ram_block(word_addr_d)(7 downto 0)   <= wb_dif_dat_i(7 downto 0);   end if;
                        if wb_dif_sel_i(1) = '1' then ram_block(word_addr_d)(15 downto 8)  <= wb_dif_dat_i(15 downto 8);  end if;
                        if wb_dif_sel_i(2) = '1' then ram_block(word_addr_d)(23 downto 16) <= wb_dif_dat_i(23 downto 16); end if;
                        if wb_dif_sel_i(3) = '1' then ram_block(word_addr_d)(31 downto 24) <= wb_dif_dat_i(31 downto 24); end if;
                    end if;
                    -- Synchronous read pipeline output
                    wb_dif_dat_o <= ram_block(word_addr_d);
                end if;
            end if;
        end if;
    end process;

end architecture rtl;
