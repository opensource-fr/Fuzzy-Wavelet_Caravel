`default_nettype none
`timescale 1ns/1ns

module srl_rolling_avg #(
    parameter BITS_PER_ELEM = 8,
    parameter TOTAL_BITS = 9 * 8
) (
    // Clock
    input wire clk,

    // Reset
    input wire rst,

    // Inputs Streaming
    input wire signed [BITS_PER_ELEM - 1:0] i_value,

    // clock in the data, if high clock in, feed in from rolling avg
    input wire i_data_clk,

    // signal to fir's, data is ready to start calculation
    output wire o_start_calc,

    // TAPS
    output reg [TOTAL_BITS - 1:0] o_taps
);

  reg start_calc;

  initial begin
    o_taps = 0;
    start_calc = 0;
  end


  always @(posedge clk) begin
    if (rst) begin
      o_taps <= 0;
      start_calc <= 0;
    end else begin
      o_taps <= o_taps;
      start_calc <= 0;
      if (i_data_clk) begin //rising clk with one redundant reg to fix metastability
        start_calc <= 1;
        if (i_value[7]) begin // if i_value positive (within range of 128 to 255 inclusive, equiv to removing 7 bit
          o_taps <= {o_taps[((TOTAL_BITS-1)-BITS_PER_ELEM):0], (i_value[7:0] & 8'b0111_1111)};
        end else begin // if i_value negative, then 127 is -1, or 0b11111111 which is 128 more, but is equiv to adding 7th bit (zero index)
          o_taps <= {o_taps[((TOTAL_BITS-1)-BITS_PER_ELEM):0], (i_value[7:0] | 8'b1000_0000)};
        end
      end
    end
  end

  assign o_start_calc = start_calc;

endmodule
