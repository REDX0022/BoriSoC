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

    --type IO_type is array(integer <>) of byte_type;
    
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
    function bv_to_integer(bv: bit_vector) return integer;
     
    function signext_bv2dw(bv: bit_vector) return dword_type;

    function bitvec_to_hex_string(bv : bit_vector) return string;
    
    function bitvec_to_bitstring(bv : bit_vector) return string;
    
    function hexstring_to_bitvector(s : string) return bit_vector;

    ----------------------Memory funtions-----------------------------
    function get_byte(addr: addr_type; mem: mem_type) return byte_type; -- does not perfrom extention
    function get_word(addr: addr_type; mem: mem_type) return word_type;
    function get_dword(addr: addr_type; mem: mem_type) return dword_type;
    
    
    ----------------------ALU functions-------------------------------
    function max(a,b:integer) return integer;--TODO: Get this to some other package, its such a stupid funciton
    function "+"(a, b : bit_vector) return bit_vector;
    function flipbv(bv: bit_vector) return bit_vector;
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
        
        for i in addrw-1 downto 0 loop -- downto needs to be used ig
            if addr(i)='1' then
                res := res + 2**(i); --potenitally change to 1 shl i
            end if;
        end loop;
        return res;
    end function;
    --TODO: make a signed version
    function bv_to_integer(bv : bit_vector) return integer is
    variable result : integer := 0;
    variable exp : integer := bv'length-1;
    begin
        for i in bv'range loop
            if(bv(i) = '1') then
                result := result + 2**exp;
            end if;
            exp := exp-1;
        end loop;
        
        return result;
    end function;



    function bitvec_to_hex_string(bv : bit_vector) return string is
            constant hex_chars : string := "0123456789ABCDEF";
            constant nibbles   : integer := bv'length / 4;
            variable result    : string(1 to nibbles);
            variable nibble    : integer;
            variable idx       : integer := 1;
            variable i         : integer;
        begin
            if (bv'length mod 4) /= 0 then
                report "bit_vector length must be a multiple of 4"
                severity error;
            end if;

            -- Process bits from MSB down to LSB, 4 at a time
            i := bv'length - 1;
            while i >= 0 loop
                nibble := 0;
                for j in 0 to 3 loop
                    if bv(i - j + bv'low) = '1' then
                        nibble := nibble + 2**(3 - j);
                    end if;
                end loop;
                result(idx) := hex_chars(nibble + 1);
                idx := idx + 1;
                i := i - 4;
            end loop;

            return result;
    end function;
    

    function bitvec_to_bitstring(bv : bit_vector) return string is
    variable result : string(1 to bv'length);
    variable idx : integer := 1;
    begin
        for i in bv'range loop
            result(idx) := character'VALUE(bit'IMAGE(bv(i)));
            idx := idx + 1;
        end loop;
        return result;
    end function;

    function hexstring_to_bitvector(s : string) return bit_vector is
    variable result : bit_vector(s'length * 4 - 1 downto 0);
    variable nibble : bit_vector(3 downto 0);
        begin
            for i in s'range loop
                case s(i) is
                    when '0' => nibble := "0000";
                    when '1' => nibble := "0001";
                    when '2' => nibble := "0010";
                    when '3' => nibble := "0011";
                    when '4' => nibble := "0100";
                    when '5' => nibble := "0101";
                    when '6' => nibble := "0110";
                    when '7' => nibble := "0111";
                    when '8' => nibble := "1000";
                    when '9' => nibble := "1001";
                    when 'A' | 'a' => nibble := "1010";
                    when 'B' | 'b' => nibble := "1011";
                    when 'C' | 'c' => nibble := "1100";
                    when 'D' | 'd' => nibble := "1101";
                    when 'E' | 'e' => nibble := "1110";
                    when 'F' | 'f' => nibble := "1111";
                    when others =>
                        report "Invalid hex digit: " & s(i) severity error;
                end case;

                result((s'length - (i - s'low) - 1) * 4 + 3 downto (s'length - (i - s'low) - 1) * 4) := nibble;
            end loop;

        return result;
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
         return mem(bv_to_integer(addr));
    end function;
    
    function get_word(addr: addr_type; mem: mem_type) return word_type is
         variable wordr: word_type; 
         begin
         return mem(bv_to_integer(addr)+1) & mem(bv_to_integer(addr)); -- are we little endian or big endian i dont get it
    end function;
    
    function get_dword(addr: addr_type; mem: mem_type) return dword_type is
         variable dwordr: dword_type; 
         begin
         
         return mem(bv_to_integer(addr)+3) & mem(bv_to_integer(addr)+2) & mem(bv_to_integer(addr)+1) & mem(bv_to_integer(addr));
    end function;
    
    ---------------------ALU functions------------------------------------
    function max(a, b : integer) return integer is
    begin
        if a > b then
            return a;
        else
            return b;
        end if;
    end function;

    
    function "+"(a, b : bit_vector) return bit_vector is --indexing must start at 0 
        constant len_a  : integer := a'length;
        constant len_b  : integer := b'length;
        constant result_len : integer := max(len_a, len_b) + 1;
        
        variable a_ext  : bit_vector(result_len - 1 downto 0) := (others => '0');
        variable b_ext  : bit_vector(result_len - 1 downto 0) := (others => '0');
        variable sum    : bit_vector(result_len - 1 downto 0);
        variable carry  : bit := '0';
        variable idx: integer :=0;
            begin
            -- Copy inputs into zero-extended vectors (aligned at LSB)
            idx := a'length-1;
            for i in a'range loop
                 a_ext(idx) := a(i);
                 idx := idx -1;
            end loop;
            
            idx := b'length-1;
            for i in b'range loop
                 b_ext(idx) := b(i);
                 idx := idx -1;
            end loop;
            
            
            
            -- Perform bitwise addition
            for i in 0 to result_len-1 loop
                
                

                sum(i) := a_ext(i) XOR b_ext(i) XOR carry; --lets hope vivado recoginzes this is just a full adder
                carry := (a_ext(i) AND b_ext(i)) OR (a_ext(i) AND carry) OR (carry AND b_ext(i));
            end loop;
            
        return sum;
    end function;

    function flipbv(bv: bit_vector) return bit_vector is --begin with 0
        variable res: bit_vector(bv'length-1 downto 0);
        begin
            for i in 0 to bv'length-1 loop
                res(bv'length-1) := bv(i);
            end loop;
            return res;
    end function;

    
    
   
    
end def_pack;