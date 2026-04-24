module cmd_interface #(parameter W = 16)(
  input clk,
  input rst_n,

  input in_valid,
  output in_ready,
  input [W-1:0] in_data,

  output out_valid,
  input out_ready,
  output [W-1:0] out_data
);

  reg full;
  reg [W-1:0] buf_q;

  assign out_valid = full;
  assign out_data  = buf_q;
  assign in_ready  = ~full || (out_valid && out_ready);

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      full  <= 1'b0;
      buf_q <= {W{1'b0}};
    end else begin
      if (out_valid && out_ready)
        full <= 1'b0;

      if (in_valid && in_ready) begin
        buf_q <= in_data;
        full  <= 1'b1;
      end
    end
  end

endmodule