
use WORK.def_pack;

package IO_pack is


end package;

package body IO_pack is
    --we need to build  a parser
    ###
    function parse(filename:string) return mem_type is
        variable l: line;
        variable f: file text is in filename;
        variable scs: boolean := False;
        variable w: string(0 to 49);
        variable curraddr: addr_type := X"0000";
        begin
        
        loop_lable: loop
            exit when endfile(f);
                readline(f,l);
                scs := True;
                line_loop: while rl loop
                    read(l,w(0),scs);
                    if(w(0) = '@') then -- line syntax: @0x0000
                        read(l,cur_addr,scs); -- this is not guaranteed to work.
                    elsif (expression) then
                    
                    end if;
                end loop;
                

        exit loop;

    end function;
end package body;