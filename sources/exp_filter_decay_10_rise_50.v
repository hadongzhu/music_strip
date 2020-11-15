`timescale 1ns / 1ps

module exp_filter_decay_10_rise_50(
    input               clk,
    input               rst,
    input   [7:0]       in,
    input               write,
    input   [7:0]       addr,
    output  [7:0]       out
    );

    reg     [7:0]       bins [39:0]  ;

    wire    [7:0]       out_decay_old;
    wire    [7:0]       out_decay_new;
    wire    [7:0]       out_rise_old;
    wire    [7:0]       out_rise_new;
    wire    [7:0]       old_bin;         

    assign old_bin  =   bins[addr];
    assign out      =   bins[addr];

    mul_LUT_90  mul_decay_old(
        .in     (old_bin),
        .out    (out_decay_old)
        );

    mul_LUT_10  mul_decay_new(
        .in     (in),
        .out    (out_decay_new)
        );

    mul_LUT_50  mul_rise_old(
        .in     (old_bin),
        .out    (out_rise_old)
        );

    mul_LUT_50  mul_rise_new(
        .in     (in),
        .out    (out_rise_new)
        );

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            bins[addr] <= 0;
        end
        else if (write == 1) begin
            if (bins[addr] > in) begin
                bins[addr] <= out_decay_old + out_decay_new;
            end
            else begin
                bins[addr] <= out_rise_old + out_rise_new;
            end
        end
    end

endmodule
