----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/18/2025 01:54:31 PM
-- Design Name: 
-- Module Name: init_pack - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library STD;
use STD.TEXTIO.all;

library WORK;
use WORK.def_pack.all;
use WORK.IO_pack.all;
use WORK.mnemonic_pack.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

package init_pack is
    function init_mem return mem_type;
end package;

package body init_pack is
    
    
   --TODO: Init memory with the text file.
   function init_mem return mem_type is
        variable mem: mem_type := (others => X"00");
        

        
        ------------------------------ OP-IMM--r0-ADD-r1---imm
        constant first: instr_type :=  "000000000010" & "00000" & "000" & "00000"  & "0010011";
        constant second: instr_type := "000000000101"  & "00000" & "000" & "00000" & "0010011" ;
        constant third: instr_type :=  "000000000001" & "00000" & "000" & "00001" & "0010011";
         begin
           --its hard coded for now, for testing
            
            mem(0):= first(7 downto 0);--TODO: figute out if this is small or big endian
            mem(1):= first(15 downto 8);
            mem(2):= first(23 downto 16);
            mem(3):= first(31 downto 24);
            mem(4):= second(7 downto 0);
            mem(5):= second(15 downto 8);
            mem(6):= second(23 downto 16);
            mem(7):= second(31 downto 24);
            mem(8):= third(7 downto 0);
            mem(9):= third(15 downto 8);
            mem(10):= third(23 downto 16);
            mem(11):= third(31 downto 24);

            --now lets try to parse file
            
            mem := tokenize("../../../../tests/textin.txt", mem);
            report bitvec_to_hex_string(mem(12));
            report bitvec_to_hex_string(mem(13));
            return mem;
    end function;
    
    
    
    
    --okay so we need to make a big parser, how do we parse
    --one function could be parse line, it takes a line and then returns a dword, what about data, how do we parse data then????
    function parse_line(s: string) return dword_type is
        variable opcode: string(4 downto 0); --max mnemonic should be 5 char long kA
        begin
            
    end function;
    

end package body;
