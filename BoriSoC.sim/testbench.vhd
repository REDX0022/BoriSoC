library WORK;
use WORK.def_pack.all; 
use WORK.init_pack.all;
use WORK.IO_pack.all;
use WORK.mnemonic_pack.all;

library STD;
use STD.TEXTIO.all;

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity testbench is

end entity;

architecture TB of testbench is

    constant trace_header: string := "OP   |RD|RS1|IMM |  PC |   x0   |   x1   |   x2   |   x3   |   x4   |   x5   |   x6   |   x7   |   x8   |   x9   | x10   |   x11  |  x12   |   x13   |  x14   |   x15  |   x16  |   x17  |   x18  |   x19  |  x20   |   x21  |   x22  |   x23  |   x24  |   x25  |   x26  |   x27  |   x28  |   x29  |   x30  |   x31  |";
                               --     ADDI   x1 x0 001 @ 0000 00000000 00000001 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 
    
    constant trace_path : string := "../../../../tests/trace.txt";
    constant dump_path : string := "../../../../tests/dump.txt";
    constant textin_path : string := "../../../../tests/textin.txt";
    signal mem_tb_in: mem_type;
    signal mem_tb_out: mem_type;
    signal instr_trace: instr_type;
    signal PC_trace: pc_type;
    signal regs_trace: regs_type;

    signal cycle_SoC_begin: bit := '0';
    signal cycle_SoC_end: bit := '0';
    signal mem_init_SoC_done: bit := '0';

    signal mem_temp: mem_type;



    
    

    

    file trace_f : text open write_mode is trace_path;
    file dump_f  : text open write_mode is dump_path;
    component SoC
            port(
                mem_in: in mem_type;
                mem_out: out mem_type;
                instr_out: out instr_type;
                PC_out: out pc_type;
                regs_out: out regs_type;
                cycle_begin: in bit;
                cycle_end: out bit;
                mem_init_done: out bit

            );
    end component;
    begin
        

        UUT: entity work.SoC
        port map (
            mem_in   => mem_tb_out,
            mem_out => mem_tb_in,
            instr_out => instr_trace,
            PC_out    => PC_trace,
            regs_out => regs_trace,
            cycle_begin => cycle_SoC_begin,
            cycle_end => cycle_SoC_end,
            mem_init_done => mem_init_SoC_done
        );

        process 
        variable l:line;
        variable last_cycle_end : bit := '0'; --Might be depracated
        
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
        variable imm11B: bit;
        variable imm3112: bit_vector(19 downto 0);
        variable imm20: bit;
        variable imm101: bit_vector(9 downto 0);
        variable imm11J: bit;
        variable imm1912: bit_vector(7 downto 0);
        variable instrm: mnemonic_type;
        begin
            -- Initialize memory and SoC
            mem_temp <= init_mem;
            wait for 10 ns; -- Wait for memory initialization
            mem_tb_out <= mem_temp;
            
           

            -- Start the first instruction
            --Make the trace look nice
            write(l, trace_header);
            writeline(trace_f, l);
            test_loop: loop
                
                wait on cycle_SoC_end;
                -- Now do your trace/logging
                code    := instr_trace(6 downto 0);
                rd      := instr_trace(11 downto 7);
                rs1     := instr_trace(19 downto 15);
                rs2     := instr_trace(24 downto 20);
                funct3  := instr_trace(14 downto 12);
                funct7  := instr_trace(31 downto 25);
                imm110  := instr_trace(31 downto 20);
                imm115  := instr_trace(31 downto 25);
                imm40   := instr_trace(11 downto 7);
                imm40_I := instr_trace(24  downto 20); --TODO: check the imm
                imm12   := instr_trace(31);
                imm105  := instr_trace(30 downto 25);
                imm41   := instr_trace(11 downto 8);
                imm11B  := instr_trace(7);  -- exception naming
                imm3112 := instr_trace(31 downto 12);
                imm20   := instr_trace(31);
                imm101  := instr_trace(30 downto 21);
                imm11J  := instr_trace(20); -- exception naming
                imm1912 := instr_trace(19 downto 12);
                case code is
                    when OP =>
                        case funct3 is
                            when ADDf3 =>
                                case funct7 is
                                    when ADDf7 =>
                                        instrm := ADDm;
                                        -- Handle ADD instructions here
                                    when SUBf7 =>
                                        instrm := SUBm;
                                        -- Handle SUB instructions here
                                    when others =>
                                        report "Unknown funct7 for ADD: " & bitvec_to_bitstring(instr_trace);
                                        exit test_loop; -- Exit the loop on unknown funct7

                                end case;
                                -- Handle ADD instructions here
                                
                            when SLTf3 =>
                                instrm := SLTm;
                                -- Handle SLT instructions here
                            when SLTUf3 =>
                                instrm := SLTUm;
                                -- Handle SLTU instructions here
                            when ANDf3 =>
                                instrm := ANDm;
                                -- Handle AND instructions here
                            when ORf3 =>
                                instrm := ORm;
                                -- Handle OR instructions here
                            when XORf3 =>
                                instrm := XORm;
                                -- Handle XOR instructions here
                            when SLLf3 =>
                                instrm := SLLm;
                                -- Handle SLL instructions here
                            when SRL_Af3 =>
                                if(instr_trace(30) = '1') then
                                    instrm := SRAm;
                                else 
                                    instrm := SRLm; 
                                    -- Handle SRL instructions here
                                end if;
                            when others =>
                                    report "Unknown funct3 for OP instruction fetched: " & bitvec_to_bitstring(instr_trace);
                                    exit test_loop; -- Exit the loop on unknown funct3
                        end case;
                        trace_R(instrm, rd, rs1, rs2, PC_trace, regs_trace, trace_f);

                    when OPIMM =>
                    case funct3 is
                        when ADDf3 =>
                                instrm := ADDIm;
                                -- Handle ADD instructions here
                            
                            when SLTf3 =>
                                instrm := SLTIm;
                                -- Handle SLTI instructions here
                            when SLTUf3 =>
                                instrm := SLTIUm;
                                -- Handle SLTIU instructions here
                            when ANDf3 =>
                                instrm := ANDIm;
                                -- Handle ANDI instructions here
                            when ORf3 =>
                                instrm := ORIm;
                                -- Handle ORI instructions here
                            when XORf3 =>
                                instrm := XORIm;
                                -- Handle XORI instructions here
                            when SLLf3 =>
                                instrm := SLLIm;
                                -- Handle SLLI instructions here
                            when SRL_Af3 =>
                                if(instr_trace(30) = '1') then
                                    instrm := SRAIm;
                                    imm110(10) := '0'; --make the immediate accurate since SRAI is alradin in the mnemonic
                                    --TODO: Better solution for line above
                                    -- Handle SRAI instructions here
                                else
                                    instrm := SRLIm; 
                                    -- Handle SRLI instructions here
                                end if;
                                
                                -- Handle SRLI instructions here
                            when others =>
                                report "Unknown OPIMM instruction fetched: " & bitvec_to_bitstring(instr_trace);
                                exit test_loop; -- Exit the loop on unknown funct3
                        -- Handle OPIMM instructions here
                        end case;
                        trace_I(instrm, rd, rs1, imm110, PC_trace,regs_trace,trace_f);
                    when LOAD =>
                        report "LOAD instruction fetched: " & bitvec_to_bitstring(instr_trace);
                        -- Handle LOAD instructions here
                    when STORE =>
                        report "STORE instruction fetched: " & bitvec_to_bitstring(instr_trace);
                        -- Handle STORE instructions here
                    when BRANCH =>
                        report "BRANCH instruction fetched: " & bitvec_to_bitstring(instr_trace);
                        -- Handle BRANCH instructions here
                    when LUI =>
                        --report "LUI instruction fetched: " & bitvec_to_bitstring(instr_trace);
                        instrm := LUIm;
                        trace_U(instrm, rd, imm3112, PC_trace, regs_trace, trace_f);
                        -- Handle LUI instructions here
                    when AUIPC =>
                        --report "AUIPC instruction fetched: " & bitvec_to_bitstring(instr_trace);
                        -- Handle AUIPC instructions here
                        instrm := AUIPCm;
                        trace_U(instrm, rd, imm3112, PC_trace, regs_trace, trace_f);
                    when JAL =>
                        report "JAL instruction fetched: " & bitvec_to_bitstring(instr_trace);
                        -- Handle JAL instructions here
                    when others =>
                        report "Unknown instruction fetched, exiting testbench: " & bitvec_to_bitstring(instr_trace);
                        exit test_loop; -- Exit the loop on unknown instruction

                end case;
                report "Trace done";

                -- Trigger SoC to execute next instruction
               
            end loop;

            dump_memory(dump_path, mem_tb_out);
            file_close(trace_f);
            file_close(dump_f);
            report "Testbench completed.";
            wait;
        end process;

end architecture;