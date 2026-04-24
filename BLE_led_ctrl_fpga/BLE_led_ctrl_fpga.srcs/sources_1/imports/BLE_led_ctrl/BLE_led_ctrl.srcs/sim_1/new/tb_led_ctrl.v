//`timescale 1ns/1ps
////`default_nettype none

//module tb_led_ctrl_top;

//  // ------------------------------------------------------------
//  // DUT Signals
//  // ------------------------------------------------------------
//  reg clk;
//  reg rst_n;

//  reg        stack_valid;
//  wire       stack_ready;
//  reg [15:0] stack_data;

//  wire [2:0] led_out;

//  // ------------------------------------------------------------
//  // Instantiate DUT
//  // ------------------------------------------------------------
//  led_ctrl_top dut (
//    .clk         (clk),
//    .rst_n       (rst_n),
//    .stack_valid (stack_valid),
//    .stack_ready (stack_ready),
//    .stack_data  (stack_data),
//    .led_out     (led_out)
//  );

//  // ------------------------------------------------------------
//  // Clock: 100 MHz
//  // ------------------------------------------------------------
//  initial clk = 1'b0;
//  always #5 clk = ~clk;

//  // ------------------------------------------------------------
//  // Packet builder
//  // ------------------------------------------------------------
//  function [15:0] build_pkt;
//    input [1:0] mode;
//    input [2:0] color;
//    input [3:0] brightness;
//    input [5:0] duration;
//    begin
//      build_pkt = {mode, 1'b0, color, brightness, duration};
//    end
//  endfunction

//  // ------------------------------------------------------------
//  // Send command (1-cycle valid pulse)
//  // ------------------------------------------------------------
//  task send_cmd;
//    input [15:0] pkt;
//    begin
//      @(posedge clk);
//      stack_data  <= pkt;
//      stack_valid <= 1'b1;

//      @(posedge clk);
//      stack_valid <= 1'b0;
//    end
//  endtask

//  // ------------------------------------------------------------
//  // Dump waves
//  // ------------------------------------------------------------
//  initial begin
//    $dumpfile("led_ctrl.vcd");
//    $dumpvars(0, tb_led_ctrl_top);
//  end

//  // ------------------------------------------------------------
//  // Test sequence
//  // ------------------------------------------------------------
//  initial begin
//    // Init
//    stack_valid = 0;
//    stack_data  = 0;
//    rst_n       = 0;

//    // Reset
//    repeat (5) @(posedge clk);
//    rst_n = 1;

//    // ==========================================================
//    // 1. BLINK MODE
//    // ==========================================================
//    $display("\n--- BLINK MODE ---");
//    send_cmd(build_pkt(2'b01, 3'b111, 4'd10, 6'd40));

//    // Let blink run long enough
//    repeat (200) @(posedge clk);

//    // ==========================================================
//    // 2. PULSE MODE
//    // ==========================================================
//    $display("\n--- PULSE MODE ---");
//    send_cmd(build_pkt(2'b11, 3'b001, 4'd12, 6'd40));

//    // Observe pulse clearly
//    repeat (150) @(posedge clk);

//    // ==========================================================
//    // 3. BREATHE MODE (2 FULL CYCLES)
//    // ==========================================================
//    $display("\n--- BREATHE MODE ---");
//    send_cmd(build_pkt(2'b10, 3'b010, 4'd12, 6'd120));

//    // Long run → ensures full ramp up/down cycles
//    repeat (600) @(posedge clk);

//    // ==========================================================
//    // 4. CORNER CASE: MID-RUN UPDATE
//    // ==========================================================
//    $display("\n--- CORNER CASE: MID-RUN UPDATE ---");

//    // Start blink
//    send_cmd(build_pkt(2'b01, 3'b111, 4'd10, 6'd60));
//    repeat (80) @(posedge clk);

//    // Interrupt with breathe
//    send_cmd(build_pkt(2'b10, 3'b011, 4'd12, 6'd100));

//    // Observe transition behavior
//    repeat (400) @(posedge clk);

//    // ==========================================================
//    // DONE
//    // ==========================================================
//    $display("\nALL TESTS COMPLETED");
//    $finish;
//  end

//endmodule

////`default_nettype wire