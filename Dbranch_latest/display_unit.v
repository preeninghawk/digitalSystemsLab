
module display_unit(
    input        clk,
    input        rst,
    input        enable,
    input  [7:0] value,
    output reg [7:0] seg_COM,
    output reg [7:0] seg_DATA
);

    reg [15:0] refresh_cnt;
    always @(posedge clk or posedge rst) begin
        if (rst) refresh_cnt <= 16'd0;
        else     refresh_cnt <= refresh_cnt + 16'd1;
    end

    wire [2:0] digit_sel = refresh_cnt[15:13];

    reg [3:0] hundreds, tens, ones;
    integer v;
    always @(*) begin
       
        v = value;
        if (v > 255) v = 255;

        hundreds = v / 100;
        tens     = (v % 100) / 10;
        ones     = v % 10;
    end

    wire [7:0] seg_h, seg_t, seg_o;

    bcd_to_7seg u_h(.bcd(hundreds), .seg(seg_h));
    bcd_to_7seg u_t(.bcd(tens),     .seg(seg_t));
    bcd_to_7seg u_o(.bcd(ones),     .seg(seg_o));

    reg [7:0] seg_COM_next, seg_DATA_next;

    always @(*) begin
        if (!enable) begin
            seg_COM_next  = 8'b11111111;
            seg_DATA_next = 8'b00000000;
        end else begin
            case (digit_sel)
                3'd0: begin
                    seg_COM_next  = 8'b11111110;
                    seg_DATA_next = seg_o;
                end
                3'd1: begin
                    seg_COM_next  = 8'b11111101;
                    seg_DATA_next = seg_t;
                end
                3'd2: begin
                    seg_COM_next  = 8'b11111011;
                    seg_DATA_next = seg_h;
                end
                default: begin
                    seg_COM_next  = 8'b11111111;
                    seg_DATA_next = 8'b00000000;
                end
            endcase
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            seg_COM  <= 8'b11111111;
            seg_DATA <= 8'b00000000;
        end else begin
            seg_COM  <= seg_COM_next;
            seg_DATA <= seg_DATA_next;
        end
    end

endmodule
