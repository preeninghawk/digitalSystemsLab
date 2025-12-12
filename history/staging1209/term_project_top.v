`timescale 1ns / 1ps

module term_project_top(
    input        CLK,           // Board clock
    input  [7:0] btn_sw,        // Active-low buttons (Bit 0=0, Bit 1=1, Bit 2=Next, Bit 3=Rst)
    output [7:0] seg_COM,       // 7-segment Common (active low)
    output [7:0] seg_DATA,      // 7-segment Data (active high)
    output [7:0] led            // LEDs to show current typing input
);

    // Button Mapping (Active Low)
    wire btn_zero = ~btn_sw[0]; // Button 0 -> Input '0'
    wire btn_one  = ~btn_sw[1]; // Button 1 -> Input '1'
    wire btn_next = ~btn_sw[2]; // Button 2 -> Confirm/Next
    wire btn_rst  = ~btn_sw[3]; // Button 3 -> Reset

    // Internal Wires
    wire        input_enable;
    wire [7:0]  input_value;
    wire [7:0]  cur_input_value; // Current value being typed
    wire        input_value_ready;

    wire [3:0]  ctrl_mem_addr;
    wire        ctrl_mem_wr;
    wire        mode_compute;
    wire        comp_start;
    wire        comp_done;
    wire [7:0]  comp_result;
    
    wire [3:0]  comp_mem_addr;
    wire        comp_mem_wr; // Likely 0, as computation usually reads

    wire        display_enable;
    wire [7:0]  display_value;

    // Memory Bus Signals
    wire [3:0]  mem_addr_final;
    wire        mem_wr_final;
    wire [7:0]  mem_data_in;
    wire [7:0]  mem_data_out;

    // =========================================================
    // 1. INPUT UNIT
    // =========================================================
    input_unit u_input(
        .clk        (CLK),
        .rst        (btn_rst),
        .enable     (input_enable),
        .btn_zero   (btn_zero),
        .btn_one    (btn_one),
        .btn_next   (btn_next),
        .value      (input_value),
        .value_ready(input_value_ready),
        .cur_value  (cur_input_value)
    );
    
    // Connect LEDs to the value currently being typed so user can see it
    assign led = cur_input_value;

    // =========================================================
    // 2. CONTROLLER
    // =========================================================
    controller u_ctrl(
        .clk              (CLK),
        .rst              (btn_rst),
        .input_value      (input_value),
        .input_value_ready(input_value_ready),
        .input_enable     (input_enable),
        .ctrl_mem_addr    (ctrl_mem_addr),
        .ctrl_mem_wr      (ctrl_mem_wr),
        .mode_compute     (mode_compute),
        .comp_start       (comp_start),
        .comp_done        (comp_done),
        .comp_result      (comp_result),
        .display_enable   (display_enable),
        .display_value    (display_value)
    );

    // =========================================================
    // 3. COMPUTATION UNIT (Dot Product)
    // =========================================================
    dot_product_computation u_comp(
        .clk        (CLK),
        .rst        (btn_rst),
        .start      (comp_start),
        .mem_data_in(mem_data_out),
        .mem_addr   (comp_mem_addr),
        .mem_wr     (comp_mem_wr), // usually unused/0 for DP
        .done       (comp_done),
        .result     (comp_result)
    );

    // =========================================================
    // 4. MEMORY & MUX (THE CRITICAL FIX)
    // =========================================================
    
    // DATA IN: Always comes from input_value (Compute unit only reads)
    assign mem_data_in = input_value;

    // ADDRESS MUX: 
    // If Controller is writing, USE CONTROLLER ADDR (Priority!)
    // Otherwise, check mode: if compute mode, use Comp Addr, else Controller Addr.
    assign mem_addr_final = (ctrl_mem_wr) ? ctrl_mem_addr : (mode_compute ? comp_mem_addr : ctrl_mem_addr);

    // WRITE ENABLE MUX:
    // If Controller says Write, WE WRITE (Priority!)
    // Otherwise, check mode.
    assign mem_wr_final   = (ctrl_mem_wr) ? 1'b1          : (mode_compute ? comp_mem_wr   : 1'b0);

    MEM16x8 u_mem(
        .CLK     (CLK),
        .WR      (mem_wr_final),
        .ADDR    (mem_addr_final),
        .DATA_IN (mem_data_in),
        .DATA_OUT(mem_data_out)
    );

    // =========================================================
    // 5. DISPLAY UNIT
    // =========================================================
    display_unit u_disp(
        .clk     (CLK),
        .rst     (btn_rst),
        .enable  (display_enable),
        .value   (display_value),
        .seg_COM (seg_COM),
        .seg_DATA(seg_DATA)
    );

endmodule