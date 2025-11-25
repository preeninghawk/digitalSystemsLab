module InputModule(
    input CLK,
    input WR_EN,         // Write enable
    input RD_EN,         // Read enable
    input selectAB,      // 0 = write A, 1 = write B
    input [7:0] keyIn,   // keypad input (0-9)
    output reg [7:0] readData,  // output for read mode
    output reg doneA,
    output reg doneB
);

    // INTERNAL MEMORIES (legal Verilog)
    reg [3:0] vectorA [0:7];
    reg [3:0] vectorB [0:7];

    integer indexA;
    integer indexB;
    integer readIndex;

    // Initialize memory
    initial begin
        indexA = 0;
        indexB = 0;
        readIndex = 0;
        doneA = 0;
        doneB = 0;
    end

    // MAIN LOGIC
    always @(posedge CLK) begin
        if (WR_EN) begin
            if (selectAB == 0) begin
                vectorA[indexA] <= keyIn;
                indexA <= indexA + 1;
                if (indexA == 7) begin
                    doneA <= 1;
                end
            end else begin
                vectorB[indexB] <= keyIn;
                indexB <= indexB + 1;
                if (indexB == 7) begin
                    doneB <= 1;
                end
            end
        end
        else if (RD_EN) begin
            readData <= vectorA[readIndex];  // default read A
            readIndex <= readIndex + 1;
        end
    end

    // ===== Debug tasks for testbench =====
    task printA;
        integer i;
        begin
            $display("---- DUMP VECTOR A ----");
            for (i = 0; i < 8; i = i + 1)
                $display("A[%0d] = %d", i, vectorA[i]);
        end
    endtask

    task printB;
        integer i;
        begin
            $display("---- DUMP VECTOR B ----");
            for (i = 0; i < 8; i = i + 1)
                $display("B[%0d] = %d", i, vectorB[i]);
        end
    endtask

endmodule
