`timescale 1ns / 1ps

module dot_product_tb;

    reg clk;
    reg rst;
    reg start;
    reg [7:0] mem_data_in;
    wire [3:0] mem_addr;
    wire mem_wr;
    wire done;
    wire [7:0] result;

    // Memory array to simulate MEM16x8
    reg [7:0] test_mem [15:0];

    // DUT
    dot_product_computation dut(
        .clk(clk),
        .rst(rst),
        .start(start),
        .mem_data_in(mem_data_in),
        .mem_addr(mem_addr),
        .mem_wr(mem_wr),
        .done(done),
        .result(result)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Memory read simulation
    always @(*) begin
        mem_data_in = test_mem[mem_addr];
    end

    // Test stimulus
    initial begin
        $display("Starting dot product testbench");
        
        // Initialize
        rst = 1;
        start = 0;
        
        // Load test vectors into memory
        // Vector A at addresses 0-7
        test_mem[0] = 8'd1;
        test_mem[1] = 8'd2;
        test_mem[2] = 8'd3;
        test_mem[3] = 8'd4;
        test_mem[4] = 8'd5;
        test_mem[5] = 8'd6;
        test_mem[6] = 8'd7;
        test_mem[7] = 8'd8;
        
        // Vector B at addresses 8-15
        test_mem[8]  = 8'd2;
        test_mem[9]  = 8'd2;
        test_mem[10] = 8'd2;
        test_mem[11] = 8'd2;
        test_mem[12] = 8'd2;
        test_mem[13] = 8'd2;
        test_mem[14] = 8'd2;
        test_mem[15] = 8'd2;
        
        #20;
        rst = 0;
        #20;
        
        // Start computation
        $display("Starting computation at time %0t", $time);
        start = 1;
        #10;
        start = 0;
        
        // Wait for done
        wait(done);
        #10;
        
        $display("Computation done at time %0t", $time);
        $display("Result = %d (expected 72)", result);
        $display("Expected: 1*2 + 2*2 + 3*2 + 4*2 + 5*2 + 6*2 + 7*2 + 8*2 = 72");
        
        #50;
        
        // Test 2: Different vectors
        $display("\n--- Test 2 ---");
        test_mem[0] = 8'd10;
        test_mem[1] = 8'd20;
        test_mem[2] = 8'd30;
        test_mem[3] = 8'd0;
        test_mem[4] = 8'd0;
        test_mem[5] = 8'd0;
        test_mem[6] = 8'd0;
        test_mem[7] = 8'd0;
        
        test_mem[8]  = 8'd5;
        test_mem[9]  = 8'd3;
        test_mem[10] = 8'd2;
        test_mem[11] = 8'd0;
        test_mem[12] = 8'd0;
        test_mem[13] = 8'd0;
        test_mem[14] = 8'd0;
        test_mem[15] = 8'd0;
        
        start = 1;
        #10;
        start = 0;
        
        wait(done);
        #10;
        
        $display("Result = %d (expected 170, but will overflow to %d)", result, (10*5 + 20*3 + 30*2) % 256);
        $display("Expected: 10*5 + 20*3 + 30*2 = 170");
        
        #50;
        $display("\nTestbench complete");
        $finish;
    end
    
    // Timeout
    initial begin
        #10000;
        $display("ERROR: Testbench timeout!");
        $finish;
    end

endmodule