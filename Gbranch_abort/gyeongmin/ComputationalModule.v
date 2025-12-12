// ========== GATE-LEVEL BUILDING BLOCKS ==========

// Full Adder (gate level)
module FullAdder(
    input A, B, Cin,
    output Sum, Cout
);
    wire w1, w2, w3;
    
    xor(w1, A, B);
    xor(Sum, w1, Cin);
    
    and(w2, A, B);
    and(w3, w1, Cin);
    or(Cout, w2, w3);
endmodule

// 8-bit Ripple Carry Adder (using Full Adders)
module RippleCarryAdder8(
    input [7:0] A, B,
    input Cin,
    output [7:0] Sum,
    output Cout
);
    wire c1, c2, c3, c4, c5, c6, c7;
    
    FullAdder fa0(.A(A[0]), .B(B[0]), .Cin(Cin), .Sum(Sum[0]), .Cout(c1));
    FullAdder fa1(.A(A[1]), .B(B[1]), .Cin(c1), .Sum(Sum[1]), .Cout(c2));
    FullAdder fa2(.A(A[2]), .B(B[2]), .Cin(c2), .Sum(Sum[2]), .Cout(c3));
    FullAdder fa3(.A(A[3]), .B(B[3]), .Cin(c3), .Sum(Sum[3]), .Cout(c4));
    FullAdder fa4(.A(A[4]), .B(B[4]), .Cin(c4), .Sum(Sum[4]), .Cout(c5));
    FullAdder fa5(.A(A[5]), .B(B[5]), .Cin(c5), .Sum(Sum[5]), .Cout(c6));
    FullAdder fa6(.A(A[6]), .B(B[6]), .Cin(c6), .Sum(Sum[6]), .Cout(c7));
    FullAdder fa7(.A(A[7]), .B(B[7]), .Cin(c7), .Sum(Sum[7]), .Cout(Cout));
endmodule

// 16-bit Ripple Carry Adder
module RippleCarryAdder16(
    input [15:0] A, B,
    input Cin,
    output [15:0] Sum,
    output Cout
);
    wire [14:0] carry;
    
    FullAdder fa0(.A(A[0]), .B(B[0]), .Cin(Cin), .Sum(Sum[0]), .Cout(carry[0]));
    FullAdder fa1(.A(A[1]), .B(B[1]), .Cin(carry[0]), .Sum(Sum[1]), .Cout(carry[1]));
    FullAdder fa2(.A(A[2]), .B(B[2]), .Cin(carry[1]), .Sum(Sum[2]), .Cout(carry[2]));
    FullAdder fa3(.A(A[3]), .B(B[3]), .Cin(carry[2]), .Sum(Sum[3]), .Cout(carry[3]));
    FullAdder fa4(.A(A[4]), .B(B[4]), .Cin(carry[3]), .Sum(Sum[4]), .Cout(carry[4]));
    FullAdder fa5(.A(A[5]), .B(B[5]), .Cin(carry[4]), .Sum(Sum[5]), .Cout(carry[5]));
    FullAdder fa6(.A(A[6]), .B(B[6]), .Cin(carry[5]), .Sum(Sum[6]), .Cout(carry[6]));
    FullAdder fa7(.A(A[7]), .B(B[7]), .Cin(carry[6]), .Sum(Sum[7]), .Cout(carry[7]));
    FullAdder fa8(.A(A[8]), .B(B[8]), .Cin(carry[7]), .Sum(Sum[8]), .Cout(carry[8]));
    FullAdder fa9(.A(A[9]), .B(B[9]), .Cin(carry[8]), .Sum(Sum[9]), .Cout(carry[9]));
    FullAdder fa10(.A(A[10]), .B(B[10]), .Cin(carry[9]), .Sum(Sum[10]), .Cout(carry[10]));
    FullAdder fa11(.A(A[11]), .B(B[11]), .Cin(carry[10]), .Sum(Sum[11]), .Cout(carry[11]));
    FullAdder fa12(.A(A[12]), .B(B[12]), .Cin(carry[11]), .Sum(Sum[12]), .Cout(carry[12]));
    FullAdder fa13(.A(A[13]), .B(B[13]), .Cin(carry[12]), .Sum(Sum[13]), .Cout(carry[13]));
    FullAdder fa14(.A(A[14]), .B(B[14]), .Cin(carry[13]), .Sum(Sum[14]), .Cout(carry[14]));
    FullAdder fa15(.A(A[15]), .B(B[15]), .Cin(carry[14]), .Sum(Sum[15]), .Cout(Cout));
endmodule

// 4-bit x 4-bit Multiplier (gate level using shift-and-add)
module Multiplier4x4(
    input [3:0] A, B,
    output [7:0] Product
);
    // Partial products
    wire [3:0] pp0, pp1, pp2, pp3;
    
    // Generate partial products using AND gates
    and(pp0[0], A[0], B[0]);
    and(pp0[1], A[1], B[0]);
    and(pp0[2], A[2], B[0]);
    and(pp0[3], A[3], B[0]);
    
    and(pp1[0], A[0], B[1]);
    and(pp1[1], A[1], B[1]);
    and(pp1[2], A[2], B[1]);
    and(pp1[3], A[3], B[1]);
    
    and(pp2[0], A[0], B[2]);
    and(pp2[1], A[1], B[2]);
    and(pp2[2], A[2], B[2]);
    and(pp2[3], A[3], B[2]);
    
    and(pp3[0], A[0], B[3]);
    and(pp3[1], A[1], B[3]);
    and(pp3[2], A[2], B[3]);
    and(pp3[3], A[3], B[3]);
    
    // Add partial products using full adders
    wire [7:0] sum1, sum2, sum3;
    wire c1, c2, c3, c4, c5, c6;
    
    // Layer 1: Add pp0 and pp1 (shifted left by 1)
    assign sum1[0] = pp0[0];
    FullAdder fa1_0(.A(pp0[1]), .B(pp1[0]), .Cin(1'b0), .Sum(sum1[1]), .Cout(c1));
    FullAdder fa1_1(.A(pp0[2]), .B(pp1[1]), .Cin(c1), .Sum(sum1[2]), .Cout(c2));
    FullAdder fa1_2(.A(pp0[3]), .B(pp1[2]), .Cin(c2), .Sum(sum1[3]), .Cout(c3));
    FullAdder fa1_3(.A(1'b0), .B(pp1[3]), .Cin(c3), .Sum(sum1[4]), .Cout(sum1[5]));
    assign sum1[6] = 1'b0;
    assign sum1[7] = 1'b0;
    
    // Layer 2: Add sum1 and pp2 (shifted left by 2)
    assign sum2[0] = sum1[0];
    assign sum2[1] = sum1[1];
    FullAdder fa2_0(.A(sum1[2]), .B(pp2[0]), .Cin(1'b0), .Sum(sum2[2]), .Cout(c4));
    FullAdder fa2_1(.A(sum1[3]), .B(pp2[1]), .Cin(c4), .Sum(sum2[3]), .Cout(c5));
    FullAdder fa2_2(.A(sum1[4]), .B(pp2[2]), .Cin(c5), .Sum(sum2[4]), .Cout(c6));
    FullAdder fa2_3(.A(sum1[5]), .B(pp2[3]), .Cin(c6), .Sum(sum2[5]), .Cout(sum2[6]));
    assign sum2[7] = 1'b0;
    
    // Layer 3: Add sum2 and pp3 (shifted left by 3)
    assign Product[0] = sum2[0];
    assign Product[1] = sum2[1];
    assign Product[2] = sum2[2];
    FullAdder fa3_0(.A(sum2[3]), .B(pp3[0]), .Cin(1'b0), .Sum(Product[3]), .Cout(c1));
    FullAdder fa3_1(.A(sum2[4]), .B(pp3[1]), .Cin(c1), .Sum(Product[4]), .Cout(c2));
    FullAdder fa3_2(.A(sum2[5]), .B(pp3[2]), .Cin(c2), .Sum(Product[5]), .Cout(c3));
    FullAdder fa3_3(.A(sum2[6]), .B(pp3[3]), .Cin(c3), .Sum(Product[6]), .Cout(Product[7]));
    
endmodule

// ========== COMPUTATIONAL MODULE ==========
// Simple module that computes dot product of two 8-element vectors
// Inputs: Two 4-bit values at a time
// Output: 16-bit accumulated result
module ComputationalModule(
    input CLK,
    input RESET,
    input ENABLE,           // Enable computation
    input [3:0] elemA,      // Element from vector A
    input [3:0] elemB,      // Element from vector B
    output reg DONE,
    output reg [15:0] result
);
    reg [2:0] count;         // Counter for 8 elements
    reg [15:0] accumulator;  // Accumulator for dot product
    wire [7:0] product;      // Current multiplication result
    wire [15:0] sum;         // Sum of accumulator + product
    wire cout;
    
    // Instantiate 4-bit multiplier
    Multiplier4x4 mult(
        .A(elemA),
        .B(elemB),
        .Product(product)
    );
    
    // Instantiate 16-bit adder
    RippleCarryAdder16 adder(
        .A(accumulator),
        .B({8'b0, product}),
        .Cin(1'b0),
        .Sum(sum),
        .Cout(cout)
    );
    
    always @(posedge CLK or posedge RESET) begin
        if (RESET) begin
            count <= 0;
            accumulator <= 16'b0;
            result <= 16'b0;
            DONE <= 0;
        end
        else if (ENABLE) begin
            if (count < 8) begin
                // Multiply and accumulate
                accumulator <= sum;
                count <= count + 1;
                DONE <= 0;
                
                // On the last element, set DONE
                if (count == 7) begin
                    DONE <= 1;
                    result <= sum;
                end
            end
        end
    end
endmodule