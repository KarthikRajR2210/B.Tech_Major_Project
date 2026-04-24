module timer_down #(parameter W = 6)(
  input clk,
  input rst_n,
  input start,
  input [W-1:0] load_val,
  output reg running,
  output reg done_pulse,
  output reg [W-1:0] count_q
);

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      count_q    <= {W{1'b0}};
      running    <= 1'b0;
      done_pulse <= 1'b0;
    end else begin
      done_pulse <= 1'b0;

      if (start) begin
        if (load_val != 0) begin
          count_q <= load_val;
          running <= 1'b1;
        end else begin
          count_q <= 0;
          running <= 1'b0;
        end
      end else if (running) begin
        if (count_q == 1) begin
          count_q    <= 0;
          running    <= 1'b0;
          done_pulse <= 1'b1;
        end else begin
          count_q <= count_q - 1'b1;
        end
      end
    end
  end

endmodule