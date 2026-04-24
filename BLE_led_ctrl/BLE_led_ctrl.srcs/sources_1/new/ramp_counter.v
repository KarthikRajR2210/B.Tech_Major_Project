
module ramp_counter #(parameter W = 4)(
  input clk,
  input rst_n,
  input clr,
  input step,
  input dir_up,
  output reg [W-1:0] value_q
);

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
      value_q <= 0;
    else if (clr)
      value_q <= 0;
    else if (step) begin
      if (dir_up) begin
        if (value_q != {W{1'b1}})
          value_q <= value_q + 1'b1;
      end else begin
        if (value_q != 0)
          value_q <= value_q - 1'b1;
      end
    end
  end

endmodule
