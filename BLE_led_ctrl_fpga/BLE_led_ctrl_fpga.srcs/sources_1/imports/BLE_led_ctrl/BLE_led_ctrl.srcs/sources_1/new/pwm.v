module pwm #(parameter W = 4)(
  input clk,
  input slow_en,
  input rst_n,
  input en,
  input [W-1:0] duty,
  output pwm_out
);

  reg [W-1:0] ctr_q;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
      ctr_q <= 0;
    else if (en)
      ctr_q <= ctr_q + 1'b1;
    else if (!en)
      ctr_q <= 0;
  end
// duty == {W{1'b1}} forces full on; otherwise strictly les than 
  assign pwm_out = en && ((duty == {W{1'b1}})|| (ctr_q < duty));

endmodule