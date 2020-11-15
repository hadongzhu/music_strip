`timescale 1ns / 1ps

module mic_ADC(
    input           clk,
    input           rst,
    output  [11:0]  out,
    output          eoc,
    input           vauxp,
    input           vauxn
    );

    wire            analog_pos_in;
    wire            analog_neg_in;
    wire    [15:0]  do_out;
    wire    [4:0]   channel_out;
    wire            eoc_out;
    reg             cnt;
    reg             eoc_sync;
    assign analog_pos_in = vauxp;
    assign analog_neg_in = vauxn;
    assign out           = do_out[15:4];
    assign eoc           = eoc_sync;

    always @(posedge clk or negedge rst) begin
        if(rst) begin
            eoc_sync <= 1'd0;
        end 
        else if (eoc_out == 1'd1 && cnt == 1'd1) begin
                eoc_sync <= 1'd1;
        end
        else begin
                eoc_sync <= 1'd0;
        end
    end

    always @(posedge clk or negedge rst) begin
            if(rst) begin
                cnt <= 1'd0;
            end 
            else if (eoc_out == 1) begin
                    cnt <= ~cnt;
            end
    end

    xadc_wiz_0 adc (
        .di_in(16'd0),              // input wire [15 : 0] di_in
        .daddr_in({2'd0, channel_out}),        // input wire [6 : 0] daddr_in
        .den_in(eoc_out),            // input wire den_in
        .dwe_in(1'b0),            // input wire dwe_in
        //.drdy_out(drdy_out),        // output wire drdy_out
        .do_out(do_out),            // output wire [15 : 0] do_out
        .dclk_in(clk),          // input wire dclk_in
        .reset_in(rst),        // input wire reset_in

        .vauxp0(analog_pos_in),            // note since vauxn5, channel 5, is used  .daddr_in(ADC_ADDRESS), ADC_ADRESS = 15h, i.e., 010101 
        .vauxn0(analog_neg_in),            // note since vauxn5, channel 5, is used  .daddr_in(ADC_ADDRESS), ADC_ADRESS = 15h, i.e., 010101     
     
        .channel_out(channel_out),  // output wire [4 : 0] channel_out
        .eoc_out(eoc_out)          // output wire eoc_out
        //.alarm_out(led[0]),      // output wire alarm_out
     
        //.busy_out(led[2])        // output wire busy_out
    );
endmodule