`timescale 1ns / 1ps

module top_tb;

    // Inputs
    reg CLK;
    reg [7:0] btn_sw;

    // Outputs
    wire [7:0] seg_COM;
    wire [7:0] seg_DATA;
    wire [7:0] led;

    // DUT Instantiation
    term_project_top dut (
        .CLK(CLK), 
        .btn_sw(btn_sw), 
        .seg_COM(seg_COM), 
        .seg_DATA(seg_DATA), 
        .led(led)
    );

    // Clock Generation (100MHz equivalent)
    initial begin
        CLK = 0;
        forever #5 CLK = ~CLK;
    end

    // --- Tasks for cleaner code ---
    
    // Task to press a specific button (Active Low simulation)
    task press_btn;
        input [2:0] index;
        begin
            btn_sw[index] = 1'b0; // Press (Active Low)
            #200;                 // Hold
            btn_sw[index] = 1'b1; // Release
            #200;                 // Bounce/Wait
        end
    endtask

    // Task to input a full byte using the buttons
    task enter_value;
        input [7:0] value;
        integer b;
        begin
            $display("[Input] Typing value: %d", value);
            // Type bits MSB to LSB
            for (b=0; b<8; b=b+1) begin
                // Note: Your design shifts left, so we can enter any order if logic supports it.
                // Assuming standard "shift in from right":
                // Actually, pure shift register usually takes MSB first or LSB first depending on logic.
                // Let's assume we press '1' or '0' buttons 8 times.
                // However, simplest way based on your input_unit is usually just typing the bits.
                
                // Let's rely on the fact we need to shift 1s and 0s. 
                // We will iterate 8 times.
                if (value[7-b] == 1'b1) 
                    press_btn(1); // Press '1'
                else 
                    press_btn(0); // Press '0'
            end
            
            // Confirm with 'Next'
            press_btn(2); 
            #50;
        end
    endtask

    integer i;

    // Main Test Sequence
    initial begin
        $display("=== STARTING TOP LEVEL TEST ===");
        
        // 1. Initialize (Buttons released = 1)
        btn_sw = 8'hFF;
        
        // 2. Reset System
        $display("[System] Resetting...");
        press_btn(3); 
        #100;

        // 3. Input Vector A (Values 1 to 8)
        $display("\n=== PHASE 1: INPUT VECTOR A ===");
        for (i=1; i<=8; i=i+1) begin
            enter_value(i); // Inputs 1, 2, 3... 8
        end

        // 4. Input Vector B (Value 2 repeated 8 times)
        $display("\n=== PHASE 2: INPUT VECTOR B ===");
        for (i=1; i<=8; i=i+1) begin
            enter_value(2); // Inputs 2, 2, 2...
        end

        // 5. Computation Phase
        $display("\n=== PHASE 3: COMPUTATION ===");
        $display("[System] Waiting for computation to finish...");
        
        // Wait for state to reach S_DISPLAY (3)
        wait(dut.u_ctrl.state == 2'd3);
        #1000;

        // 6. Check Result
        if (dut.display_value == 72) begin
            $display("\nSUCCESS: Calculated %d (Expected 72)", dut.display_value);
        end else begin
            $display("\nERROR: Calculated %d (Expected 72)", dut.display_value);
        end

        // 7. Verify Memory Contents (Optional Debug)
        $display("\n--- Memory Dump ---");
        for (i=0; i<16; i=i+1) begin
            $display("Mem[%0d] = %d", i, dut.u_mem.mem[i]);
        end

        $finish;
    end

endmodule