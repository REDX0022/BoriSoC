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
        PC_out: out pc_type;
        regs_out: out regs_type;
        cycle_begin: in bit;
        cycle_end: out bit;
        mem_init_done: out bit;
        cpu_done : out bit
    );

end SoC;

architecture functional of SoC is
    
    
    
    begin
        
        
    process
    variable cycle_end_helper: bit := '0'; -- TODO: move this
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
        variable imm40_I: bit_vector(4 downto 0); 
        variable imm12: bit;
        variable imm105: bit_vector(5 downto 0);
        variable imm41: bit_vector(3 downto 0);
        variable imm11_B: bit;
        variable imm3112: bit_vector(19 downto 0);
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
    variable last_cycle_begin : bit := '0';

    begin
        --initalize everything
        wait on mem_in;
        wait for 10 ns;
        mem := mem_in; --get the memory from the input signal
        
       
        CPU_loop: loop 
         
            
            --FETCH instrction
            cycle_end <= '0'; --reset the cycle end signal
            instr := get_dword(PC,mem);
        
            

            instr_out <= instr; --output the instruction
            PC_out <= PC; --output the program counter
            
            
            report "instruction fetched @ " & bitvec_to_hex_string(PC) & " or in intger form " &integer'image(bv_to_integer(PC));
            
            report bitvec_to_bitstring(instr);
            

            code := instr(6 downto 0);
            rd := instr(11 downto 7);
            rs1 := instr(19 downto 15);
            rs2 := instr(24 downto 20);
            funct3 := instr(14 downto 12);
            funct7 := instr(31 downto 25);
            imm110 := instr(31 downto 20);
            imm115 := instr(31 downto 25);
            imm40 := instr(11 downto 7);
            imm40_I := instr(24  downto 20); --TODO: check the imm
            imm12 := instr(31);
            imm105 := instr(30 downto 25);
            imm41 := instr(11 downto 8);
            imm11_B := instr(7);  -- exception naming
            imm3112 := instr(31 downto 12);
            imm20 := instr(31);
            imm101 := instr(30 downto 21);
            imm11J := instr(20); --exceptino naming
            imm1912 := instr(19 downto 12);
            
            
           
            
           
            
            --EXECUTE instruction
            case code is
                when OP =>
                    if(rd /= "00000") then --THIS already takes care of the NOP instruction, just not interpreted yet
                        case funct3 is
                            when ADDf3 =>
                                case funct7 is
                                    when ADDf7 => --ADD
                                        --report "GOT INTO ADD";
                                        regs(bv_to_integer(rd)) := slice_msb(regs(bv_to_integer(rs1)) + regs(bv_to_integer(rs2))); 
                                    when SUBf7 => --SUB
                                        --report "GOT INTO SUB";
                                        regs(bv_to_integer(rd)) := slice_lsb(regs(bv_to_integer(rs1)) - regs(bv_to_integer(rs2))); --TODO: Implement subtraction, also 
                                    when others =>
                                        report "illegal insruction in ADD and SUB" severity error; --also print to trace here
                                        exit CPU_loop;
                                end case;
                            when SLTf3 => --SLT
                                
                                report "GOT INTO SLT";
                                report "Integers to be compeered are SLT " & bitvec_to_hex_string(regs(bv_to_integer(rs1))) & " and " & bitvec_to_hex_string(regs(bv_to_integer(rs2)));
                                if (bv_to_signed_integer(regs(bv_to_integer(rs1))) < bv_to_signed_integer(regs(bv_to_integer(rs2)))) then
                                    regs(bv_to_integer(rd)) := X"00000001";
                                    else
                                    regs(bv_to_integer(rd)) := X"00000000";
                                    end if;
                            when SLTUf3 => --SLTU
                                    --report "GOT INTO SLTU";
                                    if (bv_to_unsigned(regs(bv_to_integer(rs1))) < bv_to_unsigned(regs(bv_to_integer(rs2)))) then
                                        regs(bv_to_integer(rd)) := X"00000001";
                                    else
                                        regs(bv_to_integer(rd)) := X"00000000";
                                    end if;
                            when ANDf3 =>
                                        --report "GOT INTO AND";
                                        regs(bv_to_integer(rd)) := regs(bv_to_integer(rs1)) and regs(bv_to_integer(rs2));
                            when ORf3 =>
                                    --report "GOT INTO OR";
                                        regs(bv_to_integer(rd)) := regs(bv_to_integer(rs1)) or regs(bv_to_integer(rs2));
                            when XORf3 =>
                                        --report "GOT INTO XOR";
                                        regs(bv_to_integer(rd)) := regs(bv_to_integer(rs1)) xor regs(bv_to_integer(rs2));
                            when SLLf3 => --TODO: check the imm
                                        --report "GOT INTO SLL";
                                        regs(bv_to_integer(rd)) := regs(bv_to_integer(rs1)) sll bv_to_integer(regs(bv_to_integer(rs2))(4 downto 0)); 
                            when SRL_Af3 =>
                                        if(instr(30) = '1') then --too nieche to make a separeate variable, this is the same as funct7
                                            --report "GOT INTO SRA";       
                                            regs(bv_to_integer(rd)) := regs(bv_to_integer(rs1)) sra bv_to_integer(regs(bv_to_integer(rs2))(4 downto 0));
                                        else
                                            --report "GOT INTO SRL";     
                                            ----report "SHIFTING BY " & integer'image(bv_to_integer(regs(bv_to_integer(rs2))(4 downto 0)));   
                                            regs(bv_to_integer(rd)) := regs(bv_to_integer(rs1)) srl bv_to_integer(regs(bv_to_integer(rs2))(4 downto 0));
                                        end if;
                                when others=> --THIS WILL NEVER HAPPEN
                                report "illegal insruction in OP" severity error; --also print to trace here
                               
                                exit CPU_loop;
                        end case;
                    
                    end if;
                    PC:= slice_msb(PC+X"0004");
                when OPIMM =>
                    if(rd /= "00000") then
                        --report "GOT INTO OPIMM";
                      case funct3 is
                        when ADDf3 => --ADDI
                            --report "GOT INTO ADDI";
                            
                            ----report "imm is " & bitvec_to_bitstring(imm110) & " or in intger form " &integer'image(bv_to_integer(imm110));
                           
                            
                        
                            regs(bv_to_integer(rd)):= slice_msb(regs(bv_to_integer(rs1)) + signext_bv2dw(imm110)); -- has to use meesy temp variables, +1 downside
                            --add error checking here
                        
                        when SLTf3 =>
                            --report "GOT INTO SLTI";
                            ----report "Integers to be compeered are SLTI " & integer'image(bv_to_integer(regs(bv_to_integer(rs1)))) & " and " & integer'image(bv_to_integer(signext_bv2dw(imm110)));
                            if (bv_to_signed_integer(regs(bv_to_integer(rs1))) < bv_to_signed_integer(signext_bv2dw(imm110))) then -- ERROR HERE
                                regs(bv_to_integer(rd)) := X"00000001";
                            else
                                regs(bv_to_integer(rd)) := X"00000000";
                            end if;
                        when SLTUf3 => -- the imm is first SIGN extended and the treated as unsigned
                            --report "GOT INTO SLTUI";

                            ----report "Integers to be compeered are SLTIU " & integer'image(bv_to_integer(regs(bv_to_integer(rs1)))) & " and " & integer'image(bv_to_integer(signext_bv2dw(imm110)));
                            if (bv_to_unsigned(regs(bv_to_integer(rs1))) < bv_to_unsigned(signext_bv2dw(imm110))) then
                                regs(bv_to_integer(rd)) := X"00000001";
                            else
                                regs(bv_to_integer(rd)) := X"00000000";
                            end if;
                        when ANDf3 =>
                            --report "GOT INTO ANDI";       
                            regs(bv_to_integer(rd)) := regs(bv_to_integer(rs1)) and signext_bv2dw(imm110);
                        when ORf3 =>
                            --report "GOT INTO ORI";       
                            regs(bv_to_integer(rd)) := regs(bv_to_integer(rs1)) or signext_bv2dw(imm110);
                        when XORf3 =>
                            --report "GOT INTO XORI";       
                            regs(bv_to_integer(rd)) := regs(bv_to_integer(rs1)) xor signext_bv2dw(imm110);
                        when SLLf3 => --TODO: check the imm
                            --report "GOT INTO SLLI";       
                            regs(bv_to_integer(rd)) := regs(bv_to_integer(rs1)) sll bv_to_integer(imm40_I);
                        when SRL_Af3 =>
                            if(instr(30) = '1') then --too nieche to make a separeate variable
                                --report "GOT INTO SRAI";       
                                ----report "SHIFTING BY " & integer'image(bv_to_integer(imm40_I));
                                regs(bv_to_integer(rd)) := regs(bv_to_integer(rs1)) sra bv_to_integer(imm40_I);
                            else
                                --report "GOT INTO SRLI";       
                                regs(bv_to_integer(rd)) := regs(bv_to_integer(rs1)) srl bv_to_integer(imm40_I);
                            end if;
                            
                        
                        when others=> --THIS WILL NEVER HAPPEN
                                report "illegal insruction" severity error;
                       end case;
                    end if;
                    PC:= slice_msb(PC+X"0004");
               
                
                when AUIPC =>
                    if(rd /= "00000") then
                        --report "GOT INTO AUIPC";
                        --Addional slicined needed because of the 16 bit address space
                        regs(bv_to_integer(rd)) := X"0000" & (slice_msb((X"0000" & PC) + (imm3112 & X"000"))(15 downto 0)); --TODO: make extenstions functions, this is specific to our 16 bit address space
                    end if;
                    PC:= slice_msb(PC+X"0004");
                when LUI =>
                    if(rd /= "00000") then
                        --report "GOT INTO LUI";
                        regs(bv_to_integer(rd)) := imm3112 & X"000"; 
                    end if;
                    PC:= slice_msb(PC+X"0004");
                
                when JAL =>
                    imm1912(imm1912'right) := '0';
                    if(rd /= "00000") then
                        regs(bv_to_integer(rd)) := X"0000" & slice_msb(PC + X"0004"); 
                    end if;
                    PC := slice_msb(PC + signext_bv2dw(imm20 & imm101 & imm11J & imm1912)(15 downto 0)); --to match the 16 bit address space 
                when JALR =>
                    if (rd /= "00000") then
                        regs(bv_to_integer(rd)) := X"0000" & slice_msb(PC + X"0004"); 
                    end if;
                    PC := slice_lsb(slice_msb(PC + signext_bv2w(imm110))) & '0'; --some bit magic
                when BRANCH =>
                   
                    case funct3 is
                        when BEQf3 =>
                            --imm105(imm105'right) := '0'; --make sure the last bit is 0
                            imm11_B := '0'; --make sure the last bit is 0
                            if (regs(bv_to_integer(rs1)) = regs(bv_to_integer(rs2))) then
                                PC := slice_msb(PC + signext_bv2dw(imm12 & imm105 & imm41 & imm11_B)(15 downto 0));
                            else
                                PC := slice_msb(PC + X"0004");
                            end if;
                        when BNEf3 =>
                            --imm105(imm105'right) := '0'; --make sure the last bit is 0
                            imm11_B := '0'; --make sure the last bit is 0
                            if (regs(bv_to_integer(rs1)) /= regs(bv_to_integer(rs2))) then
                                PC := slice_msb(PC + signext_bv2dw(imm12 & imm105 & imm41 & imm11_B)(15 downto 0));
                            else
                                PC := slice_msb(PC + X"0004");
                            end if;
                        when BLTf3 =>
                            --imm105(imm105'right) := '0'; --make sure the last bit is 0
                            imm11_B := '0'; --make sure the last bit is 0
                            if (bv_to_signed_integer(regs(bv_to_integer(rs1))) < bv_to_signed_integer(regs(bv_to_integer(rs2)))) then
                                PC := slice_msb(PC + signext_bv2dw(imm12 & imm105 & imm41 & imm11_B)(15 downto 0));
                            else
                                PC := slice_msb(PC + X"0004");
                            end if;
                        when BGEf3 =>
                            --imm105(imm105'right) := '0'; --make sure the last bit is 0
                            imm11_B := '0'; --make sure the last bit is 0
                            if (bv_to_signed_integer(regs(bv_to_integer(rs1))) >= bv_to_signed_integer(regs(bv_to_integer(rs2)))) then
                                PC := slice_msb(PC + signext_bv2dw(imm12 & imm105 & imm41 & imm11_B)(15 downto 0));
                            else
                                PC := slice_msb(PC + X"0004");
                            end if;
                        when BLTUf3 =>
                            --imm105(imm105'right) := '0'; --make sure the last bit is 0
                            imm11_B := '0'; --make sure the last bit is 0
                            if (bv_to_unsigned(regs(bv_to_integer(rs1))) < bv_to_unsigned(regs(bv_to_integer(rs2)))) then
                                PC := slice_msb(PC + signext_bv2dw(imm12 & imm105 & imm41 & imm11_B)(15 downto 0));
                            else
                                PC := slice_msb(PC + X"0004");
                            end if;
                        when BGEUf3 =>
                            --imm105(imm105'right) := '0'; --make sure the last bit is 0
                            imm11_B := '0'; --make sure the last bit is 0
                            if (bv_to_unsigned(regs(bv_to_integer(rs1))) >= bv_to_unsigned(regs(bv_to_integer(rs2)))) then
                                PC := slice_msb(PC + signext_bv2dw(imm12 & imm105 & imm41 & imm11_B)(15 downto 0));
                            else
                                PC := slice_msb(PC + X"0004");
                            end if;
                        when others =>
                            report "illegal insruction in BRANCH" severity error; --also print to trace here
                            exit CPU_loop;
                    end case;
                when SYSTEM => --dont need to support
                when FENCE => --dont need to support
                when LOAD =>
                    case funct3 is
                        when LBf3 =>
                            if(rd /= "00000") then
                                regs(bv_to_integer(rd)) := signext_bv2dw(get_byte(slice_msb(regs(bv_to_integer(rs1))(15 downto 0) + signext_bv2w(imm110)), mem));
                            end if;
                        when LBUf3 =>
                            if(rd /= "00000") then
                                regs(bv_to_integer(rd)) := zeroext_b2dw(get_byte(slice_msb(regs(bv_to_integer(rs1))(15 downto 0) + signext_bv2w(imm110)), mem));
                            end if;
                        when LHf3 =>
                            if(rd /= "00000") then
                                regs(bv_to_integer(rd)) := signext_bv2dw(get_word(slice_msb(regs(bv_to_integer(rs1))(15 downto 0) + signext_bv2w(imm110)), mem));
                            end if;
                        when LHUf3 =>
                            if(rd /= "00000") then
                                regs(bv_to_integer(rd)) := zeroext_w2dw(get_word(slice_msb(regs(bv_to_integer(rs1))(15 downto 0) + signext_bv2w(imm110)), mem));
                            end if;
                        when LWf3 =>
                            if(rd /= "00000") then
                                regs(bv_to_integer(rd)) := get_dword(slice_msb(regs(bv_to_integer(rs1))(15 downto 0) + signext_bv2w(imm110)), mem);
                            end if;
                        
                        when others =>
                            report "illegal insruction in LOAD" severity error; --also print to trace here
                            exit CPU_loop;
                    end case;
                    PC:= slice_msb(PC+X"0004");
                    
                when STORE =>
                    case funct3 is
                        when SBf3 => --TODO: Implement exceptions
                            
                            put_byte(slice_msb(regs(bv_to_integer(rs1))(15 downto 0) + signext_bv2w(imm115 & imm40)), regs(bv_to_integer(rs2))(7 downto 0), mem);
                            
                        when SHf3 =>
                            
                            put_word(slice_msb(regs(bv_to_integer(rs1))(15 downto 0) + signext_bv2w(imm115 & imm40)), regs(bv_to_integer(rs2))(15 downto 0), mem);
                            
                        when SWf3 =>
                            
                            put_dword(slice_msb(regs(bv_to_integer(rs1))(15 downto 0) + signext_bv2w(imm115 & imm40)), regs(bv_to_integer(rs2)), mem);
                            
                        when others =>
                            report "illegal insruction in STORE" severity error; --also print to trace here
                            exit CPU_loop;
                    end case;
                    PC:= slice_msb(PC+X"0004");
                when others =>
                    report "illegal insruction" severity error; --also print to trace here
                    exit CPU_loop;
                    
                    --traceOUT <= mem; --TODO: make this a proc
                    --dumpOUT <= mem; --TODO: make this a proc
                    --lets do a reg dump here
            end case;
            
            regs_out <= regs; --by this time all relevant data has been updated
            cycle_end_helper := not cycle_end_helper; --helper signal to detect cycle end
            cycle_end <= cycle_end_helper; --output the cycle end signal
                    
                    
                    --report "after increment pc is"  & bitvec_to_bitstring(PC) & " or in intger form " &integer'image(bv_to_integer(PC));
            wait for 20 ns;
        end loop;
        report "CPU loop ended";
        --we need to cycle the testbench once more to get the mem dump 
        cycle_end_helper := not cycle_end_helper; --helper signal to detect cycle end
        cycle_end <= cycle_end_helper; --output the cycle end signal    
        mem_out <= mem; --output the memory state   
        cpu_done <= '1'; --signal that the CPU has finished execution
        wait;
    end process;
end functional;
