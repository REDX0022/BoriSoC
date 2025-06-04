library STD;
use STD.TEXTIO.all;

library WORK;
use WORK.def_pack.all;
use WORK.mnemonic_pack.all;

library IEEE;
--use IEEE.NUMERIC_STD.all;
use IEEE.NUMERIC_BIT.all;


package IO_pack is
    subtype token_type is string(1 to 10); --this might be in the def_pack
    type tokens_type is array(0 to 10) of token_type;
    type tokens_len_type is array(0 to 10) of integer;

    impure function tokenize(filepath: string; mem: mem_type) return mem_type;
    procedure parse_line(tokens: tokens_type; tokens_len: tokens_len_type; token_count : integer; mem: inout mem_type; curr_addr: inout addr_type);
    procedure put_instr(mem: inout mem_type; curr_addr: in addr_type; instr: in instr_type);
    procedure dump_memory(filename: in string; mem: in mem_type);

    procedure get_next_token(l: inout line; max_len: in integer; token: out token_type; token_len: out integer; end_of_line: out boolean);
    procedure trace_R(opcodem : mnemonic_type; rd: reg_addr_type; rs1: reg_addr_type; rs2: reg_addr_type; PC: addr_type; regs: regs_type; f: inout text);
    procedure trace_I(opcodem: mnemonic_type; rd: reg_addr_type; rs1: reg_addr_type; imm110: bit_vector(11 downto 0); PC: addr_type;regs: regs_type; f: inout text);
    procedure trace_U(opcodem : mnemonic_type; rd: reg_addr_type; imm3112 : bit_vector(19 downto 0); PC: addr_type; regs: regs_type; f: inout text);
    procedure trace_B(opcodem: mnemonic_type; imm11_B: bit; imm41: bit_vector(3 downto 0); rs1: reg_addr_type; rs2: reg_addr_type; imm105: bit_vector(5 downto 0); imm12: bit; PC_trace: addr_type; regs: regs_type; f: inout text);
    procedure trace_S(opcodem: mnemonic_type; imm40: bit_vector(4 downto 0); rs1: reg_addr_type; rs2: reg_addr_type; imm115: bit_vector(6 downto 0); PC_trace: addr_type; regs: regs_type; f: inout text);
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

        variable end_of_line : boolean := false;
        variable token : token_type;
        variable token_len : integer;

        begin
        ---------------------------------Tokenisation------------------
        line_loop: loop
            exit when endfile(f);
            readline(f, l);
            token_count := 0;
            tokens := (others => "          ");
            tokens_len := (others => 0);
            end_of_line := false;
            -- Use get_next_token to extract tokens from the line

            while not end_of_line loop
                get_next_token(l, 10, token, token_len, end_of_line);
                if token_len > 0 then
                    tokens(token_count) := token;
                    tokens_len(token_count) := token_len;
                    token_count := token_count + 1;
                end if;
            end loop;
            

            -- Debug reports (optional)
            --report "A number of tokens was found" & integer'image(token_count);
            
            --report tokens(0)(1 to tokens_len(0)) & 'S';
            ----report tokens(1)(1 to tokens_len(1)) & "S";
            --report tokens(2)(1 to tokens_len(2)) &"S";
            --report tokens(3)(1 to tokens_len(3)) & "S";

            -- Now we have tokens
            parse_line(tokens, tokens_len, token_count, mem_res, curr_addr);
        end loop;
        return mem_res;
    end function;
    -- Procedure to extract the next token from a line
    procedure get_next_token(l: inout line;max_len: in integer; token: out token_type; token_len: out integer; end_of_line: out boolean) is
        variable ch : character := ' ';
        variable idx : integer := 1;
        variable scs : boolean := true;
    begin
        token := (others => ' ');
        token_len := 0;
        end_of_line := false;

        -- Skip leading spaces and control chars
        while l'length > 0 loop
            read(l, ch, scs);
            exit when not scs or ((ch /= ' ') and (ch /= CR)); -- skip spaces and CR
        end loop;

        -- If we exited because we found a non-space/control character, use it as the first token character
        if scs and (ch /= ' ') and (ch /= ';') and (ch /= CR) then
            token(idx) := ch;
            idx := idx + 1;
            -- Read the rest of the token
            while (l'length > 0) and (idx <= max_len) loop
                read(l, ch, scs);
                exit when (not scs) or (ch = ' ') or (ch = ';') or  (ch = CR);
                token(idx) := ch;
                idx := idx + 1;
            end loop;
            token_len := idx - 1;
        else
            token_len := 0;
        end if;

        -- Check if we hit end of line or comment
        if (l'length = 0) or (ch = ';') or (ch = character'val(13)) then
            end_of_line := true;
        end if;
    end procedure;


    procedure parse_line(tokens: tokens_type; tokens_len: tokens_len_type; token_count: integer; mem: inout mem_type; curr_addr: inout addr_type) is
        variable instr: instr_type := X"00000000"; --we will build the instruction here
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
        variable imm11_B: bit;
        variable imm3112: bit_vector(19 downto 0);
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
                        --report "Put VAL @" & bitvec_to_hex_string(curr_addr);    
                        mem(bv_to_integer(curr_addr)) := hexstring_to_bitvec(tokens(i)(1 to tokens_len(i)));
                        curr_addr := slice_msb(curr_addr+X"0001");
                        
                    end loop;
            --TODO: Add support for signed literals, for now everything is the same
            when ADDIm | SLTIm | SLTIUm | ANDIm | ORIm | XORIm => --TODO: check aligmnment with XALLIGN, 
                        
                    
                    code := OPIMM;
                    case tokens(0)(1 to 6) is
                        when ADDIm => funct3 := ADDf3;
                        when SLTIm => funct3 := SLTf3;
                        when SLTIUm => funct3 := SLTUf3;
                        when ANDIm => funct3 := ANDf3;
                        when ORIm => funct3 := ORf3;
                        when XORIm => funct3 := XORf3;
                        when others => report "Found illegal mnemonic in OPIMM";
                    end case;
                    rd := decode_regm(tokens(1)(1 to tokens_len(1)));
                    rs1 := decode_regm(tokens(2)(1 to tokens_len(2)));
                    imm110 := hexstring_to_bitvec(tokens(3)(1 to tokens_len(3)));
                    instr := construct_I(code,rd,funct3,rs1,imm110);
                    put_instr(mem, curr_addr, instr);
                    curr_addr := slice_msb(curr_addr+ X"0004"); --instr is 4 bytes
            when SLLIm | SRLIm | SRAIm =>
                    code := OPIMM;
                    case tokens(0)(1 to 6) is
                        when SLLIm => funct3 := SLLf3;
                        when SRLIm => 
                            funct3 := SRL_Af3; 
                            imm110(11 downto 5) := "0000000";
                        when SRAIm => 
                            funct3 := SRL_Af3; 
                            imm110(11 downto 5) := "0100000";
                        when others => report "Found illegal mnemonic in OPIMM shift"; --this should also never happen
                    end case;
                    rd := decode_regm(tokens(1)(1 to tokens_len(1)));
                    rs1 := decode_regm(tokens(2)(1 to tokens_len(2)));
                    imm110(4 downto 0):= hexstring_to_bitvec(tokens(3)(1 to tokens_len(3)))(4 downto 0); -- Bound to hexstring_to_bitvec implementation 
                    instr := construct_I(code,rd,funct3,rs1,imm110); -- still no support for signed literals
                    put_instr(mem, curr_addr, instr);
                    curr_addr := slice_msb(curr_addr+ X"0004"); --instr is 4 bytes
            when LUIm | AUIPCm =>
                    -- LUI and AUIPC are similar, so we can handle them together
                    case tokens(0)(1 to 6) is
                        when LUIm => 
                            code := LUI;
                        when AUIPCm => 
                            code := AUIPC;
                        when others => report "Found illegal mnemonic in LUI/AUIPC"; --NEVER HAPPENS
                    end case;
                    rd := decode_regm(tokens(1)(1 to tokens_len(1)));
                    imm3112 := hexstring_to_bitvec(tokens(2)(1 to tokens_len(2)));
                    instr := construct_U(code, rd, imm3112);
                    put_instr(mem, curr_addr, instr);
                    curr_addr := slice_msb(curr_addr+ X"0004"); --instr is 4 bytes
            when ADDm | SUBm | SLTm | SLTUm | ANDm | ORm | XORm | SLLm | SRLm | SRAm=>
                    code := OP;
                    case tokens(0)(1 to 6) is
                        when ADDm => funct3 := ADDf3; funct7 := "0000000";
                        when SUBm => funct3 := ADDf3; funct7 := "0100000"; -- this is a special case
                        when SLTm => funct3 := SLTf3; funct7 := "0000000";
                        when SLTUm => funct3 := SLTUf3; funct7 := "0000000";
                        when ANDm => funct3 := ANDf3; funct7 := "0000000";
                        when ORm => funct3 := ORf3; funct7 := "0000000";
                        when XORm => funct3 := XORf3; funct7 := "0000000";
                        when SLLm => funct3 := SLLf3; funct7 := "0000000";
                        when SRLm => funct3 := SRL_Af3; funct7 := "0000000"; -- this is a special case
                        when SRAm => funct3 := SRL_Af3; funct7 := "0100000"; -- this is a special case
                        when others => 
                            report "Found illegal mnemonic in OP"; --NEVER HAPPENS
                         
                    end case;
                    rd := decode_regm(tokens(1)(1 to tokens_len(1)));
                    rs1 := decode_regm(tokens(2)(1 to tokens_len(2)));
                    rs2 := decode_regm(tokens(3)(1 to tokens_len(3)));
                    instr := construct_R(code, rd, funct3, rs1, rs2, funct7);
                    put_instr(mem, curr_addr, instr);
                    curr_addr := slice_msb(curr_addr+ X"0004"); --instr is 4 bytes
            when JALm =>
                    code := JAL;
                    rd := decode_regm(tokens(1)(1 to tokens_len(1)));
                    imm3112 := hexstring_to_bitvec(tokens(2)(1 to tokens_len(2)));
                    instr := construct_U(code, rd, imm3112);
                    put_instr(mem, curr_addr, instr);
                    curr_addr := slice_msb(curr_addr+ X"0004"); --instr is 4 bytes
            when JALRm =>
                    code := JALR;
                    rd := decode_regm(tokens(1)(1 to tokens_len(1)));
                    rs1 := decode_regm(tokens(2)(1 to tokens_len(2)));
                    imm110 := hexstring_to_bitvec(tokens(3)(1 to tokens_len(3)));
                    instr := construct_I(code, rd, JALRf3, rs1, imm110);
                    put_instr(mem, curr_addr, instr);
                    curr_addr := slice_msb(curr_addr+ X"0004"); --instr is 4 bytes
            when BEQm | BNEm | BLTm | BGEm | BLTUm | BGEUm =>
                    code := BRANCH;
                    case tokens(0)(1 to 6) is
                        when BEQm => funct3 := BEQf3;
                        when BNEm => funct3 := BNEf3;
                        when BLTm => funct3 := BLTf3;
                        when BGEm => funct3 := BGEf3;
                        when BLTUm => funct3 := BLTUf3;
                        when BGEUm => funct3 := BGEUf3;
                        when others => 
                            report "Found illegal mnemonic in BRANCH";
                            
                    end case;
                    rs1 := decode_regm(tokens(1)(1 to tokens_len(1)));
                    rs2 := decode_regm(tokens(2)(1 to tokens_len(2)));
                    imm110 := hexstring_to_bitvec(tokens(3)(1 to tokens_len(3))); --this is the comnbined imm, not the actuall 110 just was conveient
                    instr := construct_B(code, funct3, rs1, rs2, imm110);
                    put_instr(mem, curr_addr, instr);
                    curr_addr := slice_msb(curr_addr+ X"0004"); --instr is 4 bytes
            when LBm | LBUM | LHm | LHUIm | LWm =>
                    code := LOAD;
                    case tokens(0)(1 to 6) is
                        when LBm => funct3 := LBF3;
                        when LBUM => funct3 := LBUF3;
                        when LHm => funct3 := LHF3;
                        when LHUIm => funct3 := LHUf3;
                        when LWm => funct3 := LWF3;
                        when others => 
                            report "Found illegal mnemonic in LOAD";
                            
                    end case;
                    rd := decode_regm(tokens(1)(1 to tokens_len(1)));
                    rs1 := decode_regm(tokens(2)(1 to tokens_len(2)));
                    imm110 := hexstring_to_bitvec(tokens(3)(1 to tokens_len(3)));
                    instr := construct_I(code, rd, funct3, rs1, imm110);
                    put_instr(mem, curr_addr, instr);
                    curr_addr := slice_msb(curr_addr+ X"0004"); --instr is 4 bytes
            when SBm | SHm | SWm =>
                    code := STORE;
                    case tokens(0)(1 to 6) is
                        when SBm => funct3 := SBF3;
                        when SHm => funct3 := SHF3;
                        when SWm => funct3 := SWF3;
                        when others => 
                            report "Found illegal mnemonic in STORE";
                            
                    end case;
                    rs2 := decode_regm(tokens(1)(1 to tokens_len(1)));
                    rs1 := decode_regm(tokens(2)(1 to tokens_len(2)));
                    imm110 := hexstring_to_bitvec(tokens(3)(1 to tokens_len(3)));
                    instr := construct_S(code, funct3, rs1, rs2, imm110);
                    put_instr(mem, curr_addr, instr);
                    curr_addr := slice_msb(curr_addr+ X"0004"); --instr is 4 bytes



                        
            when others =>
                    report "Found illegal/comment line line";
                   
        end case;
        

                
        end procedure;

    procedure put_instr(mem: inout mem_type; curr_addr: in addr_type; instr: in instr_type) is
        begin
            mem(bv_to_integer(curr_addr)) := instr(7 downto 0);
            mem(bv_to_integer(curr_addr)+1) := instr(15 downto 8);
            mem(bv_to_integer(curr_addr)+2) := instr(23 downto 16);
            mem(bv_to_integer(curr_addr)+3) := instr(31 downto 24);
            
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
                else
                    write(outline, " @ " & bitvec_to_hex_string(slice_msb(bit_vector(to_signed(i, 32)) + X"FFFD"))(5 to 8) & ": "); -- will break for 32 bit addresses, but we dont use them

                end if;
                end loop;
                
        if outline'length > 0 then
            writeline(outfile, outline);
        end if;
        file_close(outfile);
    end procedure;


    -----------------------------------------------Tracing-----------------------------------

    procedure trace_R(opcodem: mnemonic_type; rd: reg_addr_type; rs1: reg_addr_type; rs2: reg_addr_type; PC: addr_type; regs: regs_type; f: inout text) is
        variable l: line := null;
        begin
            write(l, opcodem & ' ');
            write(l, decode_reg_addr(rd) & ' ');
            write(l, decode_reg_addr(rs1) & ' ');
            write(l, decode_reg_addr(rs2) & " @ ");
            write(l, bitvec_to_hex_string(PC) & ' ');
            for i in regs'range loop
                --write(l, "x" & integer'image(i) & ": "); this will be in the header
                write(l, bitvec_to_hex_string(regs(i)) & ' ');
            end loop;
            writeline(f, l);
    end procedure;

    procedure trace_I(opcodem: mnemonic_type; rd: reg_addr_type; rs1: reg_addr_type; imm110: bit_vector(11 downto 0); PC : addr_type; regs: regs_type; f: inout text) is
        variable l: line := null;
    begin
        
        
        write(l, opcodem & ' ');
        write(l, decode_reg_addr(rd) & ' ');
        write(l, decode_reg_addr(rs1) & ' ');
        write(l, bitvec_to_hex_string(imm110) & " @ ");
        write(l, bitvec_to_hex_string(PC) & ' ');
        for i in regs'range loop
            --write(l, "x" & integer'image(i) & ": "); this will be in the header
            write(l, bitvec_to_hex_string(regs(i)) & ' ');
           
        end loop;
        
        writeline(f, l);
    end procedure;

    procedure trace_U(opcodem: mnemonic_type; rd: reg_addr_type; imm3112: bit_vector(19 downto 0); PC : addr_type; regs: regs_type; f: inout text) is
        variable l: line := null;
        begin
        write(l, opcodem & ' ');
        write(l, decode_reg_addr(rd) & ' ');
        write(l, bitvec_to_hex_string(imm3112) & "   @ ");
        write(l, bitvec_to_hex_string(PC) & ' ');
        for i in regs'range loop
            --write(l, "x" & integer'image(i) & ": "); this will be in the header
            write(l, bitvec_to_hex_string(regs(i)) & ' ');
        end loop;
        writeline(f, l);
    end procedure;

    procedure trace_B(opcodem: mnemonic_type; imm11_B: bit; imm41: bit_vector(3 downto 0); rs1: reg_addr_type; rs2: reg_addr_type; imm105: bit_vector(5 downto 0); imm12: bit;PC_trace:addr_type ;regs: regs_type; f: inout text) is
        variable l: line := null;
        --variable imm41r : bit_vector(0 to 3) := imm41; 
        begin
            write(l, opcodem & ' ');
            write(l, decode_reg_addr(rs1) & ' ');
            write(l, decode_reg_addr(rs2) & ' ');
            
            write(l, bitvec_to_hex_string(imm11_B & reverse(imm41) & reverse(imm105) & imm12) & " @ "); --TODO: check why this messes up or not bcs its changed rerun texin_BRANCH
            write(l, bitvec_to_hex_string(PC_trace) & ' ');
            for i in regs'range loop
                --write(l, "x" & integer'image(i) &x ": "); this will be in the header
                write(l, bitvec_to_hex_string(regs(i)) & ' ');
            end loop;
            writeline(f, l);
            end procedure;

    procedure trace_S(opcodem: mnemonic_type; imm40: bit_vector(4 downto 0); rs1: reg_addr_type; rs2: reg_addr_type; imm115: bit_vector(6 downto 0) ;PC_trace: addr_type; regs: regs_type; f: inout text) is
        variable l: line := null;
        begin
            write(l, opcodem & ' ');
            write(l, decode_reg_addr(rs1) & ' ');
            write(l, decode_reg_addr(rs2) & ' ');
            write(l, bitvec_to_hex_string(imm115 & imm40) & " @ ");
            write(l, bitvec_to_hex_string(PC_trace) & ' ');
            for i in regs'range loop
                --write(l, "x" & integer'image(i) & ": "); this will be in the header
                write(l, bitvec_to_hex_string(regs(i)) & ' ');
            end loop;
            writeline(f, l);
    end procedure;
            

      
    

    

    
end package body;