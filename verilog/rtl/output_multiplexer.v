`default_nettype none
`timescale 1ns/1ns

module output_multiplexer #(
    parameter NUM_FIRS = 8,
    parameter SUM_TRUNCATION = 8
) (
    // Clock
    input wire clk,

    // Reset
    input wire rst,

    // truncated outputs from wavelets
    input wire [(NUM_FIRS*SUM_TRUNCATION - 1):0] i_truncated_wavelet_out,

    // selection of output channels, hardcoded to 8 for now
    input wire [7:0] i_select_output_channel,

    // multiplexed output
    output wire [SUM_TRUNCATION - 1:0] o_multiplexed_wavelet_out

);

  reg [7:0] multiplexer_out;

  assign o_multiplexed_wavelet_out = multiplexer_out;

  initial begin
    multiplexer_out = 8'b0;
  end

  always @(posedge clk) begin
    if (rst) begin
      multiplexer_out <= 8'b0;
    end else begin
        case (i_select_output_channel) //TODO we manually create the multplexer number of outs
          8'd1: multiplexer_out <= i_truncated_wavelet_out[0*(SUM_TRUNCATION) +:SUM_TRUNCATION];
          8'd2: multiplexer_out <= i_truncated_wavelet_out[1*(SUM_TRUNCATION) +:SUM_TRUNCATION];
          8'd3: multiplexer_out <= i_truncated_wavelet_out[2*(SUM_TRUNCATION) +:SUM_TRUNCATION];
          8'd4: multiplexer_out <= i_truncated_wavelet_out[3*(SUM_TRUNCATION) +:SUM_TRUNCATION];
          8'd5: multiplexer_out <= i_truncated_wavelet_out[4*(SUM_TRUNCATION) +:SUM_TRUNCATION];
          8'd6: multiplexer_out <= i_truncated_wavelet_out[5*(SUM_TRUNCATION) +:SUM_TRUNCATION];
          8'd7: multiplexer_out <= i_truncated_wavelet_out[6*(SUM_TRUNCATION) +:SUM_TRUNCATION];
          8'd8: multiplexer_out <= i_truncated_wavelet_out[7*(SUM_TRUNCATION) +:SUM_TRUNCATION];
          8'd9: multiplexer_out <= i_truncated_wavelet_out[8*(SUM_TRUNCATION) +:SUM_TRUNCATION];
          8'd10: multiplexer_out <= i_truncated_wavelet_out[9*(SUM_TRUNCATION) +:SUM_TRUNCATION];
          8'd11: multiplexer_out <= i_truncated_wavelet_out[10*(SUM_TRUNCATION) +:SUM_TRUNCATION];
          8'd12: multiplexer_out <= i_truncated_wavelet_out[11*(SUM_TRUNCATION) +:SUM_TRUNCATION];
          8'd13: multiplexer_out <= i_truncated_wavelet_out[12*(SUM_TRUNCATION) +:SUM_TRUNCATION];
          8'd14: multiplexer_out <= i_truncated_wavelet_out[13*(SUM_TRUNCATION) +:SUM_TRUNCATION];
          8'd15: multiplexer_out <= i_truncated_wavelet_out[14*(SUM_TRUNCATION) +:SUM_TRUNCATION];
          8'd16: multiplexer_out <= i_truncated_wavelet_out[15*(SUM_TRUNCATION) +:SUM_TRUNCATION];
          /* 8'd17: multiplexer_out <= i_truncated_wavelet_out[16*(SUM_TRUNCATION) +:SUM_TRUNCATION]; */
          /* 8'd18: multiplexer_out <= i_truncated_wavelet_out[17*(SUM_TRUNCATION) +:SUM_TRUNCATION]; */
          /* 8'd19: multiplexer_out <= i_truncated_wavelet_out[18*(SUM_TRUNCATION) +:SUM_TRUNCATION]; */
          /* 8'd20: multiplexer_out <= i_truncated_wavelet_out[19*(SUM_TRUNCATION) +:SUM_TRUNCATION]; */
          /* 8'd21: multiplexer_out <= i_truncated_wavelet_out[20*(SUM_TRUNCATION) +:SUM_TRUNCATION]; */
          /* 8'd22: multiplexer_out <= i_truncated_wavelet_out[21*(SUM_TRUNCATION) +:SUM_TRUNCATION]; */
          /* 8'd23: multiplexer_out <= i_truncated_wavelet_out[22*(SUM_TRUNCATION) +:SUM_TRUNCATION]; */
          /* 8'd24: multiplexer_out <= i_truncated_wavelet_out[23*(SUM_TRUNCATION) +:SUM_TRUNCATION]; */
          /* 8'd25: multiplexer_out <= i_truncated_wavelet_out[24*(SUM_TRUNCATION) +:SUM_TRUNCATION]; */
          /* 8'd26: multiplexer_out <= i_truncated_wavelet_out[25*(SUM_TRUNCATION) +:SUM_TRUNCATION]; */
          /* 8'd27: multiplexer_out <= i_truncated_wavelet_out[26*(SUM_TRUNCATION) +:SUM_TRUNCATION]; */
          /* 8'd28: multiplexer_out <= i_truncated_wavelet_out[27*(SUM_TRUNCATION) +:SUM_TRUNCATION]; */
          /* 8'd29: multiplexer_out <= i_truncated_wavelet_out[28*(SUM_TRUNCATION) +:SUM_TRUNCATION]; */
          /* 8'd30: multiplexer_out <= i_truncated_wavelet_out[29*(SUM_TRUNCATION) +:SUM_TRUNCATION]; */
          default: multiplexer_out <= i_truncated_wavelet_out[0+:SUM_TRUNCATION];
        endcase
    end
  end


endmodule
