
use WORK.def_pack;
use WORK.init_pack;

entity testbench is

end entity;

architecture TB of testbench is
    signal memstate: mem_type;
    signal dump: mem_type;
    signal trace: mem_type;
    begin
        component BorisSoC
            port(
                fileIN: in mem_type;
                dumpOUT: out mem_type;
                traceOUT: out mem_type; --here is mem_type used creatlivly because we dont have vairable length arrays in vhdl

            );
        end component;

        UUT: BoriSoC port map(
            fileIN => memstate;
            dump => dumpOUT;
            trace => traceOUT;


        );
        process 
        begin
            
        end process;

end architecture;