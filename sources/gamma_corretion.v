`timescale 1ns / 1ps

module gamma_correction(
    input   [23:0]  in,
    output  [23:0]  out
    );

    gamma_correction_LUT  g_gamma_correction(
        .in     (in[23:16]),
        .out    (out[23:16])
        );

    gamma_correction_LUT  r_gamma_correction(
        .in     (in[15:8]),
        .out    (out[15:8])
        );

    gamma_correction_LUT  b_gamma_correction(
        .in     (in[7:0]),
        .out    (out[7:0])
        );
    
endmodule