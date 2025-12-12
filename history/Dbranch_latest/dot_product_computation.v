
module dot_product_computation(
    input        clk,
    input        rst,
    input        start,
    input  [7:0] mem_data_in,
    output reg [3:0] mem_addr,
    output reg       mem_wr,
    output reg       done,
    output reg [7:0] result
);

    localparam C_IDLE    = 3'd0;
    localparam C_LOAD_A  = 3'd1;
    localparam C_WAIT_A  = 3'd2;
    localparam C_LOAD_B  = 3'd3;
    localparam C_WAIT_B  = 3'd4;
    localparam C_ACCUM   = 3'd5;
    localparam C_DONE    = 3'd6;

    reg [2:0] state;
    reg [2:0] index;
    reg [7:0] a_reg, b_reg;
    reg [15:0] sum;

    wire [15:0] prod;
    mult8x8_struct u_mult(.a(a_reg), .b(b_reg), .p(prod));

    wire [15:0] sum_next;
    wire        cout_sum;
    adder16_fa u_add(.a(sum), .b(prod), .sum(sum_next), .cout(cout_sum));

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state    <= C_IDLE;
            index    <= 3'd0;
            a_reg    <= 8'd0;
            b_reg    <= 8'd0;
            sum      <= 16'd0;
            mem_addr <= 4'd0;
            mem_wr   <= 1'b0;
            done     <= 1'b0;
            result   <= 8'd0;
        end else begin
            mem_wr <= 1'b0;
            done   <= 1'b0;

            case (state)
                C_IDLE: begin
                    if (start) begin
                        index <= 3'd0;
                        sum   <= 16'd0;
                        state <= C_LOAD_A;
                    end
                end

                C_LOAD_A: begin
                    mem_addr <= {1'b0, index};
                    state    <= C_WAIT_A;
                end

                C_WAIT_A: begin
                    a_reg <= mem_data_in;
                    state <= C_LOAD_B;
                end

                C_LOAD_B: begin
                    mem_addr <= 4'd8 + {1'b0, index};
                    state    <= C_WAIT_B;
                end

                C_WAIT_B: begin
                    b_reg <= mem_data_in;
                    state <= C_ACCUM;
                end

                C_ACCUM: begin
                    sum <= sum_next;
                    if (index == 3'd7) begin
                        result <= sum_next[7:0];
                        state  <= C_DONE;
                    end else begin
                        index <= index + 3'd1;
                        state <= C_LOAD_A;
                    end
                end

                C_DONE: begin
                    done  <= 1'b1;
                    state <= C_IDLE;
                end
            endcase
        end
    end

endmodule
