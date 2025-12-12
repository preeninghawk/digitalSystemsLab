`timescale 1ns/1ps

module term_project_top_tb;

    reg         clk;
    reg  [7:0]  btn_sw;
    wire [7:0]  seg_COM;
    wire [7:0]  seg_DATA;

    // 버튼 인덱스 정의
    localparam integer IDX_A = 0;  // bit0 → A key = 0 입력
    localparam integer IDX_B = 1;  // bit1 → B key = 1 입력
    localparam integer IDX_C = 2;  // next input
    localparam integer IDX_D = 3;  // reset

    localparam real CLK_PERIOD = 10.0; // 100 MHz (시뮬용)

    // ▼ DUT 인스턴스 — 네 top 모듈 이름/포트에 맞춰 수정 가능
    term_project_top dut (
        .CLK     (clk),
        .btn_sw  (btn_sw),
        .seg_COM (seg_COM),
        .seg_DATA(seg_DATA)
    );

    // 클럭 생성
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2.0) clk = ~clk;
    end

    // 초기 버튼 상태 (inactive = 1)
    initial begin
        btn_sw = 8'hFF;
    end

    // 버튼 1회 누름
    task press_btn(input integer idx);
    begin
        btn_sw[idx] = 0;
        #(5*CLK_PERIOD);
        btn_sw[idx] = 1;
        #(5*CLK_PERIOD);
    end
    endtask

    // 8비트 정수 입력
    task send_byte(input [7:0] value);
        integer i;
    begin
        for (i = 7; i >= 0; i = i - 1) begin
            if (value[i] == 1)
                press_btn(IDX_B);
            else
                press_btn(IDX_A);
        end
        press_btn(IDX_C); // 정수 완료
    end
    endtask

    // 전체 시나리오
    initial begin
        
        #(10*CLK_PERIOD);
        press_btn(IDX_D); // reset

        #(20*CLK_PERIOD);

        // A 벡터 입력
        send_byte(8'd1);
        send_byte(8'd0);
        send_byte(8'd0);
        send_byte(8'd0);
        send_byte(8'd0);
        send_byte(8'd0);
        send_byte(8'd0);
        send_byte(8'd0);

        // B 벡터 입력
        send_byte(8'd5);
        send_byte(8'd0);
        send_byte(8'd0);
        send_byte(8'd0);
        send_byte(8'd0);
        send_byte(8'd0);
        send_byte(8'd0);
        send_byte(8'd0);

        #(200*CLK_PERIOD);

        $stop;
    end

endmodule
