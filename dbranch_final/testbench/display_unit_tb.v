`timescale 1ns / 1ps

// NOTICE : this takes more than 30us to be displayed correctly. please run this for more than 30us. 
// 30us 이상 시뮬레이션 해주세요

module display_unit_tb;

    reg clk;
    reg rst;
    reg enable;
    reg [7:0] value;
    wire [7:0] seg_COM;
    wire [7:0] seg_DATA;

    // DUT
    display_unit dut(
        .clk(clk),
        .rst(rst),
        .enable(enable),
        .value(value),
        .seg_COM(seg_COM),
        .seg_DATA(seg_DATA)
    );

    // Clock generation (faster for simulation)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Function to decode 7-segment to digit
    function [3:0] seg_to_digit;
        input [7:0] seg;
        begin
            case (seg)
                8'b11111100: seg_to_digit = 4'd0;
                8'b01100000: seg_to_digit = 4'd1;
                8'b11011010: seg_to_digit = 4'd2;
                8'b11110010: seg_to_digit = 4'd3;
                8'b01100110: seg_to_digit = 4'd4;
                8'b10110110: seg_to_digit = 4'd5;
                8'b10111110: seg_to_digit = 4'd6;
                8'b11100000: seg_to_digit = 4'd7;
                8'b11111110: seg_to_digit = 4'd8;
                8'b11110110: seg_to_digit = 4'd9;
                8'b00000000: seg_to_digit = 4'd15; // blank
                default:     seg_to_digit = 4'd15; // unknown
            endcase
        end
    endfunction

    // Monitor digit display
    reg [3:0] displayed_digit;
    reg [2:0] active_position;
    
    always @(*) begin
        displayed_digit = seg_to_digit(seg_DATA);
        case (seg_COM)
            8'b11111110: active_position = 0; // ones
            8'b11111101: active_position = 1; // tens
            8'b11111011: active_position = 2; // hundreds
            default:     active_position = 7; // none
        endcase
    end

    // Test stimulus
    initial begin
        $display("Starting display_unit testbench");
        
        // Initialize
        rst = 1;
        enable = 0;
        value = 8'd0;
        
        #20;
        rst = 0;
        #20;
        
        // Test 1: Display disabled
        $display("\n=== Test 1: Display Disabled ===");
        enable = 0;
        value = 8'd123;
        #1000;
        $display("When disabled: seg_COM=%b, seg_DATA=%b", seg_COM, seg_DATA);
        if (seg_COM == 8'b11111111 && seg_DATA == 8'b00000000) begin
            $display("PASS: Display correctly off");
        end else begin
            $display("FAIL: Display should be off");
        end
        
        // Test 2: Display value 0
        $display("\n=== Test 2: Display Value 0 ===");
        enable = 1;
        value = 8'd0;
        #20000; // Wait for several refresh cycles
        $display("Value 0 should show: 000");
        
        // Test 3: Display value 123
        $display("\n=== Test 3: Display Value 123 ===");
        value = 8'd123;
        #20000;
        $display("Value 123 should show: 123");
        
        // Test 4: Display value 255
        $display("\n=== Test 4: Display Value 255 ===");
        value = 8'd255;
        #20000;
        $display("Value 255 should show: 255");
        
        // Test 5: Display value 42
        $display("\n=== Test 5: Display Value 42 ===");
        value = 8'd42;
        #20000;
        $display("Value 42 should show: 042");
        
        // Test 6: Display value 9
        $display("\n=== Test 6: Display Value 9 ===");
        value = 8'd9;
        #20000;
        $display("Value 9 should show: 009");
        
        // Test 7: Rapid value changes
        $display("\n=== Test 7: Rapid Value Changes ===");
        value = 8'd100;
        #5000;
        value = 8'd200;
        #5000;
        value = 8'd50;
        #5000;
        $display("Tested rapid changes");
        
        // Test 8: Re-disable display
        $display("\n=== Test 8: Disable Display ===");
        enable = 0;
        #1000;
        $display("After disable: seg_COM=%b, seg_DATA=%b", seg_COM, seg_DATA);
        
        #10000;
        $display("\nTestbench complete");
        $finish;
    end
    
    // Detailed monitor for a few cycles
    integer monitor_count = 0;
    always @(posedge clk) begin
        if (enable && monitor_count < 20) begin
            if (active_position < 3) begin
                $display("Time %0t: pos=%0d, digit=%0d, COM=%b, DATA=%b", 
                         $time, active_position, displayed_digit, seg_COM, seg_DATA);
                monitor_count = monitor_count + 1;
            end
        end
    end
    
    // Verify digit extraction for each position - FIXED VERSION
    reg [3:0] captured_ones, captured_tens, captured_hundreds;
    reg ones_captured, tens_captured, hundreds_captured;
    
    initial begin
        captured_ones = 4'hX;
        captured_tens = 4'hX;
        captured_hundreds = 4'hX;
        ones_captured = 0;
        tens_captured = 0;
        hundreds_captured = 0;
    end
    
    always @(posedge clk) begin
        if (enable && value == 8'd123) begin
            // Capture each digit independently when it appears
            if (active_position == 0 && !ones_captured) begin
                captured_ones = displayed_digit;
                ones_captured = 1;
                $display("Time %0t: Captured ones digit: %0d", $time, displayed_digit);
            end
            
            if (active_position == 1 && !tens_captured) begin
                captured_tens = displayed_digit;
                tens_captured = 1;
                $display("Time %0t: Captured tens digit: %0d", $time, displayed_digit);
            end
            
            if (active_position == 2 && !hundreds_captured) begin
                captured_hundreds = displayed_digit;
                hundreds_captured = 1;
                $display("Time %0t: Captured hundreds digit: %0d", $time, displayed_digit);
            end
            
            // Check when all three are captured
            if (ones_captured && tens_captured && hundreds_captured) begin
                $display("\n*** All digits captured: %0d%0d%0d ***", 
                         captured_hundreds, captured_tens, captured_ones);
                if (captured_hundreds == 1 && captured_tens == 2 && captured_ones == 3) begin
                    $display("*** PASS: Correctly displaying 123 ***\n");
                end else begin
                    $display("*** FAIL: Expected 123, got %0d%0d%0d ***\n", 
                             captured_hundreds, captured_tens, captured_ones);
                end
                // Reset for potential re-test
                ones_captured = 0;
                tens_captured = 0;
                hundreds_captured = 0;
            end
        end
        
        // Reset capture flags when value changes
        if (value != 8'd123) begin
            ones_captured = 0;
            tens_captured = 0;
            hundreds_captured = 0;
        end
    end
    
    // Timeout
    initial begin
        #200000;
        $display("Testbench timeout (not an error, just done)");
        $finish;
    end

endmodule