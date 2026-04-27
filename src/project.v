/*
 * Copyright (c) 2024 Jorge Gutierrez
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_directsgg_cpu8bit (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

  wire [7:0] input_data;

  wire rst, clear, dsp_ar, set_ar, r_mem, w_mem, run_cpu, start_cpu, stop_cpu;

  assign input_data = ui_in;
  assign clear = uio_in[0];
  assign dsp_ar = uio_in[1];
  assign set_ar = uio_in[2];
  assign r_mem = uio_in[3];
  assign w_mem = uio_in[4];
  assign start_cpu = uio_in[5];
  assign stop_cpu = uio_in[6];
  assign run_cpu = uio_out[7];
  assign rst = rst_n;

cpu my_cpu (
        .clk(clk),
        .rst(rst),
        .data_in(input_data),
        .clr_data_in(clear),
        .dsp_ar(dsp_ar),
        .set_ar(set_ar),
        .w_mem(w_mem),
        .r_mem(r_mem),
        .start_cpu(start_cpu),
        .stop_cpu(stop_cpu),
        .data_out(uo_out),
        .run_cpu(run_cpu)
    );

  // All output pins must be assigned. If not used, assign to 0.
  assign uio_out[0] = 0;
  assign uio_out[1] = 0;
  assign uio_out[2] = 0;
  assign uio_out[3] = 0;
  assign uio_out[4] = 0;
  assign uio_out[5] = 0;
  assign uio_out[6] = 0;
  assign uio_oe  = 8'b00000001;

  // List all unused inputs to prevent warnings
  wire _unused = &{ena, uio_in[7], 1'b0};

endmodule
