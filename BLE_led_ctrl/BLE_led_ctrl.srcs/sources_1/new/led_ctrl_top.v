

module led_ctrl_top (
  input clk,
  input rst_n,

  // Bluetooth-stack-facing side
  input stack_valid,
  output stack_ready,
  input [15:0] stack_data,

  // LED outputs
  output [2:0] led_out
);

  // ------------------------------------------------------------
  // Command Interface
  // ------------------------------------------------------------
  wire        cmd_valid;
  wire        cmd_ready;
  wire [15:0] cmd_data;
  

  cmd_interface #(16) u_cmd_if (
    .clk      (clk),
    .rst_n    (rst_n),
    .in_valid (stack_valid),
    .in_ready (stack_ready),
    .in_data  (stack_data),
    .out_valid(cmd_valid),
    .out_ready(cmd_ready),
    .out_data (cmd_data)
  );
// Mapping switches to stack_data while tying Bit 13 and Bits 12:10 to Zero
  assign cmd_ready = 1'b1; // always consume

  // ------------------------------------------------------------
  // Decoder
  // ------------------------------------------------------------
  wire [1:0] dec_mode;
  wire [2:0] dec_color;
  wire [3:0] dec_brightness;
  wire [5:0] dec_time;

  decoder u_dec (
    .pkt       (cmd_data),
    .mode      (dec_mode),
    .color     (dec_color),
    .brightness(dec_brightness),
    .time_val  (dec_time)
  );

  wire reg_wr_en;
  assign reg_wr_en = cmd_valid & cmd_ready;

  // ------------------------------------------------------------
  // Register File
  // ------------------------------------------------------------
  wire [1:0] cfg_mode;
  wire [2:0] cfg_color;
  wire [3:0] cfg_brightness;
  wire [5:0] cfg_time;

  wire       sts_active;
  wire [2:0] sts_state;

  reg_file u_regs (
    .clk           (clk),
    .rst_n         (rst_n),
    .wr_en         (reg_wr_en),
    .wr_mode       (dec_mode),
    .wr_color      (dec_color),
    .wr_brightness (dec_brightness),
    .wr_time       (dec_time),
    .cfg_mode      (cfg_mode),
    .cfg_color     (cfg_color),
    .cfg_brightness(cfg_brightness),
    .cfg_time      (cfg_time),
    .sts_active_in (sts_active),
    .sts_state_in  (sts_state),
    .sts_active    (),
    .sts_state     ()
  );

  // ------------------------------------------------------------
  // Phase Timer
  // ------------------------------------------------------------
  wire       phase_start;
  wire [5:0] phase_load;
  wire       phase_running;
  wire       phase_done;
  wire [5:0] phase_count;

  timer_down #(6) u_phase_timer (
    .clk       (clk),
    .rst_n     (rst_n),
    .start     (phase_start),
    .load_val  (phase_load),
    .running   (phase_running),
    .done_pulse(phase_done),
    .count_q   (phase_count)
  );

  // ------------------------------------------------------------
  // Duration Timer
  // ------------------------------------------------------------
  wire       duration_start;
  wire [5:0] duration_load;
  wire       duration_running;
  wire       duration_done;
  wire [5:0] duration_count;

  timer_down #(6) u_duration_timer (
    .clk       (clk),
    .rst_n     (rst_n),
    .start     (duration_start),
    .load_val  (duration_load),
    .running   (duration_running),
    .done_pulse(duration_done),
    .count_q   (duration_count)
  );

  // ------------------------------------------------------------
  // Ramp Counter
  // ------------------------------------------------------------
  wire       ramp_clr;
  wire       ramp_step;
  wire       ramp_dir_up;
  wire [3:0] ramp_value;

  ramp_counter #(4) u_ramp (
    .clk    (clk),
    .rst_n  (rst_n),
    .clr    (ramp_clr),
    .step   (ramp_step),
    .dir_up (ramp_dir_up),
    .value_q(ramp_value)
  );

  // ------------------------------------------------------------
  // Pattern FSM
  // ------------------------------------------------------------
  wire led_enable;
  wire use_ramp_brightness;
  wire pattern_active;
  wire [2:0] state_dbg;

  pattern_fsm u_fsm (
    .clk                 (clk),
    .rst_n               (rst_n),
    .cfg_mode            (cfg_mode),
    .cfg_brightness      (cfg_brightness),
    .cfg_time            (cfg_time),
    .cmd_update_pulse    (reg_wr_en),
    .phase_done          (phase_done),
    .duration_done       (duration_done),
    .ramp_value          (ramp_value),
    .phase_start         (phase_start),
    .phase_load          (phase_load),
    .duration_start      (duration_start),
    .duration_load       (duration_load),
    .ramp_clr            (ramp_clr),
    .ramp_step           (ramp_step),
    .ramp_dir_up         (ramp_dir_up),
    .led_enable          (led_enable),
    .use_ramp_brightness (use_ramp_brightness),
    .pattern_active      (pattern_active),
    .state_dbg           (state_dbg)
  );

  assign sts_active = pattern_active;
  assign sts_state  = state_dbg;

  // ------------------------------------------------------------
  // Output Control
  // ------------------------------------------------------------
  output_control u_out (
    .clk                (clk),
    .rst_n              (rst_n),
    .led_enable         (led_enable),
    .use_ramp_brightness(use_ramp_brightness),
    .cfg_color          (cfg_color),
    .cfg_brightness     (cfg_brightness),
    .ramp_brightness    (ramp_value),
    .led_out            (led_out)
  );

endmodule