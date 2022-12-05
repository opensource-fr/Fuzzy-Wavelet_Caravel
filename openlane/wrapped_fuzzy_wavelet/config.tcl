# SPDX-FileCopyrightText: 2020 Efabless Corporation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# SPDX-License-Identifier: Apache-2.0

set ::env(PDK) "gf180mcuC"
set ::env(STD_CELL_LIBRARY) "gf180mcu_fd_sc_mcu7t5v0"

set ::env(DESIGN_NAME) user_proj_example

set ::env(VERILOG_FILES) "\
	$::env(CARAVEL_ROOT)/verilog/rtl/defines.v \
	$::env(DESIGN_DIR)/../../verilog/rtl/user_proj_example.v \
	$::env(DESIGN_DIR)/../../verilog/rtl/fir.v \
	$::env(DESIGN_DIR)/../../verilog/rtl/rolling_sum.v \
	$::env(DESIGN_DIR)/../../verilog/rtl/shift_register_line.v \
	$::env(DESIGN_DIR)/../../verilog/rtl/srl_rolling_avg.v \
	$::env(DESIGN_DIR)/../../verilog/rtl/wrapped_fuzzy_wavelet.v \
	$::env(DESIGN_DIR)/../../verilog/rtl/output_multiplexer.v \
	$::env(DESIGN_DIR)/../../verilog/rtl/fuzzy_wavelet.v"

# set absolute size of the die to 300 x 300 um
set ::env(DIE_AREA) "0 0 600 600"
set ::env(FP_SIZING) absolute

set ::env(FP_CORE_UTIL) 40
set ::env(PL_TARGET_DENSITY) [ expr ($::env(FP_CORE_UTIL)+5) / 100.0 ]

# define number of IO pads
set ::env(SYNTH_DEFINES) "MPRJ_IO_PADS=38"

# clock period is ns
# need 40MHz for VGA out = 25ns
set ::env(CLOCK_PERIOD) "30"
set ::env(CLOCK_PORT) "wb_clk_i"

# macro needs to work inside Caravel, so can't be core and can't use metal 5
set ::env(DESIGN_IS_CORE) 0
set ::env(RT_MAX_LAYER) {Metal4}

# define power straps so the macro works inside Caravel's PDN
set ::env(VDD_NETS) [list {vdd}]
set ::env(GND_NETS) [list {vss}]

# regular pin order seems to help with aggregating all the macros for the group project
#set ::env(FP_PIN_ORDER_CFG) $script_dir/pin_order.cfg

set ::env(FP_IO_VTHICKNESS_MULT) 4
set ::env(FP_IO_HTHICKNESS_MULT) 4
