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

library WORK;
use WORK.def_pack.all;
use WORK.init_pack.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;



entity SoC is
    port(
        fileIN: in mem_type;
        dumpOUT: out mem_type;
        traceOUT: out mem_type --here is mem_type used creatlivly because we dont have vairable length arrays in vhdl
    
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
        variable rd: bit_vector(regaddrw-1 downto 0);
        variable rs1: bit_vector(regaddrw-1 downto 0);
        variable rs2: bit_vector(regaddrw-1 downto 0);
        variable funct3: bit_vector(2 downto 0);
        variable funct7: bit_vector(6 downto 0);
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
        --new idea, aliases are probs easies to synthesise
        --alias code is instr(6 downto 0);
        --alias rd is instr(11 downto 7);
        --alias rs1 is instr(19 downto 15);
        --alias rs2 is instr(24 downto 20);
        --alias funct3 is instr(14 downto 12);
       -- alias funct7 is instr(31 downto 25);
        --alias imm110 is instr(31 downto 20);
        --alias imm115 is instr(31 downto 25);
        --alias imm40 is instr(11 downto 7);
        --alias imm12 is instr(31);
        --alias imm105 is instr(30 downto 25);
        --alias imm41 is instr(11 downto 8);
        --alias imm11B is instr(7);  -- exception naming
        --alias imm3111 is instr(31 downto 12);
        --alias imm20 is instr(31);
        --alias imm101 is instr(30 downto 21);
        --alias imm11J is instr(20); --exceptino naming
        --alias imm1912 is instr(19 downto 12);
    
    
        
    variable temp1: bit_vector(32 downto 0);
    variable temp2: bit_vector(16 downto 0);
    variable temp3: bit_vector(8 downto 0);
    variable temp4: bit_vector(15 downto 0);
    begin
        
        --initalize everything
        mem := init_mem;
        loop 
            --FETCH instrction
            instr := get_dword(PC,mem);

            
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
                            temp1 :=   regs(bv_to_integer(rs1)) + signext_bv2dw(imm110);

                            regs(bv_to_integer(rd)):= temp1(XLEN-1 downto 0); -- has to use meesy temp variables, +1 downside
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
                    
                    WAIT;
                    --lets do a reg dump here
                    
            end case;
            temp2 := PC + X"0004"; --TODO: Impelement an incr function, fml;
            report "after increment temp2 is"  & bitvec_to_bitstring(temp2) & " or in intger form " &integer'image(bv_to_integer(temp2));
            
            PC:= (temp2(15 downto 0));-- dont ask why it is 15 downto 1
            report "Value of x0 and x1";
                    report bitvec_to_bitstring(regs(0));
                    report bitvec_to_bitstring(regs(1));
            --report "after increment pc is"  & bitvec_to_bitstring(PC) & " or in intger form " &integer'image(bv_to_integer(PC));
            
            
        end loop;
    end process;
end functional;
