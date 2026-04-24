module output_control (
  input clk,
  input rst_n,
  input slow_en,
  input led_enable,
  input use_ramp_brightness,

  input [3:0] cfg_brightness,
  input [3:0] ramp_brightness,

  output reg [2:0] led_out
);

  reg [3:0] duty_sel;
  wire pwm_sig;

  always @(*) begin
    if (use_ramp_brightness)
      duty_sel = ramp_brightness;
    else
      duty_sel = cfg_brightness;
  end

  pwm #(4) u_pwm (
    .clk(clk),
    .rst_n(rst_n),
    .en(led_enable),
    .duty(duty_sel),
    .pwm_out(pwm_sig),
    .slow_en(slow_en)
  );

  always @(*) begin
    led_out[0] = pwm_sig;
    led_out[1] = pwm_sig;
    led_out[2] = pwm_sig;
  end

endmodule