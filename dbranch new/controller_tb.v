`timescale 1ns / 1ps

module controller_tb;

    reg clk;
    reg rst;
    reg [7:0] input_value;
    reg input_value_ready;
    wire input_enable;
    wire [3:0] ctrl_mem_addr;
    wire ctrl_mem_wr;
    wire mode_compute;
    wire comp_start;
    reg comp_done;
    reg [7:0] comp_result;
    wire display_enable;
    wire [7:0] display_value;

    // DUT
    controller_new dut(
        .clk(clk),
        .rst(rst),
        .input_value(input_value),
        .input_value_ready(input_value_ready),
        .input_enable(input_enable),
        .ctrl_mem_addr(ctrl_mem_addr),
        .ctrl_mem_wr(ctrl_mem_wr),
        .mode_compute(mode_compute),
        .comp_start(comp_start),
        .comp_done(comp_done),
        .comp_result(comp_result),
        .display_enable(display_enable),
        .display_value(display_value)
    );

    // Memory to track what gets written
    reg [7:0] mem_check [15:0];
    integer i;

    // Track memory writes
    always @(posedge clk) begin
        if (ctrl_mem_wr) begin
            mem_check[ctrl_mem_addr] <= input_value;
            $display("Time %0t: Memory write - addr=%0d, data=%0d", $time, ctrl_mem_addr, input_value);
        end
    end

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Test stimulus
    initial begin
        $display("Starting controller testbench");
        
        // Initialize
        rst = 1;
        input_value = 8'd0;
        input_value_ready = 0;
        comp_done = 0;
        comp_result = 8'd0;
        
        for (i = 0; i < 16; i = i + 1) begin
            mem_check[i] = 8'd0;
        end
        
        #20;
        rst = 0;
        #20;
        
        $display("\n=== Phase 1: Input Vector A (8 elements) ===");
        // Input 8 values for vector A
        for (i = 0; i < 8; i = i + 1) begin
            @(posedge clk);
            #1;
            input_value = 8'd1 + i;  // Values 1,2,3,4,5,6,7,8
            input_value_ready = 1;
            $display("Sending value %0d for vector A[%0d]", input_value, i);
            @(posedge clk);
            #1;
            input_value_ready = 0;
            #20;
        end
        
        $display("\n=== Phase 2: Input Vector B (8 elements) ===");
        // Input 8 values for vector B
        for (i = 0; i < 8; i = i + 1) begin
            @(posedge clk);
            #1;
            input_value = 8'd10 + i;  // Values 10,11,12,13,14,15,16,17
            input_value_ready = 1;
            $display("Sending value %0d for vector B[%0d]", input_value, i);
            @(posedge clk);
            #1;
            input_value_ready = 0;
            #20;
        end
        
        $display("\n=== Phase 3: Computation ===");
        // Wait for comp_start signal
        wait(comp_start);
        $display("Time %0t: Computation started (comp_start=1)", $time);
        
        // Simulate computation taking some time
        #100;
        
        @(posedge clk);
        #1;
        comp_result = 8'd123;  // Dummy result
        comp_done = 1;
        $display("Time %0t: Computation done, result=%0d", $time, comp_result);
        
        @(posedge clk);
        #1;
        comp_done = 0;
        
        #50;
        
        $display("\n=== Phase 4: Display ===");
        $display("Time %0t: display_enable=%0b, display_value=%0d", 
                 $time, display_enable, display_value);
        
        if (display_enable && display_value == 123) begin
            $display("SUCCESS: Display shows correct result!");
        end else begin
            $display("ERROR: Display issue - enable=%0b, value=%0d", 
                     display_enable, display_value);
        end
        
        $display("\n=== Memory Contents ===");
        $display("Vector A:");
        for (i = 0; i < 8; i = i + 1) begin
            $display("  mem[%0d] = %0d", i, mem_check[i]);
        end
        $display("Vector B:");
        for (i = 8; i < 16; i = i + 1) begin
            $display("  mem[%0d] = %0d", i, mem_check[i]);
        end
        
        #100;
        $display("\nTestbench complete");
        $finish;
    end
    
    // Monitor state transitions
    always @(dut.state) begin
        case (dut.state)
            2'd0: $display("Time %0t: STATE = S_INPUT_A", $time);
            2'd1: $display("Time %0t: STATE = S_INPUT_B", $time);
            2'd2: $display("Time %0t: STATE = S_COMPUTE", $time);
            2'd3: $display("Time %0t: STATE = S_DISPLAY", $time);
        endcase
    end
    
    // Timeout
    initial begin
        #100000;
        $display("ERROR: Testbench timeout!");
        $finish;
    end

endmodule