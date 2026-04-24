module decoder (
  input [7:0] pkt,

  output reg [1:0] mode,
  output reg [3:0] brightness,
  output reg [1:0] time_val
);

  always @(*) begin
    mode       = pkt[7:6];
    brightness = pkt[5:2];
    time_val   = pkt[1:0];
  end

endmodule