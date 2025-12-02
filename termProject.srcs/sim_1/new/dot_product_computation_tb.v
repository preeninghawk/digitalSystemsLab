`timescale 1ns / 1ps


module dot_product_computation_tb;
// Clock and reset
    reg        clk;
    reg        rst;
    
    // Control signals
    reg        start;
    
    // Memory interface
    reg  [7:0] mem_data_in;
    wire [3:0] mem_addr;
    wire       mem_wr;
    
    // Outputs
    wire       done;
    wire [7:0] result;
    
    // Memory model (16x8 bits)
    reg [7:0] test_mem [0:15];
    
    // Instantiate DUT (Device Under Test)
    dot_product_computation uut (
        .clk         (clk),
        .rst         (rst),
        .start       (start),
        .mem_data_in (mem_data_in),
        .mem_addr    (mem_addr),
        .mem_wr      (mem_wr),
        .done        (done),
        .result      (result)
    );
    
    // Clock generation (50MHz -> 20ns period)
    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end
    
    // Memory read behavior - simulate memory with 1 cycle delay
    always @(posedge clk) begin
        if (!mem_wr) begin
            mem_data_in <= test_mem[mem_addr];
        end
    end
    
    // Test variables
    integer i;
    integer expected_result;
    integer test_num;
    
    // Main test procedure
    initial begin
        // Initialize waveform dump
        $dumpfile("dot_product_tb.vcd");
        $dumpvars(0, dot_product_computation_tb);
        
        // Initialize signals
        rst = 1;
        start = 0;
        test_num = 0;
        
        // Initialize memory
        for (i = 0; i < 16; i = i + 1) begin
            test_mem[i] = 0;
        end
        
        // Reset pulse
        #25;
        rst = 0;
        #40;
        
        $display("\n========================================");
        $display("Starting Dot Product Computation Tests");
        $display("========================================\n");
        
        //--------------------------------------
        // Test 1: Simple case - all ones
        //--------------------------------------
        test_num = 1;
        $display("Test %0d: Vector A = [1,1,1,1,1,1,1,1], Vector B = [1,1,1,1,1,1,1,1]", test_num);
        
        // Setup vectors in memory
        // A vector at addresses 0-7
        for (i = 0; i < 8; i = i + 1) begin
            test_mem[i] = 8'd1;
        end
        // B vector at addresses 8-15
        for (i = 8; i < 16; i = i + 1) begin
            test_mem[i] = 8'd1;
        end
        
        expected_result = 8;  // 1*1 + 1*1 + ... (8 times) = 8
        run_test(expected_result);
        
        //--------------------------------------
        // Test 2: Zero vectors
        //--------------------------------------
        test_num = 2;
        $display("Test %0d: Vector A = [0,0,0,0,0,0,0,0], Vector B = [0,0,0,0,0,0,0,0]", test_num);
        
        for (i = 0; i < 16; i = i + 1) begin
            test_mem[i] = 8'd0;
        end
        
        expected_result = 0;
        run_test(expected_result);
        
        //--------------------------------------
        // Test 3: Simple multiplication
        //--------------------------------------
        test_num = 3;
        $display("Test %0d: Vector A = [2,0,0,0,0,0,0,0], Vector B = [3,0,0,0,0,0,0,0]", test_num);
        
        test_mem[0] = 8'd2;
        test_mem[8] = 8'd3;
        for (i = 1; i < 8; i = i + 1) begin
            test_mem[i] = 8'd0;
            test_mem[i+8] = 8'd0;
        end
        
        expected_result = 6;  // 2*3 = 6
        run_test(expected_result);
        
        //--------------------------------------
        // Test 4: Incrementing values
        //--------------------------------------
        test_num = 4;
        $display("Test %0d: Vector A = [1,2,3,4,5,6,7,8], Vector B = [8,7,6,5,4,3,2,1]", test_num);
        
        for (i = 0; i < 8; i = i + 1) begin
            test_mem[i] = i + 1;
            test_mem[i+8] = 8 - i;
        end
        
        expected_result = 120;  // 1*8 + 2*7 + 3*6 + 4*5 + 5*4 + 6*3 + 7*2 + 8*1
        run_test(expected_result);
        
        //--------------------------------------
        // Test 5: Maximum values (overflow test)
        //--------------------------------------
        test_num = 5;
        $display("Test %0d: Vector A = [255,255,...], Vector B = [255,255,...] (overflow)", test_num);
        
        for (i = 0; i < 16; i = i + 1) begin
            test_mem[i] = 8'd255;
        end
        
        // 255*255 = 65025, * 8 = 520200
        // Result should be lower 8 bits after accumulation
        expected_result = 8;  // Only lower 8 bits: 520200 & 0xFF
        run_test(expected_result);
        
        //--------------------------------------
        // Test 6: Mixed values
        //--------------------------------------
        test_num = 6;
        $display("Test %0d: Vector A = [10,20,30,40,5,6,7,8], Vector B = [1,2,3,4,10,9,8,7]", test_num);
        
        test_mem[0] = 8'd10; test_mem[8]  = 8'd1;
        test_mem[1] = 8'd20; test_mem[9]  = 8'd2;
        test_mem[2] = 8'd30; test_mem[10] = 8'd3;
        test_mem[3] = 8'd40; test_mem[11] = 8'd4;
        test_mem[4] = 8'd5;  test_mem[12] = 8'd10;
        test_mem[5] = 8'd6;  test_mem[13] = 8'd9;
        test_mem[6] = 8'd7;  test_mem[14] = 8'd8;
        test_mem[7] = 8'd8;  test_mem[15] = 8'd7;
        
        expected_result = 10 + 40 + 90 + 160 + 50 + 54 + 56 + 56;
        expected_result = expected_result & 8'hFF;  // Take lower 8 bits
        run_test(expected_result);
        
        //--------------------------------------
        // Test 7: Consecutive operations
        //--------------------------------------
        test_num = 7;
        $display("Test %0d: Two consecutive operations without reset", test_num);
        
        for (i = 0; i < 8; i = i + 1) begin
            test_mem[i] = 8'd2;
            test_mem[i+8] = 8'd5;
        end
        
        expected_result = 80;  // 2*5 * 8 = 80
        run_test(expected_result);
        
        // Second operation immediately after
        for (i = 0; i < 8; i = i + 1) begin
            test_mem[i] = 8'd3;
            test_mem[i+8] = 8'd4;
        end
        
        expected_result = 96;  // 3*4 * 8 = 96
        run_test(expected_result);
        
        //--------------------------------------
        // End of tests
        //--------------------------------------
        #100;
        $display("\n========================================");
        $display("All tests completed!");
        $display("========================================\n");
        $finish;
    end
    
    // Task to run a single test
    task run_test;
        input [7:0] expected;
        begin
            @(posedge clk);
            start = 1;
            @(posedge clk);
            start = 0;
            
            // Wait for completion (timeout after 500 cycles)
            fork
                begin
                    wait(done);
                end
                begin
                    repeat(500) @(posedge clk);
                    $display("ERROR: Timeout waiting for done signal!");
                    $finish;
                end
            join_any;
            disable fork;
            
            @(posedge clk);
            
            // Check result
            if (result == expected) begin
                $display("  PASS: Result = %0d (Expected = %0d)", result, expected);
            end else begin
                $display("  FAIL: Result = %0d (Expected = %0d)", result, expected);
            end
            
            #40;  // Wait a bit before next test
        end
    endtask
    
    // Monitor for debugging (optional - comment out if too verbose)
    /*
    initial begin
        $monitor("Time=%0t rst=%b start=%b done=%b result=%0d mem_addr=%0d state=%0d", 
                 $time, rst, start, done, result, mem_addr, dut.state);
    end
    */
    
    // Timeout watchdog
    initial begin
        #100000;  // 100us timeout
        $display("\nERROR: Simulation timeout!");
        $finish;
    end
endmodule
