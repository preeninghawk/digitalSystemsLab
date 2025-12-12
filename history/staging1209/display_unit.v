module display_unit(
    input        clk,
    input        rst,
    input        enable,
    input  [7:0] value,
    output reg [7:0] seg_COM,
    output reg [7:0] seg_DATA
);

    // Fast refresh counter for simulation
    reg [7:0] refresh_cnt;
    always @(posedge clk or posedge rst) begin
        if (rst) refresh_cnt <= 8'd0;
        else     refresh_cnt <= refresh_cnt + 8'd1;
    end

    // Use top 3 bits to select which digit (0-7)
    wire [2:0] digit_sel = refresh_cnt[7:5];

    // Extract 8 decimal digits from value (handles up to 99,999,999)
    // For 8-bit input (0-255), we only need 3 digits but structure supports 8
    reg [3:0] digit [7:0];
    integer temp_val;
    integer i;
    
    always @(*) begin
        temp_val = value;
        if (temp_val > 99999999) temp_val = 99999999; // Cap at 8 digits
        
        // Extract each digit
        for (i = 0; i < 8; i = i + 1) begin
            digit[i] = temp_val % 10;
            temp_val = temp_val / 10;
        end
    end

    // Generate 7-segment patterns for each digit
    wire [7:0] seg_pattern [7:0];
    
    genvar g;
    generate
        for (g = 0; g < 8; g = g + 1) begin : seg_gen
            bcd_to_7seg u_seg(.bcd(digit[g]), .seg(seg_pattern[g]));
        end
    endgenerate

    // Multiplexer logic
    reg [7:0] seg_COM_next, seg_DATA_next;

    always @(*) begin
        if (!enable) begin
            seg_COM_next  = 8'b11111111;
            seg_DATA_next = 8'b00000000;
        end else begin
            // Select which digit to display
            case (digit_sel)
                3'd0: begin
                    seg_COM_next  = 8'b11111110;
                    seg_DATA_next = seg_pattern[0];
                end
                3'd1: begin
                    seg_COM_next  = 8'b11111101;
                    seg_DATA_next = seg_pattern[1];
                end
                3'd2: begin
                    seg_COM_next  = 8'b11111011;
                    seg_DATA_next = seg_pattern[2];
                end
                3'd3: begin
                    seg_COM_next  = 8'b11110111;
                    seg_DATA_next = seg_pattern[3];
                end
                3'd4: begin
                    seg_COM_next  = 8'b11101111;
                    seg_DATA_next = seg_pattern[4];
                end
                3'd5: begin
                    seg_COM_next  = 8'b11011111;
                    seg_DATA_next = seg_pattern[5];
                end
                3'd6: begin
                    seg_COM_next  = 8'b10111111;
                    seg_DATA_next = seg_pattern[6];
                end
                3'd7: begin
                    seg_COM_next  = 8'b01111111;
                    seg_DATA_next = seg_pattern[7];
                end
            endcase
        end
    end

    // Register outputs
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