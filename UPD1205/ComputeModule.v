// ========================================
// COMPUTATIONAL MODULE: DOT PRODUCT
// ========================================
module ComputeModule(
    input CLK,
    input START,                    // Start computation
    input [7:0] dataA,              // Input from vector A
    input [7:0] dataB,              // Input from vector B
    output reg [15:0] result,       // Dot product result (16-bit for accumulation)
    output reg DONE                 // Computation complete flag
);

    reg [2:0] counter;              // Count 0-7 for 8 elements
    reg [15:0] accumulator;         // Accumulate products
    reg computing;                  // State flag

    initial begin
        result = 0;
        DONE = 0;
        counter = 0;
        accumulator = 0;
        computing = 0;
    end

    always @(posedge CLK) begin
        if (START && !computing) begin
            // Initialize computation
            computing <= 1;
            counter <= 0;
            accumulator <= 0;
            DONE <= 0;
        end
        else if (computing) begin
            // Perform multiply-accumulate
            accumulator <= accumulator + (dataA * dataB);
            counter <= counter + 1;
            
            // Check if done (after 8 iterations)
            if (counter == 7) begin
                result <= accumulator + (dataA * dataB);  // Include last product
                DONE <= 1;
                computing <= 0;
            end
        end
    end

endmodule
