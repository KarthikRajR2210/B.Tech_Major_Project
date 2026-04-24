module decoder (
  input [15:0] pkt,

  output reg [1:0] mode,
  output reg [2:0] color,
  output reg [3:0] brightness,
  output reg [5:0] time_val
);

  always @(*) begin
    mode       = pkt[15:14];
    color      = pkt[12:10];
    brightness = pkt[9:6];
    time_val   = pkt[5:0];
  end

endmodule