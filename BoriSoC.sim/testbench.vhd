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

    constant trace_path : string := "../../../../tests/trace.txt";
    constant dump_path : string := "../../../../tests/dump.txt";
    constant textin_path : string := "../../../../tests/textin.txt";
    signal mem_tb_in: mem_type;
    signal mem_tb_out: mem_type;
    signal instr_trace: instr_type;
    signal PC_trace: pc_type;

    signal mem_temp: mem_type;



    
    

    

    file trace_f : text open write_mode is trace_path;
    file dump_f  : text open write_mode is dump_path;
    component SoC
            port(
                mem_in: in mem_type;
                mem_out: out mem_type;
                instr_out: out instr_type;
                PC_out: out pc_type

            );
    end component;
    begin
        

        UUT: entity work.SoC
        port map (
            mem_in   => mem_tb_out,
            mem_out => mem_tb_in,
            instr_out => instr_trace,
            PC_out    => PC_trace
        );

        process 
        
        

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
        variable imm3111: bit_vector(19 downto 0);
        variable imm20: bit;
        variable imm101: bit_vector(9 downto 0);
        variable imm11J: bit;
        variable imm1912: bit_vector(7 downto 0);
        variable instrm: mnemonic_type;
        begin
            --Assign the instruction parts for easy use
            -- Initialize memory with the text file
            mem_temp <= init_mem;
            wait on mem_temp; -- Allow some time for the memory to initialize
            wait for 10 ns; -- Wait for the memory to stabilize
            mem_tb_out <= mem_temp;
            test_loop:loop
                report "Waiting for instruction trace...";
                wait on instr_trace;
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
                imm3111 := instr_trace(31 downto 12);
                imm20   := instr_trace(31);
                imm101  := instr_trace(30 downto 21);
                imm11J  := instr_trace(20); -- exception naming
                imm1912 := instr_trace(19 downto 12);
                case code is
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
                                instrm := SRLIm;
                                -- Handle SRLI instructions here
                            when others =>
                                report "Unknown OPIMM instruction fetched: " & bitvec_to_bitstring(instr_trace);
                                exit test_loop; -- Exit the loop on unknown funct3
                        -- Handle OPIMM instructions here
                        end case;
                        trace_OPIMM(instrm, rd, rs1, imm110, PC_trace,trace_f);
                    when OP =>
                        report "OP instruction fetched: " & bitvec_to_bitstring(instr_trace);
                        -- Handle OP instructions here
                    when LOAD =>
                        report "LOAD instruction fetched: " & bitvec_to_bitstring(instr_trace);
                        -- Handle LOAD instructions here
                    when STORE =>
                        report "STORE instruction fetched: " & bitvec_to_bitstring(instr_trace);
                        -- Handle STORE instructions here
                    when BRANCH =>
                        report "BRANCH instruction fetched: " & bitvec_to_bitstring(instr_trace);
                        -- Handle BRANCH instructions here
                    when JARL =>
                        report "JALR instruction fetched: " & bitvec_to_bitstring(instr_trace);
                        -- Handle JALR instructions here
                    when JAL =>
                        report "JAL instruction fetched: " & bitvec_to_bitstring(instr_trace);
                        -- Handle JAL instructions here
                    when others =>
                        report "Unknown instruction fetched, exiting: " & bitvec_to_bitstring(instr_trace);
                        exit test_loop; -- Exit the loop on unknown instruction

                end case;
                
            end loop;
            wait for 10 ns; -- Allow some time for the last instruction to be processed
            --wait on mem_tb_out;
            dump_memory(dump_path, mem_tb_out);
            file_close(trace_f);
            file_close(dump_f);
            report "Testbench completed.";
            WAIT;
        end process;

end architecture;