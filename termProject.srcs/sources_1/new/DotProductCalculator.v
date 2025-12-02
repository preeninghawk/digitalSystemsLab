`timescale 1ns / 1ps

//==============================================================================
// COMPUTATIONAL MODULE: Dot Product Calculator (Fixed)
//==============================================================================
module DotProductCalculator(
    input CLK,
    input RST,
    input START,                    // Start computation
    input [7:0] mem_data,           // Data from unified memory
    output reg [3:0] mem_addr,      // Address for memory
    output reg [7:0] result,        // Final result (lower 8 bits)
    output reg DONE                 // Computation complete flag
);

    // State machine - following your dotprod_compute pattern
    localparam S_IDLE = 3'd0;
    localparam S_LOAD_A = 3'd1;
    localparam S_WAIT_A = 3'd2;
    localparam S_LOAD_B = 3'd3;
    localparam S_WAIT_B = 3'd4;
    localparam S_ACCUM = 3'd5;
    localparam S_DONE = 3'd6;
    
    reg [2:0] state;
    reg [2:0] index;                // 0 to 7 for 8 elements
    reg [15:0] accumulator;         // 16-bit accumulator for dot product
    reg [7:0] a_reg, b_reg;
    
    always @(posedge CLK or posedge RST) begin
        if (RST) begin
            state <= S_IDLE;
            index <= 0;
            accumulator <= 0;
            result <= 0;
            DONE <= 0;
            mem_addr <= 0;
            a_reg <= 0;
            b_reg <= 0;
        end
        else begin
            DONE <= 0;  // Default: clear done signal
            
            case (state)
                S_IDLE: begin
                    if (START) begin
                        index <= 0;
                        accumulator <= 0;
                        state <= S_LOAD_A;
                    end
                end
                
                S_LOAD_A: begin
                    mem_addr <= index;      // Request A[i]
                    state <= S_WAIT_A;
                end
                
                S_WAIT_A: begin
                    a_reg <= mem_data;      // Capture A[i]
                    state <= S_LOAD_B;
                end
                
                S_LOAD_B: begin
                    mem_addr <= 8 + index;  // Request B[i]
                    state <= S_WAIT_B;
                end
                
                S_WAIT_B: begin
                    b_reg <= mem_data;      // Capture B[i]
                    state <= S_ACCUM;
                end
                
                S_ACCUM: begin
                    // Multiply and accumulate
                    accumulator <= accumulator + (a_reg * b_reg);
                    
                    if (index == 7) begin
                        // Last element - go to done state
                        result <= accumulator[7:0] + (a_reg * b_reg)[7:0];
                        
                        state <= S_DONE;
                    end
                    else begin
                        // Move to next element
                        index <= index + 1;
                        state <= S_LOAD_A;
                    end
                end
                
                S_DONE: begin
                    DONE <= 1;
                    state <= S_IDLE;
                end
                
                default: state <= S_IDLE;
            endcase
        end
    end

endmodule