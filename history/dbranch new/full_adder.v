module full_adder(
    input a, b, cin,
    output reg s, cout
    );
    reg [2-1:0] _cout;
    reg _s;
    /* If you want to design combinational circuit
        using behavioral modeling, 
        please use ‘blocking’ assignment like this!  */
    always @ (*) begin
        _s          = a ^ b;
        _cout[0] = a & b;
        s            = _s ^ cin;
        _cout[1] = _s & cin;
        cout       = _cout[0] | _cout[1];
    end
endmodule
