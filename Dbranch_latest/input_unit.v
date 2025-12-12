
module input_unit(
    input       clk,
    input       rst,
    input       enable,
    input       btn_zero,
    input       btn_one,
    input       btn_next,
    output reg [7:0] value,
    output reg       value_ready,
    output [7:0]     cur_value
);

    reg [2:0] bit_cnt;

    reg btn_zero_d, btn_one_d, btn_next_d;
    wire zero_rise = btn_zero & ~btn_zero_d;
    wire one_rise  = btn_one  & ~btn_one_d;
    wire next_rise = btn_next & ~btn_next_d;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            btn_zero_d <= 1'b0;
            btn_one_d  <= 1'b0;
            btn_next_d <= 1'b0;
        end else begin
            btn_zero_d <= btn_zero;
            btn_one_d  <= btn_one;
            btn_next_d <= btn_next;
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            value       <= 8'd0;
            bit_cnt     <= 3'd0;
            value_ready <= 1'b0;
        end else begin
            value_ready <= 1'b0;

            if (enable) begin
                if (zero_rise && bit_cnt < 3'd8) begin
                    value   <= {value[6:0], 1'b0};
                    bit_cnt <= bit_cnt + 3'd1;
                end
                else if (one_rise && bit_cnt < 3'd8) begin
                    value   <= {value[6:0], 1'b1};
                    bit_cnt <= bit_cnt + 3'd1;
                end

                if (next_rise && bit_cnt == 3'd8) begin
                    value_ready <= 1'b1;
                    bit_cnt     <= 3'd0;
                end
            end else begin
                bit_cnt <= 3'd0;
                value   <= 8'd0;
            end
        end
    end

endmodule
