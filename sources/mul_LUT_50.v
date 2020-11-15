`timescale 1ns / 1ps

module mul_LUT_50(
    input   [7:0]       in,
    output  [7:0]       out
    );
    assign out = {1'b0, in[7:1]};

endmodule