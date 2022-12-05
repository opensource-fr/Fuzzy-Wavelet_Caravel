`default_nettype none `timescale 1ns / 1ns

module rolling_sum #(
    parameter BITS_PER_ELEM = 8,
    parameter NUM_ELEM = 4, // start with 4 increase by powers of two, 4, 8, 16...
    parameter MAX_BITS = $clog2(4 * 255)  // should be calculated on top
) (
    input wire clk,
    input wire rst,
    input wire [BITS_PER_ELEM - 1:0] i_new,  // 7:0
    input wire [BITS_PER_ELEM*NUM_ELEM - 1:BITS_PER_ELEM*(NUM_ELEM - 1)] i_old,  //15:0
    input wire i_start_calc,
    output wire o_shift_in_rdy, // signal rdy to shift into srl_ra
    output wire [BITS_PER_ELEM - 1:0] o_rs
);

  // output goes into ma shift register
  /* reg [$clog2(NUM_ELEM) - 1:0] counter; */
  reg [MAX_BITS - 1:0] r_sum;  // rolling sum
  reg ready_to_shift_in; // 0 if not ready, 1 if ready

  initial begin
    r_sum = 0;
    ready_to_shift_in = 0;
  end

  assign o_rs = r_sum[(MAX_BITS-1):(MAX_BITS-BITS_PER_ELEM)];

  // Assume that i_new and i_old are between [0,255] but represent numbers
  // from -128 -> 127. In other words, that the input is shifted up by 128.
  // This simplifies the rolling sum logic.
  always @(posedge clk) begin
    if (rst) begin
      r_sum <= 0;
      ready_to_shift_in <= 0;
    end else begin
      // if new value then update rs
      if (i_start_calc) begin
        r_sum <= (r_sum + {{(MAX_BITS - BITS_PER_ELEM){1'b0}},i_new}) - {{(MAX_BITS - BITS_PER_ELEM){1'b0}},i_old}; // TODO: ensure the addition is done before subtraction in seqeunce (to ensure always positive)
        ready_to_shift_in <= 1;
      end else begin
        r_sum <= r_sum;
        ready_to_shift_in <= 0;
      end
    end
  end

  assign o_shift_in_rdy = ready_to_shift_in;

endmodule
