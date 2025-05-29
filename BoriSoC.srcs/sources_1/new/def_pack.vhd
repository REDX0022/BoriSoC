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

library WORK;


package def_pack is
    ---------------------Fundemental constants and types------------------------
    constant XLEN: integer := 32; -- to make type conversions bearable these constants will be useless
    constant IALLIGN: integer:= 16; --makes sense to be 16 since our whole cput is 16Bit
    
    constant dataw: integer range 32 downto 1 := XLEN;
    constant addrw: integer range 32 downto 1 := 16;
    constant regw: integer:= XLEN;
    constant regaddrw: integer := 5; --32 registers
    
    constant maxaddr: integer := 2**addrw-1;
    constant maxregaddr: integer := 2**regaddrw-1; -- WAR: This is redundent with regw
    
    subtype byte_type is bit_vector(7 downto 0);
    subtype word_type is bit_vector(15 downto 0);
    subtype dword_type is bit_vector(31 downto 0);
    
    subtype data_type is dword_type;
    --type data_type is array (dataw-1 downto 0) of bit;
        subtype reg_type is data_type;
       
    
    subtype addr_type is word_type; --this makes all constants effectvely useless
    --type addr_type is array (addrw-1 downto 0) of bit;
        subtype pc_type is addr_type;
        
    
        
    
    type regs_type is array (0 to maxregaddr) of  reg_type; -- beware of difference between regs_type and reg_type
    
    
    type mem_type is array(0 to maxaddr) of byte_type;

    --type IO_type is array(integer <>) of byte_type;
    
    -----------------------Instruction definitions--------------------
    constant opcodew: integer := 7;
   
    subtype instr_type is data_type;
    subtype opcode_type is bit_vector(opcodew-1 downto 0); --
    subtype funct3_type is bit_vector(2 downto 0);
    subtype funct7_type is bit_vector(6 downto 0);
    subtype reg_addr_type is bit_vector(regaddrw-1 downto 0);
    
    
    constant OP: opcode_type := "0110011";
    constant OPIMM: opcode_type := "0010011";
        constant ADDf3: funct3_type := "000"; --NOTE: SUB also uses this funct3
        constant SLTf3: funct3_type := "010";
        constant SLTUf3: funct3_type := "011";
        constant XORf3: funct3_type := "100";
        constant ORf3: funct3_type := "110";
        constant ANDf3: funct3_type := "111";
        constant SLLf3: funct3_type := "001"; 
        constant SRL_Af3: funct3_type := "101"; --this is gonna have to undergo additional parsing

        constant ADDf7: funct7_type := "0000000"; 
        constant SUBf7: funct7_type := "0100000"; --NOTE: could be factored out as primary and secondary funct7
    constant LOAD: opcode_type := "0000011";
        constant LBf3: funct3_type := "000";
        constant LHf3: funct3_type := "001";
        constant LWf3: funct3_type := "010";
        constant LBUf3: funct3_type := "100";
        constant LHUf3: funct3_type := "101";
    constant JALR: opcode_type := "1100111";
        constant JALRf3: funct3_type := "000"; --NOTE: this is the only funct3 for JALR
    constant STORE: opcode_type := "0100011";
        constant SBf3: funct3_type := "000";
        constant SHf3: funct3_type := "001";
        constant SWf3: funct3_type := "010";
    constant BRANCH: opcode_type := "1100011";
        constant BEQf3: funct3_type := "000";
        constant BNEf3: funct3_type := "001";
        constant BLTf3: funct3_type := "100";
        constant BGEf3: funct3_type := "101";
        constant BLTUf3: funct3_type := "110";
        constant BGEUf3: funct3_type := "111";
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
    function bv_to_signed_integer(bv : bit_vector) return integer;
    function bv_to_unsigned(bv: bit_vector) return unsigned;

    --------------------Sign and Zero extentinon functions-------------------

    function signext_bv2dw(bv: bit_vector) return dword_type;
    function signext_bv2w(bv: bit_vector) return word_type;
    function signext_b2dw(byte: byte_type) return dword_type;
    function signext_w2dw(word: word_type) return dword_type;
    function zeroext_b2dw(byte: byte_type) return dword_type;
    function zeroext_w2dw(word: word_type) return dword_type;

    ----------------------Bit vector functions-----------------------------

    function bitvec_to_hex_string(bv : bit_vector) return string;
    
    function bitvec_to_bitstring(bv : bit_vector) return string;
    
    function hexstring_to_bitvec(s : string) return bit_vector;

    ----------------------Memory funtions-----------------------------
    function get_byte(addr: addr_type; mem: mem_type) return byte_type; -- does not perfrom extention
    function get_word(addr: addr_type; mem: mem_type) return word_type;
    function get_dword(addr: addr_type; mem: mem_type) return dword_type;
    procedure put_byte(addr: addr_type; data: byte_type; mem: inout mem_type); -- does not perfrom extention
    procedure put_word(addr: addr_type; data: word_type; mem: inout mem_type);
    procedure put_dword(addr: addr_type; data: dword_type; mem: inout mem_type);
    
    
    ----------------------ALU functions-------------------------------
    function max(a,b:integer) return integer;--TODO: Get this to some other package, its such a stupid funciton
    function "+"(a, b : bit_vector) return bit_vector;
    function "-" (a, b : bit_vector) return bit_vector;
    function slice_msb(bv : bit_vector) return bit_vector;
    function slice_lsb(bv : bit_vector) return bit_vector;
    
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
    
    --the point is range always goes to msb first
    function bv_to_signed_integer(bv : bit_vector) return integer is
    variable result : integer := 0;
    variable width  : integer := bv'length;
    variable idx    : integer := 0;
    variable is_negative : boolean := false;
    begin
        for i in bv'range loop
            if idx = 0 then
                if bv(i) = '1' then
                    is_negative := true;
                end if;
            elsif ((bv(i) = '1')  and not is_negative) OR ((bv(i) = '0') and is_negative) then
                result := result + 2**(width-1-idx);
            end if;
            idx := idx + 1;
        end loop;
    
        return result;
    end function;
    
    function bv_to_unsigned(bv: bit_vector) return unsigned is
        variable result: unsigned(bv'length - 1 downto 0);
        variable idx: integer :=  bv'length - 1; -- Start from the MSB
        begin
            for i in bv'range loop
                if(bv(i) = '1') then --GOD THIS IS UGLY, stupid vivado gives me an error no matter what i do
                    result(idx) := '1';
                else
                    result(idx) := '0';
                end if;
                idx := idx - 1; -- Move to the next bit
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

    function hexstring_to_bitvec(s : string) return bit_vector is
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
       variable res: dword_type := X"00000000";
       variable sign_bit: bit := '0';
       variable i: integer;
       variable res_idx: integer := bv'length -1; -- Index for result vector
    begin
       -- Sign-extend bit_vector to dword_type (32 bits)
       if bv'length = 0 then
          return res;
       end if;

       sign_bit := bv(bv'left);

    -- Copy input bits to LSB of result using a separate index for res
   
    for i in bv'range loop
       res(res_idx) := bv(i);
       res_idx := res_idx - 1;
    end loop;

       -- Sign-extend if input is shorter than 32 bits
       for i in bv'length to 31 loop
          res(i) := sign_bit;
       end loop;

       return res;
    end function;


    function signext_bv2w(bv: bit_vector) return word_type is
       variable res: word_type := X"0000";
       variable sign_bit: bit := '0';
       variable i: integer;
       variable res_idx: integer := bv'length -1; -- Index for result vector
    begin
       -- Sign-extend bit_vector to word_type (16 bits)
       if bv'length = 0 then
          return res;
       end if;

       sign_bit := bv(bv'left);
       -- Copy input bits to LSB of result using a separate index for res
       for i in bv'range loop
          res(res_idx) := bv(i);
          res_idx := res_idx - 1;
       end loop;
       -- Sign-extend if input is shorter than 16 bits
       for i in bv'length to 15 loop
          res(i) := sign_bit;
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

    procedure put_byte(addr: addr_type; data: byte_type; mem: inout mem_type) is
        begin
        mem(bv_to_integer(addr)) := data; --TODO: check if this is correct
    end procedure;

    procedure put_word(addr: addr_type; data: word_type; mem: inout mem_type) is
        begin
        mem(bv_to_integer(addr)) := data(7 downto 0); --TODO: check if this is correct
        mem(bv_to_integer(addr)+1) := data(15 downto 8); --TODO: check if this is correct
    end procedure;
    
    procedure put_dword(addr: addr_type; data: dword_type; mem: inout mem_type) is
        begin
        mem(bv_to_integer(addr)) := data(7 downto 0); --TODO: check if this is correct
        mem(bv_to_integer(addr)+1) := data(15 downto 8); --TODO: check if this is correct
        mem(bv_to_integer(addr)+2) := data(23 downto 16); --TODO: check if this is correct
        mem(bv_to_integer(addr)+3) := data(31 downto 24); --TODO: check if this is correct
    end procedure;
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
            report "Performing addition on bit_vectors of lengths " & integer'image(len_a) & " and " & integer'image(len_b) severity note;
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
            for i in 0 to result_len-1 loop --NOTE: Made a big change to go to result_len instead of result_len-1
                
                

                sum(i) := a_ext(i) XOR b_ext(i) XOR carry; --lets hope vivado recoginzes this is just a full adder
                carry := (a_ext(i) AND b_ext(i)) OR (a_ext(i) AND carry) OR (carry AND b_ext(i));
            end loop;
        return sum;
    end function;

    function "-" (a, b : bit_vector) return bit_vector is
        constant len_a  : integer := a'length;
        constant len_b  : integer := b'length;
        constant result_len : integer := max(len_a, len_b) + 1;

        variable a_ext  : bit_vector(result_len - 1 downto 0) := (others => '0');
        variable b_ext  : bit_vector(result_len - 1 downto 0) := (others => '0');
        variable diff   : bit_vector(result_len - 1 downto 0);
        variable borrow : bit := '0';
        variable idx    : integer := 0;
    begin
        -- Copy inputs into zero-extended vectors (aligned at LSB)
        --report "Performing subtraction on bit_vectors of lengths " & integer'image(len_a) & " and " & integer'image(len_b) severity note;
        idx := a'length;
        for i in a'range loop
            a_ext(idx) := a(i);
            idx := idx - 1;
        end loop;

        idx := b'length;
        for i in b'range loop
            b_ext(idx) := b(i);
            idx := idx - 1;
        end loop;

        -- Perform bitwise subtraction
        for i in 0 to result_len-1 loop
            diff(i) := (a_ext(i) XOR b_ext(i)) XOR borrow;
            borrow := ((not a_ext(i)) and b_ext(i)) or (borrow and (not a_ext(i) XOR b_ext(i)));
        end loop;
        return diff;
    end function;

    function slice_msb(bv : bit_vector) return bit_vector is
    variable result : bit_vector(bv'length - 2 downto 0);
    variable index  : integer := bv'length-2;
    begin
        for i in bv'range loop
            if i /= bv'left then  -- skip the MSB
                result(index) := bv(i);
                index := index -1;
            end if;
        end loop;
        return result;
    end function;

    function slice_lsb(bv : bit_vector) return bit_vector is
        variable result : bit_vector(bv'length - 2 downto 0);
        variable index  : integer := bv'length-2;
        begin
            for i in bv'range loop
                if i /= bv'right then  -- skip the LSB
                    result(index) := bv(i);
                    index := index - 1; --this should work
                end if;
            end loop;
        return result;
    
    end function;
   
    
end def_pack;