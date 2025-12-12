`timescale 1ns / 1ps


module tb_controller;

    // ==========================
    // 1. Signal Declarations
    // ==========================
    reg        clk;
    reg        rst;
    reg  [7:0] input_value;
    reg        input_value_ready;
    wire       input_enable;
    wire [3:0] ctrl_mem_addr;
    wire       ctrl_mem_wr;
    wire       mode_compute;
    wire       comp_start;
    reg        comp_done;
    reg  [7:0] comp_result;
    wire       display_enable;
    wire [7:0] display_value;

    // Loop integer
    integer i;

    // ==========================
    // 2. DUT Instantiation
    // ==========================
    controller uut (
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

    // ==========================
    // 3. Clock Generation
    // ==========================
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10ns period (100MHz)
    end

    // ==========================
    // 4. Stimulus Process
    // ==========================
    initial begin
        // Initialize Inputs
        rst = 1;
        input_value = 0;
        input_value_ready = 0;
        comp_done = 0;
        comp_result = 0;

        // Wait 100 ns for global reset to finish
        #100;
        rst = 0;
        #10;

        // -------------------------------------------------
        // PHASE 1: Feed Input A (8 values)
        // -------------------------------------------------
        $display("--- Starting Input Phase A ---");
        
        for (i = 0; i < 8; i = i + 1) begin
            // Wait until controller says it is ready to receive
            wait(input_enable == 1'b1);
            
            // Sync with negative edge to drive inputs (good practice)
            @(negedge clk);
            input_value = i + 1;      // Send values 1, 2, ... 8
            input_value_ready = 1;
            
            // Hold for 1 clock cycle
            @(negedge clk);
            input_value_ready = 0;
        end

        // -------------------------------------------------
        // PHASE 2: Feed Input B (8 values)
        // -------------------------------------------------
        $display("--- Starting Input Phase B ---");
        
        for (i = 0; i < 8; i = i + 1) begin
            wait(input_enable == 1'b1);
            
            @(negedge clk);
            input_value = i + 11;     // Send values 11, 12, ... 18
            input_value_ready = 1;
            
            @(negedge clk);
            input_value_ready = 0;
        end

        // -------------------------------------------------
        // PHASE 3: Compute Simulation
        // -------------------------------------------------
        $display("--- Inputs Done. Waiting for Compute Start ---");
        
        // Wait for the controller to signal start of computation
        wait(comp_start == 1'b1);
        $display("--- Compute Start Signal Detected ---");

        // Simulate calculation time (e.g., 5 clock cycles)
        repeat(5) @(posedge clk);

        // Provide result and signal done
        @(negedge clk);
        comp_result = 8'hFF; // Example result (255), separately testing
        comp_done = 1;
        
        @(negedge clk);
        comp_done = 0;

        // -------------------------------------------------
        // PHASE 4: Check Display
        // -------------------------------------------------
        wait(display_enable == 1'b1);
        @(negedge clk); // Allow value to settle
        
        if (display_value == 8'hFF) 
            $display("SUCCESS: Controller in Display Mode. Value: %h", display_value);
        else 
            $display("FAILURE: Expected FF, got %h", display_value);

        $stop;
    end

    // ==========================
    // 5. Monitoring (Optional Debugging)
    // ==========================
    initial begin
        // Monitors write operations to ensure addresses are correct
        $monitor("Time=%0t | State_Comp=%b | WR=%b | Addr=%d | Val=%d", 
                 $time, mode_compute, ctrl_mem_wr, ctrl_mem_addr, input_value);
    end

endmodule