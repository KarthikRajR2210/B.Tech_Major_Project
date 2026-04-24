

module pattern_fsm #(
  parameter BLINK_ON_TICKS     = 6'd20,
  parameter BLINK_OFF_TICKS    = 6'd20,
  parameter PULSE_ON_TICKS     = 6'd15,
  parameter PULSE_OFF_TICKS     = 6'd30,
  parameter BREATHE_STEP_TICKS = 6'd2
)(


  input clk,
  input rst_n,

  input [1:0] cfg_mode,
  input [3:0] cfg_brightness,
  input [5:0] cfg_time,

  input cmd_update_pulse,

  input phase_done,
  input duration_done,

  input [3:0] ramp_value,

  output reg phase_start,
  output reg [5:0] phase_load,

  output reg duration_start,
  output reg [5:0] duration_load,

  output reg ramp_clr,
  output reg ramp_step,
  output reg ramp_dir_up,

  output reg led_enable,
  output reg use_ramp_brightness,

  output pattern_active,
  output [2:0] state_dbg
);
  // Modes
localparam MODE_IDLE    = 2'b00;
localparam MODE_BLINK   = 2'b01;
localparam MODE_BREATHE = 2'b10;
localparam MODE_PULSE   = 2'b11;

// States
localparam S_IDLE      = 3'd0;
localparam S_ON        = 3'd1;
localparam S_OFF       = 3'd2;
localparam S_RAMP_UP   = 3'd3;
localparam S_RAMP_DOWN = 3'd4;
  reg [2:0] state_q, state_d;

  assign pattern_active = (state_q != S_IDLE);
  assign state_dbg = state_q;

  always @(*) begin
    state_d = state_q;

    phase_start = 0;
    phase_load  = 0;

    duration_start = 0;
    duration_load  = cfg_time;

    ramp_clr = 0;
    ramp_step = 0;
    ramp_dir_up = 1;

    led_enable = 0;
    use_ramp_brightness = 0;

    case (state_q)

      S_IDLE: begin
        ramp_clr = 1;

        if (cfg_mode == MODE_BLINK) begin
          state_d = S_ON;
          phase_start = 1;
          phase_load = BLINK_ON_TICKS;
          if (cfg_time != 0) duration_start = 1;
        end
        else if (cfg_mode == MODE_BREATHE) begin
          state_d = S_RAMP_UP;
          phase_start = 1;
          phase_load = BREATHE_STEP_TICKS;
          if (cfg_time != 0) duration_start = 1;
        end
        else if (cfg_mode == MODE_PULSE) begin
          state_d = S_ON;
          phase_start = 1;
          phase_load = PULSE_ON_TICKS;
          if (cfg_time != 0) duration_start = 1;
        end
      end

      S_ON: begin
        led_enable = 1;

        if (duration_done || cmd_update_pulse)
          state_d = S_IDLE;
        else if (phase_done) begin
          if (cfg_mode == MODE_BLINK) begin
            state_d = S_OFF;
            phase_start = 1;
            phase_load = BLINK_OFF_TICKS;
          end else if (cfg_mode == MODE_PULSE) begin
            state_d = S_OFF;
            phase_start = 1;
            phase_load = PULSE_OFF_TICKS;
            end else
              state_d = S_IDLE;
        end
      end

      S_OFF: begin
        if (duration_done || cmd_update_pulse)
          state_d = S_IDLE;
        else if (phase_done) begin
          if (cfg_mode == MODE_BLINK) begin
            state_d = S_ON;
            phase_start = 1;
            phase_load = BLINK_ON_TICKS;
          end else if (cfg_mode == MODE_PULSE) begin
            state_d = S_ON;
            phase_start = 1;
            phase_load = PULSE_ON_TICKS;
            end else
              state_d = S_IDLE;
        end
      end

      S_RAMP_UP: begin
        led_enable = 1;
        use_ramp_brightness = 1;

        if (duration_done || cmd_update_pulse)
          state_d = S_IDLE;
        else if (phase_done) begin
          ramp_step = 1;
          phase_start = 1;
          phase_load = BREATHE_STEP_TICKS;

          if ((ramp_value + 1) >= cfg_brightness)
            state_d = S_RAMP_DOWN;
        end
      end

      S_RAMP_DOWN: begin
        led_enable = 1;
        use_ramp_brightness = 1;
        ramp_dir_up = 0;

        if (duration_done || cmd_update_pulse)
          state_d = S_IDLE;
        else if (phase_done) begin
          ramp_step = 1;
          phase_start = 1;
          phase_load = BREATHE_STEP_TICKS;

          if (ramp_value <= 1)
            state_d = S_RAMP_UP;
        end
      end

      default: state_d = S_IDLE;

    endcase
  end

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
      state_q <= S_IDLE;
    else
      state_q <= state_d;
  end

endmodule