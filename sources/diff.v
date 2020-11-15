`timescale 1ns / 1ps

module diff(
    input               clk,
    input               rst,
    input   [7:0]       in,
    input               write,
    input   [7:0]       addr,
    output  [7:0]       out
    );

    reg     [7:0]       bins        [39:0];
    reg     [7:0]       old_bins    [39:0];
    reg     [7:0]       _out;
    wire    [7:0]       old_bin;        

    assign old_bin  =   bins[addr];
    assign out      =   bins[addr];

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            bins[addr] <= 0;
        end
        else if (write == 1) begin
            if (old_bins[addr] > in) begin
                bins[addr] <= old_bins[addr] - in;
            end
            else begin
                bins[addr] <= in - old_bins[addr];
            end
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            old_bins[addr] <= 0;
        end
        else if (write == 1) begin
            old_bins[addr] <= in;
        end
    end

endmodule
