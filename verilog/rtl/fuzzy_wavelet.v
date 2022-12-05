`default_nettype none
`timescale 1ns/1ns

module top #(
    parameter BITS_PER_ELEM = 8,
    parameter NUM_FIRS = 8, // NOTE: same as number of RS
    parameter SUM_TRUNCATION = 8
) (
`ifdef USE_POWER_PINS
  inout vdd,  // User area 1 1.8V power
  inout vss,  // User area 1 digital ground
`endif

    input wire clk,
    input wire rst,
    // 8 bit input from source
    input wire signed [BITS_PER_ELEM - 1:0] i_value,
    // data_input clock (rising edge)
    input wire i_data_clk,
    // multiplexing for output channels
    input wire [7:0] i_select_output_channel,
    // 8 bit output, channel selected by multiplexer
    output wire [SUM_TRUNCATION - 1:0] o_multiplexed_wavelet_out,
    // chip active gpio signal
    output wire o_active
);

  // Parameter maths outside of generator {{{
  parameter NUM_RS = NUM_FIRS;

  // output bits from rolling sums
  wire [BITS_PER_ELEM*NUM_RS - 1:0] w_truncated_rs_out; // include more bits as need
  wire [BITS_PER_ELEM*NUM_FIRS - 1:0] w_truncated_wt_out; // include more bits as need

  parameter RS_MAX_SIZE = 2**NUM_RS;

  parameter FIR_NUM_ELEM = 9;
  parameter SRL_RA_TOTAL_BITS = FIR_NUM_ELEM * BITS_PER_ELEM;

  parameter TOTAL_TAPS_IN_SRL = RS_MAX_SIZE + 1; // srl will need + 1 for stale value (for subtracting)
  parameter TOTAL_BITS = BITS_PER_ELEM * TOTAL_TAPS_IN_SRL;

  /* verilator lint_off UNUSED */
  wire [TOTAL_BITS - 1:0] taps;
  /* verilator lint_on UNUSED*/

  wire start_calc;
  // }}}

  // OUTPUT MULTIPLEXER {{{
  output_multiplexer #(
  .NUM_FIRS(NUM_FIRS + NUM_RS),
  .SUM_TRUNCATION(SUM_TRUNCATION)
  ) om_1 (
    .clk(clk),
    .rst(rst),
    .i_truncated_wavelet_out({w_truncated_wt_out, w_truncated_rs_out}),
    .i_select_output_channel(i_select_output_channel),
    .o_multiplexed_wavelet_out(o_multiplexed_wavelet_out)
  );
  // }}}

  // SHIFT REGISTER LINES {{{
  shift_register_line #(
    .BITS_PER_ELEM(BITS_PER_ELEM),
    .TOTAL_BITS(TOTAL_BITS)
  ) srl_1 (
    .clk(clk),
    .rst(rst),
    .i_value(i_value),
    .i_data_clk (i_data_clk),
    .o_start_calc (start_calc),
    .o_taps (taps[TOTAL_BITS-1:0])
  );

  // }}}

  // CocoSim {{{

  `ifdef COCOTB_SIM
    initial begin
      $dumpfile ("top.vcd");
      $dumpvars (0, top);
    end
  `endif

  // }}}

  // Active GPIO {{{
  reg active;
  assign o_active = active;

  // NOTE: signal that this module is active after pulling out of reset
  always @(posedge clk) begin
    if (rst) begin
      active <= 1'b0;
    end else begin
      active <= 1'b1;
    end
  end

  // }}}

  // Main Generator {{{
  genvar i;
  generate
    for (i = 1; i < (NUM_FIRS + 1); i = i + 1) begin // start at 1, no fir 0
      // RS_x_NUM_ELEM
      /* localparam RS_X_NUM_ELEM = 2**(i+1); // 1->4, 2->8, etc... */
      wire fir_start_calc;
      wire rs_shift_in_ready;
      wire [BITS_PER_ELEM*FIR_NUM_ELEM - 1:0] srl_ra_taps;

      srl_rolling_avg #(
        .BITS_PER_ELEM(BITS_PER_ELEM),
        .TOTAL_BITS(SRL_RA_TOTAL_BITS)
      ) srl_ra (
        .clk(clk),
        .rst(rst),
        .i_value(w_truncated_rs_out[BITS_PER_ELEM - 1:0]),
        .i_data_clk(rs_shift_in_ready),
        .o_start_calc(fir_start_calc),
        .o_taps(srl_ra_taps[SRL_RA_TOTAL_BITS - 1:0])
      );

      rolling_sum #(
        .BITS_PER_ELEM(BITS_PER_ELEM),
        .NUM_ELEM(2**(i+1)),
        .MAX_BITS($clog2(2**(i+1) * 255))
      ) rs (
        .clk(clk),
        .rst(rst),
        .i_new(taps[BITS_PER_ELEM - 1:0]),
        .i_old(taps[BITS_PER_ELEM*(2**(i+1) + 1) - 1:BITS_PER_ELEM*(2**(i+1))]),
        .i_start_calc(start_calc),
        .o_shift_in_rdy(rs_shift_in_ready),
        .o_rs(w_truncated_rs_out[(BITS_PER_ELEM*i) - 1:BITS_PER_ELEM*(i - 1)])
      );

      fir #(
        .BITS_PER_ELEM(BITS_PER_ELEM),
        .SUM_TRUNCATION(SUM_TRUNCATION),
        .NUM_ELEM(FIR_NUM_ELEM),
        .FILTER_VAL(72'hf6dcc51c7c1cc5dcf6),
        .MAX_BITS(16),
        .BASE_NUM_ELEM(FIR_NUM_ELEM)
      ) fir (
        .clk(clk),
        .rst(rst),
        .taps(srl_ra_taps[(BITS_PER_ELEM*FIR_NUM_ELEM) - 1:0]),
        .o_wavelet(w_truncated_wt_out[((i-1)*8)+:8]), // 1 -> 0, 2->8
        .i_start_calc(fir_start_calc)
      );
    end
  endgenerate
  // }}}

  endmodule
