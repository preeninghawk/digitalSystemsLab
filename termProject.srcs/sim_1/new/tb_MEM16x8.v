`timescale 1ns / 1ps

module MEM16x8_tb;

    // Inputs
    reg        CLK;
    reg        WR;
    reg  [3:0] ADDR;
    reg  [7:0] DATA_IN;
    
    // Outputs
    wire [7:0] DATA_OUT;
    
    // Instantiate the memory module
    MEM16x8 dut (
        .CLK      (CLK),
        .WR       (WR),
        .ADDR     (ADDR),
        .DATA_IN  (DATA_IN),
        .DATA_OUT (DATA_OUT)
    );
    
    // Clock generation (50MHz -> 20ns period)
    initial begin
        CLK = 0;
        forever #10 CLK = ~CLK;
    end
    
    // Test variables
    integer i;
    reg [7:0] expected;
    integer errors;
    
    // Main test procedure
    initial begin
        // Initialize waveform dump
        $dumpfile("mem16x8_tb.vcd");
        $dumpvars(0, MEM16x8_tb);
        
        // Initialize signals
        WR = 0;
        ADDR = 0;
        DATA_IN = 0;
        errors = 0;
        
        $display("\n========================================");
        $display("Starting MEM16x8 Memory Tests");
        $display("========================================\n");
        
        // Wait for a few clock cycles
        repeat(5) @(posedge CLK);
        
        //--------------------------------------
        // Test 1: Write to all addresses
        //--------------------------------------
        $display("Test 1: Writing to all 16 addresses...");
        WR = 1;
        
        for (i = 0; i < 16; i = i + 1) begin
            @(posedge CLK);
            ADDR = i;
            DATA_IN = i * 17;  // Pattern: 0, 17, 34, 51, ...
            $display("  Writing ADDR=%0d, DATA=%0d", i, i*17);
        end
        
        @(posedge CLK);
        WR = 0;
        $display("  Write complete.\n");
        
        //--------------------------------------
        // Test 2: Read from all addresses
        //--------------------------------------
        $display("Test 2: Reading from all 16 addresses...");
        
        @(posedge CLK);  // Wait one cycle before reading
        
        for (i = 0; i < 16; i = i + 1) begin
            ADDR = i;
            @(posedge CLK);
            @(posedge CLK);  // Wait for read to complete
            
            expected = i * 17;
            if (DATA_OUT == expected) begin
                $display("  PASS: ADDR=%0d, Read=%0d (Expected=%0d)", i, DATA_OUT, expected);
            end else begin
                $display("  FAIL: ADDR=%0d, Read=%0d (Expected=%0d)", i, DATA_OUT, expected);
                errors = errors + 1;
            end
        end
        $display("");
        
        //--------------------------------------
        // Test 3: Overwrite specific addresses
        //--------------------------------------
        $display("Test 3: Overwriting addresses 5, 10, 15...");
        WR = 1;
        
        @(posedge CLK);
        ADDR = 5;
        DATA_IN = 8'd255;
        $display("  Writing ADDR=5, DATA=255");
        
        @(posedge CLK);
        ADDR = 10;
        DATA_IN = 8'd128;
        $display("  Writing ADDR=10, DATA=128");
        
        @(posedge CLK);
        ADDR = 15;
        DATA_IN = 8'd0;
        $display("  Writing ADDR=15, DATA=0");
        
        @(posedge CLK);
        WR = 0;
        
        // Read back
        $display("  Reading back overwritten addresses...");
        @(posedge CLK);
        
        ADDR = 5;
        @(posedge CLK);
        @(posedge CLK);
        if (DATA_OUT == 255) begin
            $display("  PASS: ADDR=5, Read=%0d", DATA_OUT);
        end else begin
            $display("  FAIL: ADDR=5, Read=%0d (Expected=255)", DATA_OUT);
            errors = errors + 1;
        end
        
        ADDR = 10;
        @(posedge CLK);
        @(posedge CLK);
        if (DATA_OUT == 128) begin
            $display("  PASS: ADDR=10, Read=%0d", DATA_OUT);
        end else begin
            $display("  FAIL: ADDR=10, Read=%0d (Expected=128)", DATA_OUT);
            errors = errors + 1;
        end
        
        ADDR = 15;
        @(posedge CLK);
        @(posedge CLK);
        if (DATA_OUT == 0) begin
            $display("  PASS: ADDR=15, Read=%0d", DATA_OUT);
        end else begin
            $display("  FAIL: ADDR=15, Read=%0d (Expected=0)", DATA_OUT);
            errors = errors + 1;
        end
        $display("");
        
        //--------------------------------------
        // Test 4: Verify other addresses unchanged
        //--------------------------------------
        $display("Test 4: Verify other addresses unchanged...");
        
        ADDR = 0;
        @(posedge CLK);
        @(posedge CLK);
        if (DATA_OUT == 0) begin
            $display("  PASS: ADDR=0 unchanged, Read=%0d", DATA_OUT);
        end else begin
            $display("  FAIL: ADDR=0, Read=%0d (Expected=0)", DATA_OUT);
            errors = errors + 1;
        end
        
        ADDR = 7;
        @(posedge CLK);
        @(posedge CLK);
        if (DATA_OUT == 119) begin
            $display("  PASS: ADDR=7 unchanged, Read=%0d", DATA_OUT);
        end else begin
            $display("  FAIL: ADDR=7, Read=%0d (Expected=119)", DATA_OUT);
            errors = errors + 1;
        end
        $display("");
        
        //--------------------------------------
        // Test 5: Rapid write/read cycles
        //--------------------------------------
        $display("Test 5: Rapid write/read cycles...");
        
        for (i = 0; i < 4; i = i + 1) begin
            // Write
            WR = 1;
            ADDR = i;
            DATA_IN = 100 + i;
            @(posedge CLK);
            
            // Read immediately
            WR = 0;
            @(posedge CLK);
            @(posedge CLK);
            
            expected = 100 + i;
            if (DATA_OUT == expected) begin
                $display("  PASS: Rapid W/R at ADDR=%0d, Read=%0d", i, DATA_OUT);
            end else begin
                $display("  FAIL: Rapid W/R at ADDR=%0d, Read=%0d (Expected=%0d)", 
                         i, DATA_OUT, expected);
                errors = errors + 1;
            end
        end
        $display("");
        
        //--------------------------------------
        // Test 6: Edge case - same address multiple writes
        //--------------------------------------
        $display("Test 6: Multiple writes to same address...");
        WR = 1;
        ADDR = 8;
        
        DATA_IN = 50;
        @(posedge CLK);
        $display("  Write 1: ADDR=8, DATA=50");
        
        DATA_IN = 75;
        @(posedge CLK);
        $display("  Write 2: ADDR=8, DATA=75");
        
        DATA_IN = 100;
        @(posedge CLK);
        $display("  Write 3: ADDR=8, DATA=100");
        
        WR = 0;
        @(posedge CLK);
        @(posedge CLK);
        
        if (DATA_OUT == 100) begin
            $display("  PASS: Final value at ADDR=8 is %0d", DATA_OUT);
        end else begin
            $display("  FAIL: ADDR=8, Read=%0d (Expected=100)", DATA_OUT);
            errors = errors + 1;
        end
        $display("");
        
        //--------------------------------------
        // Summary
        //--------------------------------------
        #100;
        $display("========================================");
        if (errors == 0) begin
            $display("ALL TESTS PASSED!");
        end else begin
            $display("TESTS FAILED: %0d errors found", errors);
        end
        $display("========================================\n");
        
        $finish;
    end
    
    // Timeout watchdog
    initial begin
        #50000;  // 50us timeout
        $display("\nERROR: Simulation timeout!");
        $finish;
    end

endmodule