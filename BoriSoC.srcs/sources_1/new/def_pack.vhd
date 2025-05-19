----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/16/2025 08:06:50 PM
-- Design Name: 
-- Module Name: const_pack - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

package def_pack is
    ---------------------Fundemental constants and types------------------------
    constant XLEN: integer := 32; -- to make type conversions bearable these constants will be useless
    constant IALLIGN: integer:= 16; --makes sense to be 16 since our whole cput is 16Bit
    
    constant dataw: integer range 32 downto 1 := XLEN;
    constant addrw: integer range 32 downto 1 := 16;
    constant regw: integer:= XLEN;
    constant regaddrw: integer := 5; --32 registers
    
    constant maxaddr: integer := 2**addrw-1;
    constant maxregaddr: integer := 2**regaddrw-1;
    
    subtype byte_type is bit_vector(7 downto 0);
    subtype word_type is bit_vector(15 downto 0);
    subtype dword_type is bit_vector(31 downto 0);
    
    subtype data_type is dword_type;
    --type data_type is array (dataw-1 downto 0) of bit;
        subtype reg_type is data_type;
    
    subtype addr_type is word_type; --this makes all constants effectvely useless
    --type addr_type is array (addrw-1 downto 0) of bit;
        subtype pc_type is addr_type;
        
    
        
    
    type regs_type is array (maxregaddr downto 0) of  reg_type; -- beware of difference between regs_type and reg_type
    
    
    type mem_type is array(maxaddr downto 0) of byte_type;
    
    -----------------------Instruction definitions--------------------
    constant opcodew: integer := 7;
   
    subtype instr_type is data_type;
    subtype opcode_type is bit_vector(opcodew-1 downto 0); --
    subtype funct3_type is bit_vector(2 downto 0);
        
    
    
    
   
     constant OP: opcode_type := "0110011";
     constant OPIMM: opcode_type := "0010011";
        constant ADDf3: funct3_type := "000";
        constant SLTf3: funct3_type := "010";
        constant SLTUf3: funct3_type := "011";
        constant XORf3: funct3_type := "100";
        constant ORf3: funct3_type := "110";
        constant ANDf3: funct3_type := "100";
        constant SLLf3: funct3_type := "001"; 
        constant SRLf3_SRAf3: funct3_type := "101"; --this is gonna have to undergo additional parsing
     constant LOAD: opcode_type := "0000011";
     constant JARL: opcode_type := "1100111";
     constant STORE: opcode_type := "0100011";
     constant BRANCH: opcode_type := "1100011";
     constant AUIPC: opcode_type := "0010111";
     constant LUI: opcode_type := "0110111";
     constant JAL: opcode_type := "1101111";
     constant FENCE: opcode_type := "0001111";
     constant SYSTEM: opcode_type := "1110011";
   
    
    
   
    
    
    
    --Opcodes--- Might want to split it and branch later for better synthsis i.e. simillar instructions are gonna use simmilar hardware
    
    
    
    
    
    
    
    ----------------------Type conversions----------------------------
    --function to_data(addr: addr_type) return data_type;
    --function to_addr(data: data_type) return addr_type;
    function to_integer(addr: addr_type) return integer;
    function to_integer(bv: bit_vector; len: integer ; signed: boolean) return integer;
     
    function signext_bv2dw(bv: bit_vector) return dword_type;
    
    ----------------------Memory funtions-----------------------------
    function get_byte(addr: addr_type; mem: mem_type) return byte_type; -- does not perfrom extention
    function get_word(addr: addr_type; mem: mem_type) return word_type;
    function get_dword(addr: addr_type; mem: mem_type) return dword_type;
    
    
    ----------------------ALU functions-------------------------------
    function "+"(a, b : bit_vector) return bit_vector;
end def_pack;
    
    
    
    
package body def_pack is
    
    ------------------------Type conversions---------------------------
    
    --function to_data(addr: addr_type) return data_type is
      --  variable datar: data_type;
    
    --begin
      --  for i in addr'range loop
        --    datar(i) := addr(i);
        --end loop;
        --return datar;
    --end function;
    
    --function to_addr(data: data_type) return addr_type is
      --  variable addrr: addr_type;
    
    --begin
      --  for i in data'range loop
        --    addrr(i) := data(i);
        --end loop;
        --return addrr;
    --end function;
    
    
    function to_integer(addr: addr_type) return integer is --NOTE: addr sould be unsigned and this conversion should be fine idk, since these types are quite small 
        variable res:integer := 0;
        --variable pow: integer; for synthesis vivado will probbaly better recongise VHDL power operator than powering manually
        begin
        
        for i in 0 to addrw-1 loop
            if addr(i)='1' then
                res := res + 2**i; --potenitally change to 1 shl i
            end if;
        end loop;
        return res;
    end function;
    --TODO: implement signed and make argument actually do something
    function to_integer(bv: bit_vector; len: integer ; signed: boolean) return integer is --NOTE: this accepts unsigned bv
        variable res:integer := 0;
        --variable pow: integer; for synthesis vivado will probbaly better recongise VHDL power operator than powering manually
        begin
        
        for i in 0 to len-1 loop
            if bv(i)='1' then
                res := res + 2**i;
            end if;
        end loop;
        return res;
    end function;
    ---------------------Sign and Zero extentinon functions--------------
     function signext_b2dw(byte: byte_type) return dword_type is --naming scheme is horrible i know
        begin
        if (byte(7) = '1') then
            return X"FFFFFF" & byte;
        else 
            return X"000000" & byte;
        end if;
     end function;  
     
     function signext_w2dw(word: word_type) return dword_type is --naming scheme is horrible i know
        begin
        if (word(15) = '1') then
            return X"FFFF" & word;
        else 
            return X"0000" & word;
        end if;
     end function;
     
     function zeroext_b2dw(byte: byte_type) return dword_type is --naming scheme is horrible i know
        begin 
        return X"000000" & byte;
     end function;
     
     function zeroext_w2dw(word: word_type) return dword_type is --naming scheme is horrible i know
        begin 
        return X"0000" & word;
     end function;
     
     function signext_bv2dw(bv: bit_vector) return dword_type is
        variable res: dword_type;
        begin
        for i in 31 downto bv'length loop
            res(i):=bv(bv'left);
        end loop;
        for i in bv'length-1 downto 0 loop
            res(i):=bv(i);
        end loop;
        return res;
     end function;
     
     
    
    ---------------------Memory functions--------------------------------
    
    function get_byte(addr: addr_type; mem: mem_type) return byte_type is
         variable byter: byte_type; 
         begin
         return mem(to_integer(addr));
    end function;
    
    function get_word(addr: addr_type; mem: mem_type) return word_type is
         variable wordr: word_type; 
         begin
         return mem(to_integer(addr)) & mem(to_integer(addr)+1); -- are we little endian or big endian i dont get it
    end function;
    
    function get_dword(addr: addr_type; mem: mem_type) return dword_type is
         variable dwordr: dword_type; 
         begin
         
         return mem(to_integer(addr)) & mem(to_integer(addr)+1) & mem(to_integer(addr)+2) & mem(to_integer(addr)+3);
    end function;
    
    ---------------------ALU functions------------------------------------
    
    
    function "+"(a, b : bit_vector) return bit_vector is
    constant len_a  : integer := a'length;
    constant len_b  : integer := b'length;
    constant result_len : integer := integer'max(len_a, len_b) + 1;

    variable a_ext  : bit_vector(result_len - 1 downto 0) := (others => '0');
    variable b_ext  : bit_vector(result_len - 1 downto 0) := (others => '0');
    variable sum    : bit_vector(result_len - 1 downto 0);
    variable carry  : bit := '0';
    variable total : integer := 0;
        begin
        -- Copy inputs into zero-extended vectors (aligned at LSB)
        for i in 0 to len_a - 1 loop
            a_ext(i) := a(i + a'low);
        end loop;
        
        for i in 0 to len_b - 1 loop
            b_ext(i) := b(i + b'low);
        end loop;
        
        -- Perform bitwise addition
        for i in 0 to result_len - 1 loop
            
            total := to_integer(a_ext(i)) + to_integer(b_ext(i)) + to_integer(carry);
            sum(i) := bit'val(total mod 2);
            carry  := bit'val(total / 2);
        end loop;
        
    return sum;
end function;

    
    
   
    
end def_pack;