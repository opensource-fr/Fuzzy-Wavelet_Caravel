`default_nettype none
`timescale 1ns/1ns
`define M_T 6.2831853071

module fir #(
    parameter BITS_PER_ELEM = 8,
    parameter SUM_TRUNCATION = 8,
    parameter NUM_ELEM = 9,
    parameter FILTER_VAL = 0,
    parameter MAX_BITS = $clog2({BITS_PER_ELEM{1'b1}}*{BITS_PER_ELEM{1'b1}}*NUM_ELEM),
    parameter BASE_NUM_ELEM = 9
) (
    // Clock
    input wire clk,

    // Reset
    input wire rst,

    // signal to clock in data from inputs
    input wire i_start_calc,

    // TAPS
    input wire [NUM_ELEM * BITS_PER_ELEM - 1:0] taps,

    // Outputs
    output wire signed [SUM_TRUNCATION - 1:0] o_wavelet

);

  reg [NUM_ELEM * BITS_PER_ELEM - 1:0] filter;
  reg signed [MAX_BITS - 1:0] sum;

  initial begin
    // Ricker Equation: r(τ)=(1−1/2 * ω^2 * τ^2)exp(−1/4* ω^2 * τ^2),
    // see python code for calculations
    filter = FILTER_VAL;
    sum = 0;
  end

  assign o_wavelet = sum[(MAX_BITS - 1): (MAX_BITS) - SUM_TRUNCATION]; // top 8 bits, (e.g. 31: 24 (32 - 8 = 24) )

  always @(posedge clk) begin
    if (rst) begin
      // NOTE: parametric setting appears to require sv, so hardcoding with FILTER_VAL
      filter <= FILTER_VAL;
      sum <= 0;
    end else begin
      if (i_start_calc) begin
      // taps:9 tap_bits:72 max_bits:16 hex_value:f9dfc81f7f1fc8dff9
          sum <= $signed(filter[BITS_PER_ELEM*(0)+:BITS_PER_ELEM]) * $signed(taps[BITS_PER_ELEM*(0)+:BITS_PER_ELEM])
                        + $signed(filter[BITS_PER_ELEM*(1)+:BITS_PER_ELEM]) * $signed(taps[BITS_PER_ELEM*(1)+:BITS_PER_ELEM])
                        + $signed(filter[BITS_PER_ELEM*(2)+:BITS_PER_ELEM]) * $signed(taps[BITS_PER_ELEM*(2)+:BITS_PER_ELEM])
                        + $signed(filter[BITS_PER_ELEM*(3)+:BITS_PER_ELEM]) * $signed(taps[BITS_PER_ELEM*(3)+:BITS_PER_ELEM])
                        + $signed(filter[BITS_PER_ELEM*(4)+:BITS_PER_ELEM]) * $signed(taps[BITS_PER_ELEM*(4)+:BITS_PER_ELEM])
                        + $signed(filter[BITS_PER_ELEM*(5)+:BITS_PER_ELEM]) * $signed(taps[BITS_PER_ELEM*(5)+:BITS_PER_ELEM])
                        + $signed(filter[BITS_PER_ELEM*(6)+:BITS_PER_ELEM]) * $signed(taps[BITS_PER_ELEM*(6)+:BITS_PER_ELEM])
                        + $signed(filter[BITS_PER_ELEM*(7)+:BITS_PER_ELEM]) * $signed(taps[BITS_PER_ELEM*(7)+:BITS_PER_ELEM])
                        + $signed(filter[BITS_PER_ELEM*(8)+:BITS_PER_ELEM]) * $signed(taps[BITS_PER_ELEM*(8)+:BITS_PER_ELEM]);
        end else begin
          sum <= sum;
        end
      end
  end

  `ifdef FORMAL
    reg f_past_valid = 0;
    reg signed [31:0] overflow_test_sum = 0;
    reg signed [MAX_BITS - 1:0] truncated_overflow_test_sum = 0;

    initial assume(rst);

    always @(posedge clk) begin
      f_past_valid <= 1;
      if(f_past_valid) begin
        if (rst) begin
          overflow_test_sum <= 0;
          truncated_overflow_test_sum <= 0;
        end else begin
          if (i_start_calc) begin
            overflow_test_sum = 0;
            for (i = 0; i < NUM_ELEM; i = i + 1) begin
              overflow_test_sum = overflow_test_sum + $signed(filter[BITS_PER_ELEM*i+:BITS_PER_ELEM]) * $signed(taps[BITS_PER_ELEM*i+:BITS_PER_ELEM]);
            end
            truncated_overflow_test_sum <= overflow_test_sum[MAX_BITS - 1: 0];
          end
        end
        // test if the MAX_BITS value from the top module can result in overflow
        if(f_past_valid) begin
          if ($signed(overflow_test_sum) > 0) begin
            _overflow_test_pos: assert($signed(overflow_test_sum) <= {{(32 - MAX_BITS + 1){1'b0}},{(MAX_BITS - 1){1'b1}}});
          end
          if ($signed(overflow_test_sum) < 0) begin
            _overflow_test_neg: assert($signed(overflow_test_sum) >= {{(32 - MAX_BITS + 1){1'b1}},{(MAX_BITS - 1){1'b0}}});
          end
        end
      end
    end

  `endif
endmodule
