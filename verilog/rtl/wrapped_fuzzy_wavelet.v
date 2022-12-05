
// SPDX-FileCopyrightText: 2020 Efabless Corporation
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// SPDX-License-Identifier: Apache-2.0

`default_nettype none
/*
 *-------------------------------------------------------------
 *
 * user_project_wrapper
 *
 * This wrapper enumerates all of the pins available to the
 * user for the user project.
 *
 * An example user project is provided in this wrapper.  The
 * example should be removed and replaced with the actual
 * user project.
 *
 *-------------------------------------------------------------
 */

module wrapped_fuzzy_wavelet (

  `ifdef USE_POWER_PINS
    inout vdd,
    inout vss,
  `endif

    // interface as user_proj_example
    input wire wb_clk_i,
    input wire wb_rst_i,

    // IO Pads
    input wire [`MPRJ_IO_PADS-1:0] io_in,
    output wire [`MPRJ_IO_PADS-1:0] io_out,
    output wire [`MPRJ_IO_PADS-1:0] io_oeb,

);

assign io_oeb = {`MPRJ_IO_PADS{1'b0}};

fuzzy_wavelet fzzy_wvlt (
    `ifdef USE_POWER_PINS
      .vdd(vdd),// User area 1 1.8V power
      .vss(vss),// User area 1 digital ground
    `endif
    .clk(wb_clk_i),
    .rst(wb_rst_i),

    // NOTE: Can only have so many pins, avoid io's 0-7
    .i_data_clk(io_in[8]),
    .i_value(io_in[16:9]),
    .i_select_output_channel(io_in[24:17]),
    .o_multiplexed_wavelet_out(io_out[32:25]),
    .o_active(io_out[33]),
);


endmodule	// user_project_wrapper

`default_nettype wire
