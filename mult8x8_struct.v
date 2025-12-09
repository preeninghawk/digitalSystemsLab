
module mult8x8_struct(
    input  [7:0] a,
    input  [7:0] b,
    output [15:0] p
);
    wire [3:0] al = a[3:0];
    wire [3:0] ah = a[7:4];
    wire [3:0] bl = b[3:0];
    wire [3:0] bh = b[7:4];

    wire [7:0] p0, p1, p2, p3;

    fourbit_multiplier m0(.a(al), .b(bl), .out(p0));
    fourbit_multiplier m1(.a(al), .b(bh), .out(p1));
    fourbit_multiplier m2(.a(ah), .b(bl), .out(p2));
    fourbit_multiplier m3(.a(ah), .b(bh), .out(p3));

    wire [7:0] s1;
    wire       c1;
    adder8_fa add8_0(
        .a   (p1),
        .b   (p2),
        .sum (s1),
        .cout(c1)
    );

    wire [15:0] term0 = {8'd0, p0};
    wire [15:0] term1 = {4'd0, s1, 4'd0};
    wire [15:0] term2 = {p3, 8'd0};

    wire [15:0] temp;
    wire        ctemp, c2;

    adder16_fa add16_0(.a(term0), .b(term1), .sum(temp), .cout(ctemp));
    adder16_fa add16_1(.a(temp),  .b(term2), .sum(p),    .cout(c2));

endmodule
