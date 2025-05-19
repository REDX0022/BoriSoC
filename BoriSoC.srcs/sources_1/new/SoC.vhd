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
--  Port ( );
end SoC;

architecture functional of SoC is
   
begin
    process
    variable mem: mem_type;
    variable regs: regs_type := (others => X"00000000"); --TODO: Might want to have a proc
    variable PC: pc_type := X"0000"; --might want to change program start
    variable instr: instr_type;
        --variable code: opcode_type;
        --variable rd: bit_vector(regaddrw-1 downto 1);
        --variable rs1: bit_vector(regaddrw-1 downto 1);
        --variable rs2: bit_vector(regaddrw-1 downto 1);
        --variable func3: bit_vector(2 downto 0);
        --variable func7: bit_vector(6 downto 0);
        --variable imm3212: bit_vector(19 to 0); --this can be hardcoded bcs it is just implenetation, you probably dont need it anywhere else
        --variable imm
        --new idea, aliases are probs easies to synthesise
        alias code is instr(6 downto 0);
        alias rd is instr(11 downto 7);
        alias rs1 is instr(19 downto 15);
        alias rs2 is instr(24 downto 20);
        alias funct3 is instr(14 downto 12);
        alias funct7 is instr(31 downto 25);
        alias imm110 is instr(31 downto 20);
        alias imm115 is instr(31 downto 25);
        alias imm40 is instr(11 downto 7);
        alias imm12 is instr(31);
        alias imm105 is instr(30 downto 25);
        alias imm41 is instr(11 downto 8);
        alias imm11B is instr(7);  -- exception naming
        alias imm3111 is instr(31 downto 12);
        alias imm20 is instr(31);
        alias imm101 is instr(30 downto 21);
        alias imm11J is instr(20); --exceptino naming
        alias imm1912 is instr(19 downto 12);
        
        
    variable temp1: bit_vector(32 downto 0);
    variable temp2: bit_vector(16 downto 0);
    begin
    
        --initalize everything
        mem := init_mem;
        loop 
            --FETCH instrction
            instr := get_dword(PC,mem);
            --parsing is sone implicity via alias, seems sympler to syntesise, have no idea tho
           
            
            
            
            --code := instr(opcodew downto 0); --theese types are getting complicated
            --parse everything then use something, dont know how well that will syntesise tho
            
            --EXECUTE instruction
            case code is
                when OP => 
                    
                when OPIMM =>
                        
                      case funct3 is
                        when ADDf3 => --ADDI
                            temp1 := (regs(to_integer(rs1,4,false)) + signext_bv2dw(imm110));
                            regs(to_integer(rd,4,false)):= temp1(XLEN-1 downto 0); -- has to use meesy temp variables, +1 downside
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
                    exit;
            end case;
            temp2 := PC + X"0001"; --TODO: Impelement an incr function, fml;
            PC:= temp1(15 downto 0);    
        end loop;
    end process;
end functional;
