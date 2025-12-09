
module controller(
    input        clk,
    input        rst,
    input  [7:0] input_value,
    input        input_value_ready,
    output reg   input_enable,
    output reg [3:0] ctrl_mem_addr,
    output reg       ctrl_mem_wr,
    output reg       mode_compute,
    output reg       comp_start,
    input            comp_done,
    input      [7:0] comp_result,
    output reg       display_enable,
    output reg [7:0] display_value
);
    localparam S_INPUT_A = 2'd0;
    localparam S_INPUT_B = 2'd1;
    localparam S_COMPUTE = 2'd2;
    localparam S_DISPLAY = 2'd3;

    reg [1:0] state;
    reg [2:0] elem_idx;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state          <= S_INPUT_A;
            elem_idx       <= 3'd0;
            input_enable   <= 1'b1;
            ctrl_mem_addr  <= 4'd0;
            ctrl_mem_wr    <= 1'b0;
            mode_compute   <= 1'b0;
            comp_start     <= 1'b0;
            display_enable <= 1'b0;
            display_value  <= 8'd0;
        end else begin

            ctrl_mem_wr    <= 1'b0;
            comp_start     <= 1'b0;
            display_enable <= 1'b0;

            case (state)
                S_INPUT_A: begin
                    input_enable <= 1'b1;
                    mode_compute <= 1'b0;

                    if (input_value_ready) begin
                        ctrl_mem_addr <= {1'b0, elem_idx};
                        ctrl_mem_wr   <= 1'b1;

                        if (elem_idx == 3'd7) begin
                            elem_idx <= 3'd0;
                            state    <= S_INPUT_B;
                        end else begin
                            elem_idx <= elem_idx + 3'd1;
                        end
                    end
                end

                S_INPUT_B: begin
                    input_enable <= 1'b1;
                    mode_compute <= 1'b0;

                    if (input_value_ready) begin
                        ctrl_mem_addr <= 4'd8 + {1'b0, elem_idx};
                        ctrl_mem_wr   <= 1'b1;

                        if (elem_idx == 3'd7) begin
                            elem_idx     <= 3'd0;
                            state        <= S_COMPUTE;
                            mode_compute <= 1'b1;
                            comp_start   <= 1'b1;
                        end else begin
                            elem_idx <= elem_idx + 3'd1;
                        end
                    end
                end

                S_COMPUTE: begin
                    input_enable <= 1'b0;
                    mode_compute <= 1'b1;

                    if (comp_done) begin
                        display_value <= comp_result;
                        state         <= S_DISPLAY;
                        mode_compute  <= 1'b0;
                    end
                end

                S_DISPLAY: begin
                    input_enable   <= 1'b0;
                    mode_compute   <= 1'b0;
                    display_enable <= 1'b1;
                end
            endcase
        end
    end
endmodule
