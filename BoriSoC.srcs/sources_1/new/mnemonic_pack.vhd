library WORK;
use WORK.def_pack.all;

--naming convention should be m suffix for mnemonic
--TODO: Finish the mnemonics
package mnemonic_pack is




    constant mnem_len: integer := 6;
    subtype mnemonic_type is string(1 to mnem_len);
    constant addr_identifierm: mnemonic_type := "@     ";
    constant VALm: mnemonic_type := "VAL   ";
    constant ADDIm: mnemonic_type := "ADDI  ";
    constant SLTIm: mnemonic_type := "SLTI  ";
    constant SLTIUm: mnemonic_type := "SLTIU ";
    constant ANDIm: mnemonic_type := "ANDI  ";
    constant ORIm: mnemonic_type := "ORI   ";
    constant XORIm: mnemonic_type := "XORI  ";
    constant SLLIm: mnemonic_type := "SLLI  ";
    constant SRLIm: mnemonic_type := "SRLI  ";
    constant SRAIm: mnemonic_type := "SRAI  ";

    constant LUIm: mnemonic_type := "LUI   ";

    constant AUIPCm: mnemonic_type := "AUIPC ";
    
    constant ADDm: mnemonic_type := "ADD   ";
    constant SUBm: mnemonic_type := "SUB   ";
    constant SLTm: mnemonic_type := "SLT   ";
    constant SLTUm: mnemonic_type := "SLTU  ";
    constant ANDm: mnemonic_type := "AND   ";
    constant ORm: mnemonic_type := "OR    ";
    constant XORm: mnemonic_type := "XOR   ";
    constant SLLm: mnemonic_type := "SLL   ";
    constant SRLm: mnemonic_type := "SRL   ";
    constant SRAm: mnemonic_type := "SRA   ";


    function construct_OP(opcode: opcode_type; rd: reg_addr_type; funct3 : funct3_type; rs1: reg_addr_type; rs2: reg_addr_type; funct7: funct7_type) return instr_type;
    function construct_OPIMM(opcode: opcode_type; rd: reg_addr_type; funct3 : funct3_type; rs1: reg_addr_type; imm110: bit_vector(11 downto 0)) return instr_type;
    function construct_LUI(opcode: opcode_type; rd: reg_addr_type; imm3112: bit_vector(19 downto 0)) return instr_type;
    function construct_AUIPC(opcode: opcode_type; rd: reg_addr_type; imm3112: bit_vector(19 downto 0)) return instr_type;
    function decode_regm(name : string) return reg_addr_type;
    function decode_reg_addr(addr : reg_addr_type) return string;
    end package;
    
    
    -- naming functinos after opcodes means there will be duplicates, but that is file for now 
package body mnemonic_pack is

    function construct_OP(opcode: opcode_type; rd: reg_addr_type; funct3 : funct3_type; rs1: reg_addr_type; rs2: reg_addr_type; funct7: funct7_type) return instr_type is
        begin
            return (funct7 & rs2 & rs1 & funct3 & rd & opcode);
    end function;

    function construct_OPIMM(opcode: opcode_type; rd: reg_addr_type; funct3 : funct3_type; rs1: reg_addr_type; imm110: bit_vector(11 downto 0)) return instr_type is
        begin
        return (imm110 & rs1 & funct3 & rd & opcode);
    end function;

    function construct_LUI(opcode: opcode_type; rd: reg_addr_type; imm3112: bit_vector(19 downto 0)) return instr_type is
       
        begin
            return (imm3112 & rd & opcode);
    end function;

    function construct_AUIPC(opcode: opcode_type; rd: reg_addr_type; imm3112: bit_vector(19 downto 0)) return instr_type is
        
        begin
            return (imm3112 & rd & opcode);
    end function;


    function decode_regm(name : string) return reg_addr_type is
        begin
        if name'length = 2 then
            case name is
                when "x0"  => return "00000";
                when "x1"  => return "00001";
                when "x2"  => return "00010";
                when "x3"  => return "00011";
                when "x4"  => return "00100";
                when "x5"  => return "00101";
                when "x6"  => return "00110";
                when "x7"  => return "00111";
                when "x8"  => return "01000";
                when "x9"  => return "01001";
                when others => report "Invalid register name: " & name severity error;
            end case;
        elsif name'length = 3 then
            case name is 
                when "x10" => return "01010";
                when "x11" => return "01011";
                when "x12" => return "01100";
                when "x13" => return "01101";
                when "x14" => return "01110";
                when "x15" => return "01111";
                when "x16" => return "10000";
                when "x17" => return "10001";
                when "x18" => return "10010";
                when "x19" => return "10011";
                when "x20" => return "10100";
                when "x21" => return "10101";
                when "x22" => return "10110";
                when "x23" => return "10111";
                when "x24" => return "11000";
                when "x25" => return "11001";
                when "x26" => return "11010";
                when "x27" => return "11011";
                when "x28" => return "11100";
                when "x29" => return "11101";
                when "x30" => return "11110";
                when "x31" => return "11111";
                when others => report "Invalid register name: " & name severity error;
            end case;
        else
            report "Invalid register name length: " & integer'image(name'length) severity error;
        end if;
        return  "00000";  -- return something to satisfy compiler
    end function;
 
    -- Function to decode a register address from a 5-bit binary string to its corresponding register name
    -- This function assumes the register addresses are in the range of "00000" to "11111"
    function decode_reg_addr(addr : reg_addr_type) return string is
        begin
            case addr is
                when "00000" => return "x0 ";
                when "00001" => return "x1 ";
                when "00010" => return "x2 ";
                when "00011" => return "x3 ";
                when "00100" => return "x4 ";
                when "00101" => return "x5 ";
                when "00110" => return "x6 ";
                when "00111" => return "x7 ";
                when "01000" => return "x8 ";
                when "01001" => return "x9 ";
                when "01010" => return "x10";
                when "01011" => return "x11";
                when "01100" => return "x12";
                when "01101" => return "x13";
                when "01110" => return "x14";
                when "01111" => return "x15";
                when "10000" => return "x16";
                when "10001" => return "x17";
                when "10010" => return "x18";
                when "10011" => return "x19";
                when "10100" => return "x20";
                when "10101" => return "x21";
                when "10110" => return "x22";
                when "10111" => return "x23";
                when "11000" => return "x24";
                when "11001" => return "x25";
                when "11010" => return "x26";
                when "11011" => return "x27";
                when "11100" => return "x28";
                when "11101" => return "x29";
                when "11110" => return "x30";
                when "11111" => return "x31";
                when others => report "Invalid register address: " & bitvec_to_bitstring(addr) severity error;
            end case;
            return "x0"; -- default return to satisfy compiler
        end function;
    
end package body;