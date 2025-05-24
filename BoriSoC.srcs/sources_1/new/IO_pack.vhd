library STD;
use STD.TEXTIO.all;

library WORK;
use WORK.def_pack.all;
use WORK.mnemonic_pack.all;

library IEEE;


package IO_pack is
    subtype token_type is string(1 to 10); --this might be in the def_pack
    type tokens_type is array(0 to 10) of token_type;
    type tokens_len_type is array(0 to 10) of integer;

    impure function tokenize(filepath: string; mem: mem_type) return mem_type;
    procedure parse_line(tokens: tokens_type; tokens_len: tokens_len_type; token_count : integer; mem: inout mem_type; curr_addr: inout addr_type);
    procedure dump_memory(filename: in string; mem: in mem_type);
end package;


--we only support hex values here, so no need for 0x
package body IO_pack is
    --we need to build  a parser
    
    --TODO: implement better end of line rules, quite bad as it is reqires a space and then ; to work
    impure function tokenize(filepath: string; mem: mem_type) return mem_type is --vivado says we have to dillute the blodline(make in inpure)
        variable l: line;
        file f: text is in filepath;
        variable scs: boolean := False;
        variable tokens: tokens_type  := (others=>"          "); --no word should be longer than 10 chars, dont know where it might come up
        variable tokens_len: tokens_len_type := (others =>0);
        variable ch: character;
        variable w_count: integer:= 0;
        variable token_count: integer := 0;
        variable curr_instr: instr_type := X"00000000"; -- what do we do man
        variable mnemonic: mnemonic_type;

        
        variable mem_res: mem_type := mem;
        variable curr_addr: addr_type := X"0000"; --no point in being bitvector 


        begin
        ---------------------------------Tokenisation------------------
        line_loop: loop
            exit when endfile(f);
                readline(f,l);
                scs := True;
                 --actuall -1
                token_count:= 0;
                tokens := (others => "          ");
                token_loop: while scs=True loop  
                    w_count := 0;
                    char_loop: while scs=True loop --TODO: make this logic nicer
                        read(l,ch,scs); -- TODO: add asserts
                        --if it did not succeed then end word and line idk how tho, should be fine
                        if ((ch = ' ') AND (w_count>0)) then
                            exit char_loop;
                        elsif (ch = LF OR ch = CR OR ch = ';' OR not scs) then -- we remove the newline char and finish the token, this is getting messy
                            --tokens(token_count)(w_count) := ' ';
                            --tokens_len(token_count) := tokens_len(token_count) - 2; --no clue why it is -2 i guess its /n /r
                            exit char_loop;
                        elsif ch = ' ' then
                            --beggining of comment and end of line at the same time, 
                            next;
                        else
                            w_count := w_count+1;
                            tokens(token_count)(w_count) := ch;
                        end if;
                    end loop;
                    
                    if(w_count = 0) then --empty word therefore we have nothing more of value in this line
                        exit; --maybe not
                    else --this should be a valid word
                        tokens_len(token_count) := w_count;
                        token_count := token_count + 1;
                    end if; 
                end loop;
                report "A number of tokens was found" & integer'image(token_count);
                report tokens(0)(1 to tokens_len(0)) & 'S';
                report tokens(1)(1 to tokens_len(1)) & "S";
                report tokens(2)(1 to tokens_len(2)) &"S";
                report tokens(3)(1 to tokens_len(3)) & "S";
                --now we have tokens
                parse_line(tokens, tokens_len,token_count,mem_res,curr_addr);
        end loop;
        return mem_res;
    end function;


    procedure parse_line(tokens: tokens_type; tokens_len: tokens_len_type; token_count: integer; mem: inout mem_type; curr_addr: inout addr_type) is
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


        
        

        begin
        case tokens(0)(1 to 6) is --we compare to opcode mnemonics, less hardcode here myb
            when addr_identifierm =>
                    curr_addr := hexstring_to_bitvec(tokens(1)(1 to tokens_len(1)));
            when VALm => -- VAL CAN FILL AT MOST 10 BYTES, might want to offload it onto a function to be clearer
                    for i in 1 to token_count-1 loop
                        report "Put VAL @" & bitvec_to_hex_string(curr_addr);    
                        mem(bv_to_integer(curr_addr)) := hexstring_to_bitvec(tokens(i)(1 to tokens_len(i)));
                        curr_addr := slice_msb(curr_addr+X"0001");
                        
                    end loop;
            when ADDIm => --TODO: check aligmnment with XALLIGN
                    report "Put ADDI @" & bitvec_to_hex_string(curr_addr);
                    code := OPIMM;
                    funct3 := ADDf3;
                    rd := decode_regm(tokens(1)(1 to tokens_len(1)));
                    rs1 := decode_regm(tokens(2)(1 to tokens_len(2)));
                    imm110 := hexstring_to_bitvec(tokens(3)(1 to tokens_len(3)));
                    instr := construct_OPIMM(code,rd,funct3,rs1,imm110);
                    mem(bv_to_integer(curr_addr)) := instr(7 downto 0);
                    mem(bv_to_integer(curr_addr)+1) := instr(15 downto 8);
                    mem(bv_to_integer(curr_addr)+2) := instr(23 downto 16);
                    mem(bv_to_integer(curr_addr)+3) := instr(31 downto 24);
                    curr_addr := slice_msb(curr_addr+ X"0004"); --instr is 4 bytes
                    
            when others =>
                    report "Found illegal/comment line line";
        end case;
        

                
    end procedure;

    procedure dump_memory(filename: in string; mem: in mem_type) is
        file outfile : text;
        variable outline : line;
        variable byte_str : string(1 to 2);
    begin
        -- Explicitly open in write_mode to clear/truncate the file
        file_open(outfile, filename, write_mode);
        for i in mem'range loop
            if (i mod 4 = 0) then
                if i /= mem'low then
                    writeline(outfile, outline);
                end if;
                outline := null;
            end if;
            byte_str := bitvec_to_hex_string(mem(i));
            write(outline, byte_str);
            if (i mod 4 /= 3) then
                write(outline, string'(" "));
            end if;
        end loop;
        if outline'length > 0 then
            writeline(outfile, outline);
        end if;
        file_close(outfile);
    end procedure;

end package body;