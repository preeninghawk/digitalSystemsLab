`timescale 1ns / 1ps

//==============================================================================
// TESTBENCH (Fixed)
//==============================================================================
module DotProduct_tb;

    // Clock and reset
    reg CLK;
    reg RST;
    
    // Memory signals
    reg        mem_WR;
    reg  [3:0] mem_ADDR;
    reg  [7:0] mem_DATA_IN;
    wire [7:0] mem_DATA_OUT;
    
    // Computation signals
    reg        comp_START;
    wire [3:0] comp_addr;
    wire [7:0] comp_result;
    wire       comp_DONE;
    
    // Memory interface mux
    wire [3:0] final_addr;
    wire       final_wr;
    reg        use_comp_addr;  // 0=testbench writes, 1=calculator reads
    
    assign final_addr = use_comp_addr ? comp_addr : mem_ADDR;
    assign final_wr = use_comp_addr ? 1'b0 : mem_WR;
    
    // Instantiate SINGLE Memory Module
    MEM16x8 memory (
        .CLK      (CLK),
        .WR       (final_wr),
        .ADDR     (final_addr),
        .DATA_IN  (mem_DATA_IN),
        .DATA_OUT (mem_DATA_OUT)
    );
    
    // Instantiate Dot Product Calculator
    DotProductCalculator calculator (
        .CLK       (CLK),
        .RST       (RST),
        .START     (comp_START),
        .mem_data  (mem_DATA_OUT),
        .mem_addr  (comp_addr),
        .result    (comp_result),
        .DONE      (comp_DONE)
    );
    
    // Clock generation (50MHz)
    initial begin
        CLK = 0;
        forever #10 CLK = ~CLK;
    end
    
    // Test vectors
    integer i;
    integer expected_result;
    integer test_passed;
    
    // Main test procedure
    initial begin
        $dumpfile("dot_product_tb.vcd");
        $dumpvars(0, DotProduct_tb);
        
        // Initialize
        RST = 1;
        mem_WR = 0;
        mem_ADDR = 0;
        mem_DATA_IN = 0;
        comp_START = 0;
        use_comp_addr = 0;
        test_passed = 0;
        
        // Reset pulse
        #50;
        RST = 0;
        #50;
        
        $display("\n========================================");
        $display("Dot Product System Test");
        $display("========================================\n");
        
        //--------------------------------------
        // Test 1: Simple case [1,2,3,4,5,6,7,8] ¡¤ [8,7,6,5,4,3,2,1]
        //--------------------------------------
        $display("Test 1: A=[1,2,3,4,5,6,7,8], B=[8,7,6,5,4,3,2,1]");
        
        use_comp_addr = 0;  // Testbench controls memory
        
        // Write vector A to memory (addresses 0-7)
        mem_WR = 1;
        for (i = 0; i < 8; i = i + 1) begin
            @(posedge CLK);
            mem_ADDR = i;
            mem_DATA_IN = i + 1;  // 1, 2, 3, 4, 5, 6, 7, 8
            $display("  Writing A[%0d] = %0d to addr %0d", i, i+1, i);
        end
        
        // Write vector B to memory (addresses 8-15)
        for (i = 0; i < 8; i = i + 1) begin
            @(posedge CLK);
            mem_ADDR = 8 + i;
            mem_DATA_IN = 8 - i;  // 8, 7, 6, 5, 4, 3, 2, 1
            $display("  Writing B[%0d] = %0d to addr %0d", i, 8-i, 8+i);
        end
        
        @(posedge CLK);
        mem_WR = 0;
        
        // Calculate expected result: 1*8 + 2*7 + 3*6 + 4*5 + 5*4 + 6*3 + 7*2 + 8*1
        expected_result = 8 + 14 + 18 + 20 + 20 + 18 + 14 + 8;
        $display("  Expected result: %0d", expected_result);
        
        // Switch to computation mode
        use_comp_addr = 1;
        
        // Start computation
        #100;
        @(posedge CLK);
        comp_START = 1;
        @(posedge CLK);
        comp_START = 0;
        
        // Wait for completion
        wait(comp_DONE);
        @(posedge CLK);
        
        if (comp_result == expected_result[7:0]) begin
            $display("  PASS: Result = %0d\n", comp_result);
            test_passed = test_passed + 1;
        end else begin
            $display("  FAIL: Result = %0d (Expected = %0d)\n", 
                     comp_result, expected_result[7:0]);
        end
        
        //--------------------------------------
        // Test 2: All ones
        //--------------------------------------
        #200;
        use_comp_addr = 0;
        $display("Test 2: A=[1,1,1,1,1,1,1,1], B=[1,1,1,1,1,1,1,1]");
        
        mem_WR = 1;
        for (i = 0; i < 16; i = i + 1) begin
            @(posedge CLK);
            mem_ADDR = i;
            mem_DATA_IN = 1;
        end
        
        @(posedge CLK);
        mem_WR = 0;
        
        expected_result = 8;
        $display("  Expected result: %0d", expected_result);
        
        use_comp_addr = 1;
        #100;
        @(posedge CLK);
        comp_START = 1;
        @(posedge CLK);
        comp_START = 0;
        
        wait(comp_DONE);
        @(posedge CLK);
        
        if (comp_result == expected_result[7:0]) begin
            $display("  PASS: Result = %0d\n", comp_result);
            test_passed = test_passed + 1;
        end else begin
            $display("  FAIL: Result = %0d (Expected = %0d)\n", 
                     comp_result, expected_result[7:0]);
        end
        
        //--------------------------------------
        // Test 3: Overflow test
        //--------------------------------------
        #200;
        use_comp_addr = 0;
        $display("Test 3: A=[255,255,0,0,0,0,0,0], B=[255,255,0,0,0,0,0,0] (Overflow)");
        
        mem_WR = 1;
        for (i = 0; i < 16; i = i + 1) begin
            @(posedge CLK);
            mem_ADDR = i;
            mem_DATA_IN = (i == 0 || i == 1 || i == 8 || i == 9) ? 255 : 0;
        end
        
        @(posedge CLK);
        mem_WR = 0;
        
        // 255*255 = 65025, twice = 130050
        expected_result = 130050;
        $display("  Full result: %0d", expected_result);
        $display("  Expected (lower 8 bits): %0d", expected_result[7:0]);
        
        use_comp_addr = 1;
        #100;
        @(posedge CLK);
        comp_START = 1;
        @(posedge CLK);
        comp_START = 0;
        
        wait(comp_DONE);
        @(posedge CLK);
        
        if (comp_result == expected_result[7:0]) begin
            $display("  PASS: Result = %0d (correctly took lower 8 bits)\n", comp_result);
            test_passed = test_passed + 1;
        end else begin
            $display("  FAIL: Result = %0d (Expected = %0d)\n", 
                     comp_result, expected_result[7:0]);
        end
        
        //--------------------------------------
        // Test 4: Zero vectors
        //--------------------------------------
        #200;
        use_comp_addr = 0;
        $display("Test 4: A=[0,0,0,0,0,0,0,0], B=[0,0,0,0,0,0,0,0]");
        
        mem_WR = 1;
        for (i = 0; i < 16; i = i + 1) begin
            @(posedge CLK);
            mem_ADDR = i;
            mem_DATA_IN = 0;
        end
        
        @(posedge CLK);
        mem_WR = 0;
        
        expected_result = 0;
        $display("  Expected result: %0d", expected_result);
        
        use_comp_addr = 1;
        #100;
        @(posedge CLK);
        comp_START = 1;
        @(posedge CLK);
        comp_START = 0;
        
        wait(comp_DONE);
        @(posedge CLK);
        
        if (comp_result == expected_result) begin
            $display("  PASS: Result = %0d\n", comp_result);
            test_passed = test_passed + 1;
        end else begin
            $display("  FAIL: Result = %0d (Expected = %0d)\n", 
                     comp_result, expected_result);
        end
        
        //--------------------------------------
        // Summary
        //--------------------------------------
        #200;
        $display("========================================");
        $display("Tests Passed: %0d/4", test_passed);
        if (test_passed == 4)
            $display("All Tests Complete!");
        else
            $display("Some tests failed!");
        $display("========================================\n");
        
        $finish;
    end
    
    // Timeout watchdog
    initial begin
        #100000;
        $display("\nERROR: Simulation timeout!");
        $finish;
    end

endmodule