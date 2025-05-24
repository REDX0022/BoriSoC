----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Boris Ceranic
-- 
-- Create Date: 05/16/2025 08:01:18 PM
-- Design Name: 
-- Module Name: SoC - functional
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
use IEEE.NUMERIC_STD.ALL;

library WORK;
use WORK.def_pack.all;
use WORK.init_pack.all;
use WORK.mnemonic_pack.all;
use WORK.IO_pack.all;

library STD;
use STD.TEXTIO.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values



entity SoC is
    port(
        mem_in: in mem_type; 
        mem_out: out mem_type;
        instr_out: out instr_type;
        PC_out: out pc_type
        --Might want to add a register dump output
    );

end SoC;

architecture functional of SoC is

    
   
begin


    process
    variable mem: mem_type;
    variable regs: regs_type := (others => X"00000000"); --TODO: Might want to have a proc
    variable PC: pc_type := X"0000"; --might want to change program start
    variable instr: instr_type;
        variable code: opcode_type;
        variable rd: reg_addr_type;
        variable rs1: reg_addr_type;
        variable rs2: reg_addr_type;
        variable funct3: funct3_type;
        variable funct7: funct7_type;
        variable imm110: bit_vector(11 downto 0); 
        variable imm115: bit_vector(6 downto 0);
        variable imm40: bit_vector(4 downto 0);
        variable imm12: bit;
        variable imm105: bit_vector(5 downto 0);
        variable imm41: bit_vector(3 downto 0);
        variable imm11B: bit;
        variable imm3111: bit_vector(19 downto 0);
        variable imm20: bit;
        variable imm101: bit_vector(9 downto 0);
        variable imm11J: bit;
        variable imm1912: bit_vector(7 downto 0);

    
    
        
    variable temp1: bit_vector(32 downto 0);
    variable temp2: bit_vector(16 downto 0);
    variable temp3: bit_vector(8 downto 0);
    variable temp4: bit_vector(15 downto 0);
    ---TEMPORARY TRACE FILE: MOVE TO tesetbench
    -- file declaration moved outside process
    
    begin
        --initalize everything
        wait on mem_in;
        mem := mem_in; --get the memory from the input signal
        
        CPU_loop: loop 
        --FETCH instrction
            instr := get_dword(PC,mem);
        
            instr_out <= instr; --output the instruction
            PC_out <= PC; --output the program counter
            
            --report "The value of 'a' is " & integer'image(to_integer(temp2(15 downto 0)));
            report "instruction fetched @ " & bitvec_to_bitstring(PC) & " or in intger form " &integer'image(bv_to_integer(PC));
     
            report bitvec_to_bitstring(instr);
            --temp4 := X"0004";
            --report "constant and + checking";
            --report "4 is from hex" & bitvec_to_bitstring(X"0004") & " or in intger form " &integer'image(bv_to_integer(X"0004"));
            --report "4 is from bin" & bitvec_to_bitstring("0000000000000100") & " or in intger form " &integer'image(bv_to_integer("0000000000000100"));
            --report "and from variable" & bitvec_to_bitstring(temp4) & " or in intger form " &integer'image(bv_to_integer(temp4));
            --report "adds up to " & bitvec_to_bitstring(X"0004"+X"0002") & " or in intger form " &integer'image(bv_to_integer(X"0004"+X"0002"));
            --report "adds up to " & bitvec_to_bitstring(temp4+X"0004") & " or in intger form " &integer'image(bv_to_integer(temp4+X"0004"));
            --WAIT;
         

            code := instr(6 downto 0);
            rd := instr(11 downto 7);
            rs1 := instr(19 downto 15);
            rs2 := instr(24 downto 20);
            funct3 := instr(14 downto 12);
            funct7 := instr(31 downto 25);
            imm110 := instr(31 downto 20);
            imm115 := instr(31 downto 25);
            imm40 := instr(11 downto 7);
            imm12 := instr(31);
            imm105 := instr(30 downto 25);
            imm41 := instr(11 downto 8);
            imm11B := instr(7);  -- exception naming
            imm3111 := instr(31 downto 12);
            imm20 := instr(31);
            imm101 := instr(30 downto 21);
            imm11J := instr(20); --exceptino naming
            imm1912 := instr(19 downto 12);
            
            
           
            
            --code := instr(opcodew downto 0); --theese types are getting complicated
            --parse everything then use something, dont know how well that will syntesise tho
            
            --EXECUTE instruction
            case code is
                when OP => 
                    
                when OPIMM =>
                        --report "GOT INTO OPIMM";
                      case funct3 is
                        when ADDf3 => --ADDI
                            --report "GOT INTO ADDI";
                            
                            report "imm is " & bitvec_to_bitstring(imm110) & " or in intger form " &integer'image(bv_to_integer(imm110));
                           
                            

                            regs(bv_to_integer(rd)):= slice_msb(regs(bv_to_integer(rs1)) + signext_bv2dw(imm110)); -- has to use meesy temp variables, +1 downside
                            --add error checking here
                        
                        when SLTf3 =>
                             
                        when others=>
                                report "illegal insruction" severity error;
                       end case;
                      
                            
                when LOAD =>
                when JARL =>
                when STORE =>
                when BRANCH =>
                when AUIPC =>
                when LUI =>
                when JAL =>
                when FENCE => --dont need to support
                when SYSTEM => --dont need to support
                when others =>
                    report "illegal insruction" severity error; --also print to trace here
                    exit CPU_loop;
                    
                    --traceOUT <= mem; --TODO: make this a proc
                    --dumpOUT <= mem; --TODO: make this a proc
                    --lets do a reg dump here
            end case;
                    
                    PC:= slice_msb(PC+X"0004");-- dont ask why it is 15 downto 1
                    report "Value of x0 and x1";
                    report bitvec_to_bitstring(regs(0));
                    report bitvec_to_bitstring(regs(1));
                    --report "after increment pc is"  & bitvec_to_bitstring(PC) & " or in intger form " &integer'image(bv_to_integer(PC));
                    
            wait for 10 ns; 
        end loop;
        mem_out <= mem; --output the memory state
    end process;
end functional;
