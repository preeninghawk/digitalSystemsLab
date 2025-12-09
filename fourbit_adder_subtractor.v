module fourbit_adder_subtractor(
    input   [4-1:0] a, b,
    input   M,	// 0 -> addition, 1 -> subtraction
    output [4-1:0] s,
    output cout, v
    );
    wire [4-1:0] _xb;
    wire [3-1:0] _cout;
    
    xor (_xb[0], b[0], M);
    xor (_xb[1], b[1], M);
    xor (_xb[2], b[2], M);
    xor (_xb[3], b[3], M);
    
    full_adder fa0( a[0], _xb[0],        M,    s[0], _cout[0]);
    full_adder fa1( a[1], _xb[1], _cout[0], s[1], _cout[1]);
    full_adder fa2( a[2], _xb[2], _cout[1], s[2], _cout[2]);
    full_adder fa3( a[3], _xb[3], _cout[2], s[3],       cout);
    
    xor (v, cout, _cout[2]);
endmodule
