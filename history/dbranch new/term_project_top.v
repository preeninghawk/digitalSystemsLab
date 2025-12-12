//======================================
// Top module
//======================================
module term_project_top(
    input        CLK,          // Board clock
    input  [7:0] btn_sw,       // Button switches SW_A..SW_H (active-low)
    output [7:0] seg_COM,      // 7-seg common (active-low)
    output [7:0] seg_DATA,      // 7-seg data (a,b,c,d,e,f,g,dp), active-high
    output [7:0] led
);

    wire btn_a = btn_sw[0];   // A: bit 0
    wire btn_b = btn_sw[1];   // B: bit 1
    wire btn_c = btn_sw[2];   // C: 8-bit integer confirm
    wire btn_d = btn_sw[3];   // D: reset

    wire rst = btn_d;

    wire        input_enable;
    wire [7:0]  input_value;
    wire        input_value_ready;

    wire [3:0]  ctrl_mem_addr;
    wire        ctrl_mem_wr;

    wire [3:0]  comp_mem_addr;
    wire        comp_mem_wr;

    wire [3:0]  mem_addr_4;
    wire        mem_wr;
    wire [7:0]  mem_data_in;
    wire [7:0]  mem_data_out;

    wire        comp_start;
    wire        comp_done;
    wire [7:0]  comp_result;

    wire        display_enable;
    wire [7:0]  display_value;

    wire        mode_compute;
    wire [7:0]  cur_input_value;
    // Input Unit
    input_unit u_input(
        .clk         (CLK),
        .rst         (rst),
        .enable      (input_enable),
        .btn_zero    (btn_a),
        .btn_one     (btn_b),
        .btn_next    (btn_c),
        .value       (input_value),
        .value_ready (input_value_ready),
        .cur_value(cur_input_value)
    );
    assign led = cur_input_value;
    // Computation Unit
    dot_product_computation u_comp(
        .clk        (CLK),
        .rst        (rst),
        .start      (comp_start),
        .mem_data_in(mem_data_out),
        .mem_addr   (comp_mem_addr),
        .mem_wr     (comp_mem_wr),
        .done       (comp_done),
        .result     (comp_result)
    );

    // Controller
    controller u_ctrl(
        .clk              (CLK),
        .rst              (rst),
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

    assign mem_addr_4 = mode_compute ? comp_mem_addr : ctrl_mem_addr;
    assign mem_wr = mode_compute ? 1'b0 : ctrl_mem_wr;

    assign mem_data_in = input_value;

    MEM16x8 u_mem(
        .CLK     (CLK),
        .WR      (mem_wr),
        .ADDR    (mem_addr_4),
        .DATA_IN (mem_data_in),
        .DATA_OUT(mem_data_out)
    );

    display_unit u_disp(
        .clk     (CLK),
        .rst     (rst),
        .enable  (display_enable),
        .value   (display_value),
        .seg_COM (seg_COM),
        .seg_DATA(seg_DATA)
    );

endmodule
