module fourbit_multiplier(
    input [4-1:0] a, b,
    output [8-1:0] out
    );
    wire [16-1:0] _and_temp;
    wire [8-1:0]   _add_temp;
    wire [3-1:0]   _dump_v;
    
    and (      out[0],  a[0], b[0]);
    and (_and_temp[1],  a[0], b[1]);
    and (_and_temp[2],  a[0], b[2]);
    and (_and_temp[3],  a[0], b[3]);
    and (_and_temp[4],  a[1], b[0]);
    and (_and_temp[5],  a[1], b[1]);
    and (_and_temp[6],  a[1], b[2]);
    and (_and_temp[7],  a[1], b[3]);
    
    and ( _and_temp[8], a[2], b[0]);
    and ( _and_temp[9], a[2], b[1]);
    and (_and_temp[10], a[2], b[2]);
    and (_and_temp[11], a[2], b[3]);
    and (_and_temp[12], a[3], b[0]);
    and (_and_temp[13], a[3], b[1]);
    and (_and_temp[14], a[3], b[2]);
    and (_and_temp[15], a[3], b[3]);
    
    fourbit_adder_subtractor ffa0(
        {1'b0, _and_temp[3:1]}, _and_temp[7:4], 1'b0, 
        {_add_temp[2:0], out[1]}, _add_temp[3], _dump_v[0]);
    fourbit_adder_subtractor ffa1( 
        _add_temp[3:0], _and_temp[11:8], 1'b0, 
        {_add_temp[6:4], out[2]}, _add_temp[7], _dump_v[1]);
    fourbit_adder_subtractor ffa2(
        _add_temp[7:4], _and_temp[15:12], 1'b0, 
        out[6:3], out[7], _dump_v[2]);
endmodule
