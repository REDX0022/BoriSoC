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
        begin
          
            mem := tokenize("../../../../tests/textin.txt", mem);
            return mem;
    end function;
    
    
    
    
   
    

end package body;
