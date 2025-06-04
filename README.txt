***BoriSoC, Independant/University project***
    -RV32I functional model
    -BUILTIN Testbench and Assembly compiler
    -Test programs

**NOTES**
    - Had to make an artifical clock to have the testbench independent of the SoC

**HOW TO OPERATE**
    -from console run: vivado -mode batch -source sim.tcl
    -Test programs are in the test folder
    -The program to be tested is called textin.text
    -The outputs are the TRACE and DUMP in the trace.txt and dump.txt files respecivelty
        -Note: all mentioned files have to already exist, they will NOT be created by the testbench
    -Some debugging reports have been left
    

**GREAT TODOs: **
    - labels to assemblty preproccesor -- to hard
        -that also means decoding signed stuff, idk
        - also in trace with imm shift instructions 400 is added to imm because of the instr(30) determening bit
        
    -TO add an instruction, you need to add it to the soc, the IO_pack both for input and output
        - new mnemonic in the mnemonic_pack
        - new opcode defs in the def_pac...
