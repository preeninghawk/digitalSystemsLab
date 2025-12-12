`timescale 1ns / 1ps

module top_module_tb;

    // Clock and reset
    reg        clk;
    reg        rst;
    
    // Input signals (No wr_en or selectAB needed anymore)
    reg  [7:0] keyIn;

    // Outputs
    wire [7:0] seg_COM;
    wire [7:0] seg_DATA;

    // Instantiate the top module
    top_module dut(
        .clk       (clk),
        .rst       (rst),
        .keyIn     (keyIn),
        .seg_COM   (seg_COM),
        .seg_DATA  (seg_DATA)
    );

    // Clock generation (10ns period = 100MHz)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Test vectors
    reg [7:0] vector_a [0:7];
    reg [7:0] vector_b [0:7];
    integer expected_result;
    integer i;

    // State name function for debugging
    function [63:0] ctrl_state_name;
        input [2:0] state;
        begin
            case(state)
                3'd0: ctrl_state_name = "IDLE    ";
                3'd1: ctrl_state_name = "WAIT_AB ";
                3'd2: ctrl_state_name = "TRANS_A ";
                3'd3: ctrl_state_name = "TRANS_B ";
                3'd4: ctrl_state_name = "COMPUTE ";
                3'd5: ctrl_state_name = "DISPLAY ";
                3'd6: ctrl_state_name = "PRIME   "; // Added new state
                default: ctrl_state_name = "UNKNOWN ";
            endcase
        end
    endfunction

    // Monitor controller state changes
    reg [2:0] prev_ctrl_state;
    initial begin
        prev_ctrl_state = 3'd0;
        forever begin
            @(posedge clk);
            if (dut.u_controller.state != prev_ctrl_state) begin
                $display("\n[%0t] *** CONTROLLER: %s -> %s ***",
                         $time,
                         ctrl_state_name(prev_ctrl_state),
                         ctrl_state_name(dut.u_controller.state));
                prev_ctrl_state = dut.u_controller.state;
            end
        end
    end

    // Monitor internal memory writes
    always @(posedge clk) begin
        if (dut.ctrl_mem_wr) begin
            $display("[%0t] MEM_WRITE: addr=%2d | data=%3d | readDataA=%3d | readDataB=%3d", 
                     $time, dut.ctrl_mem_addr, dut.mem_data_in,
                     dut.readDataA, dut.readDataB);
        end
    end

    // Monitor computation done signal
    initial begin
        forever begin
            @(posedge clk);
            if (dut.comp_done) begin
                $display("\n[%0t] *** COMPUTATION DONE! Result = %0d ***\n", $time, dut.comp_result);
            end
        end
    end

    // Main test sequence
    initial begin
        // Initialize signals
        rst = 1;
        keyIn = 0;

        // Initialize test vectors
        // Vector A: [1, 2, 3, 4, 5, 6, 7, 8]
        for(i=0; i<8; i=i+1) vector_a[i] = i + 1;

        // Vector B: [8, 7, 6, 5, 4, 3, 2, 1]
        for(i=0; i<8; i=i+1) vector_b[i] = 8 - i;

        // Calculate expected result
        expected_result = 0;
        for (i = 0; i < 8; i = i + 1) begin
            expected_result = expected_result + (vector_a[i] * vector_b[i]);
        end
        
        $display("\n========================================");
        $display("=== AUTOMATED DOT PRODUCT TESTBENCH ===");
        $display("========================================");
        $display("Expected dot product result: %0d", expected_result);
        $display("========================================\n");

        // Release reset
        repeat(10) @(posedge clk);
        rst = 0;
        $display("[%0t] Reset Released", $time);

        // === STREAMING INPUT PHASE ===
        $display("\n=== Streaming Input Data (16 Cycles) ===");
        
        // Feed Vector A (8 cycles)
        for (i = 0; i < 8; i = i + 1) begin
            keyIn = vector_a[i];
            $display("[%0t] Inputting A[%0d] = %3d", $time, i, vector_a[i]);
            @(posedge clk); // Wait for clock edge to latch data
        end

        // Feed Vector B (8 cycles)
        for (i = 0; i < 8; i = i + 1) begin
            keyIn = vector_b[i];
            $display("[%0t] Inputting B[%0d] = %3d", $time, i, vector_b[i]);
            @(posedge clk); // Wait for clock edge to latch data
        end
        
        // Input phase done, clear input
        keyIn = 8'd0;
        $display("[%0t] Input Stream Complete", $time);

        // === VERIFICATION PHASE ===
        
        // Wait for input_unit to signal done
        wait(dut.doneA && dut.doneB);
        $display("[%0t] Input Unit reports DONE", $time);

        $display("\n=== Verifying Input Unit Storage ===");
        // Check Vector A in storage
        for (i = 0; i < 8; i = i + 1) begin
            if (dut.u_input.vectorA[i] !== vector_a[i]) 
                $display("ERROR: A[%0d] = %d (Expected %d)", i, dut.u_input.vectorA[i], vector_a[i]);
        end
        // Check Vector B in storage
        for (i = 0; i < 8; i = i + 1) begin
            if (dut.u_input.vectorB[i] !== vector_b[i]) 
                $display("ERROR: B[%0d] = %d (Expected %d)", i, dut.u_input.vectorB[i], vector_b[i]);
        end

        // Wait for computation
        $display("\n=== Waiting for Computation ===");
        
        // Wait for done signal with timeout
        fork
            begin
                wait(dut.comp_done);
            end
            begin
                #500000; // Timeout
                if (!dut.comp_done) begin
                    $display("ERROR: Computation timeout!");
                    $finish;
                end
            end
        join

        // Give one cycle to settle
        @(posedge clk);

        // Check Final Result
        $display("\n=== Checking Final Result ===");
        $display("Expected: %0d", expected_result[7:0]);
        $display("Actual:   %0d", dut.comp_result);
        
        if (dut.comp_result == expected_result[7:0])
            $display("\n*** TEST PASSED ***");
        else
            $display("\n*** TEST FAILED ***");

        // Wait to observe display logic
        $display("\n=== Observing Display (Run for 200 cycles) ===");
        repeat(200) @(posedge clk);

        $finish;
    end

endmodule