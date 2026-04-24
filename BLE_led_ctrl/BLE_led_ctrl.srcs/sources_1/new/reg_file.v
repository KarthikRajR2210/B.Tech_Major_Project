`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.04.2026 17:10:31
// Design Name: 
// Module Name: reg_file
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module reg_file (
  input clk,
  input rst_n,

  input wr_en,
  input [1:0] wr_mode,
  input [2:0] wr_color,
  input [3:0] wr_brightness,
  input [5:0] wr_time,

  output reg [1:0] cfg_mode,
  output reg [2:0] cfg_color,
  output reg [3:0] cfg_brightness,
  output reg [5:0] cfg_time,

  input sts_active_in,
  input [2:0] sts_state_in,

  output reg sts_active,
  output reg [2:0] sts_state
);

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      cfg_mode       <= 2'b00;
      cfg_color      <= 3'b000;
      cfg_brightness <= 4'hF;
      cfg_time       <= 6'd0;

      sts_active     <= 1'b0;
      sts_state      <= 3'd0;
    end else begin
      if (wr_en) begin
        cfg_mode       <= wr_mode;
        cfg_color      <= wr_color;
        cfg_brightness <= wr_brightness;
        cfg_time       <= wr_time;
      end

      sts_active <= sts_active_in;
      sts_state  <= sts_state_in;
    end
  end

endmodule
