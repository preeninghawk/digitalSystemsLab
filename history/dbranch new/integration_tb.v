`timescale 1ns / 1ps

module system_tb;

    // =========================================================
    // 1. Signal Declarations
    // =========================================================
    reg clk;
    reg rst;
    
    // Inputs to Controller
    reg [7:0] input_value;
    reg input_value_ready;
    
    // Outputs from Controller
    wire input_enable;
    wire [3:0] ctrl_mem_addr;
    wire ctrl_mem_wr;
    wire mode_compute;
    wire comp_start;
    wire display_enable;
    wire [7:0] display_value;

    // Interconnect Signals (Wires between modules)
    wire comp_done;           // From Dot Product to Controller
    wire [7:0] comp_result;   // From Dot Product to Controller
    
    // Memory Signals
    wire [3:0] mem_addr_mux;  // Shared Address Bus
    wire mem_wr_mux;          // Shared Write Enable
    wire [7:0] mem_data_out;  // Data from Memory
    
    // Dot Product Signals
    wire [3:0] dp_mem_addr;   // Address requested by Dot Product

    // =========================================================
    // 2. Module Instantiations
    // =========================================================

    // --- A. Controller Instance ---
    controller u_controller(
        .clk(clk),
        .rst(rst),
        .input_value(input_value),
        .input_value_ready(input_value_ready),
        .input_enable(input_enable),
        .ctrl_mem_addr(ctrl_mem_addr),
        .ctrl_mem_wr(ctrl_mem_wr),
        .mode_compute(mode_compute),
        .comp_start(comp_start),
        .comp_done(comp_done),      // Connected to Dot Product
        .comp_result(comp_result),  // Connected to Dot Product
        .display_enable(display_enable),
        .display_value(display_value)
    );

    // --- B. Memory Bus Multiplexer ---
    // If mode_compute is 1: Dot Product owns the memory.
    // If mode_compute is 0: Controller owns the memory.
    assign mem_addr_mux = (mode_compute) ? dp_mem_addr : ctrl_mem_addr;
    assign mem_wr_mux   = (mode_compute) ? 1'b0        : ctrl_mem_wr; // DP only reads

    // --- C. Memory Instance ---
    MEM16x8 u_memory(
        .CLK(clk),
        .WR(mem_wr_mux),
        .ADDR(mem_addr_mux),
        .DATA_IN(input_value), // Controller writes input_value directly to RAM
        .DATA_OUT(mem_data_out)
    );

    // --- D. Dot Product Computation Instance ---
    dot_product_computation u_dot_product(
        .clk(clk),
        .rst(rst),
        .start(comp_start),     // Triggered by Controller
        .mem_data_in(mem_data_out),
        .mem_addr(dp_mem_addr),
        .mem_wr(),              // Not used (DP doesn't write)
        .done(comp_done),       // Signals back to Controller
        .result(comp_result)    // Sends result to Controller
    );

    // =========================================================
    // 3. Clock Generation
    // =========================================================
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // =========================================================
    // 4. Test Stimulus
    // =========================================================
    integer i;

    initial begin
        $display("Starting System Integration Testbench");
        
        // Initialize
        rst = 1;
        input_value = 8'd0;
        input_value_ready = 0;
        
        #20;
        rst = 0;
        #20;
        
        // -----------------------------------------------------
        // Phase 1: Input Vector A (Values 1 to 8)
        // -----------------------------------------------------
        $display("\n=== Phase 1: Input Vector A ===");
        for (i = 0; i < 8; i = i + 1) begin
            @(posedge clk); #1;
            input_value = 8'd1 + i; 
            input_value_ready = 1;
            @(posedge clk); #1;
            input_value_ready = 0;
            #20; // Wait a bit between inputs
        end
        
        // -----------------------------------------------------
        // Phase 2: Input Vector B (Values 2 to 9)
        // Note: Using small numbers to fit result in 8 bits if possible,
        // or just to verify math. 
        // -----------------------------------------------------
        $display("\n=== Phase 2: Input Vector B ===");
        for (i = 0; i < 8; i = i + 1) begin
            @(posedge clk); #1;
            input_value = 8'd2 + i; 
            input_value_ready = 1;
            @(posedge clk); #1;
            input_value_ready = 0;
            #20;
        end
        
        // -----------------------------------------------------
        // Phase 3: Computation (Automatic)
        // -----------------------------------------------------
        $display("\n=== Phase 3: Computation ===");
        // We do NOT force comp_done manually. We wait for the hardware to do it.
        
        wait(comp_start);
        $display("Controller asserted comp_start. Waiting for hardware calculation...");
        
        wait(comp_done); // Wait for the Dot Product unit to finish
        $display("Computation Finished (comp_done received)!");
        
        // -----------------------------------------------------
        // Phase 4: Display Result
        // -----------------------------------------------------
        @(posedge clk);
        #10;
        
        if (display_enable) begin
            $display("SUCCESS: Final Result Displayed = %d", display_value);
        end else begin
            $display("ERROR: display_enable did not go high.");
        end

        #100;
        $finish;
    end
    
    // Monitor State Changes
    always @(u_controller.state) begin
        case (u_controller.state)
            2'd0: $display("[Time %0t] Controller State: S_INPUT_A", $time);
            2'd1: $display("[Time %0t] Controller State: S_INPUT_B", $time);
            2'd2: $display("[Time %0t] Controller State: S_COMPUTE", $time);
            2'd3: $display("[Time %0t] Controller State: S_DISPLAY", $time);
        endcase
    end

endmodule