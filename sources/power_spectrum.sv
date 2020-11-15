`timescale 1ns / 1ps

module power_spectrum(
    input clk,
    input reset,
    input [15:0] in,
    output [31:0] out,
    
    output s_ready,
    input s_valid,
    input s_last,
    
    input m_ready,
    output m_valid
    );


    // fft 信号
    logic [15:0]i_re;                   // 实部输入
    logic [15:0]i_im;                   // 虚部输入
    logic [31:0]o_re;                   // 实部输出
    logic [31:0]o_im;                   // 虚部输出
    logic q_stop_fft = 1'b0;            // 停止输出对称fft输出的信号
    logic d_stop_fft = 1'b0;
    logic fft_reset = 1'b1;
    logic fft_out_valid;
    logic d_valid;
    logic [6:0] q_valid;
    
    logic [63:0] re_squared;
    logic [63:0] im_squared;
    logic [63:0] sum_squared;           // 幅值平方和
    logic [63:0] pow_spec;
    
    logic [8:0] q_cnt = 0;              // 帧长度计数,达到一时复位
    logic [8:0] d_cnt = 0;
    
    assign i_re = in;
    assign i_im = 16'h0000;
    assign sum_squared = re_squared + im_squared;
    assign pow_spec = sum_squared>>9;  
    
    assign out = pow_spec[31:0];
    
    assign m_valid = q_valid[0];
    
    
    mult_gen_0 mult_re (
      .CLK(clk),  // input wire CLK
      .A(o_re),      // input wire [31 : 0] A
      .B(o_re),      // input wire [31 : 0] B
      .P(re_squared)      // output wire [63 : 0] P
    );
    
    mult_gen_0 mult_im (
      .CLK(clk),  // input wire CLK
      .A(o_im),      // input wire [31 : 0] A
      .B(o_im),      // input wire [31 : 0] B
      .P(im_squared)      // output wire [63 : 0] P
    );

    xfft_512 my_fft (.aclk(clk),
                     .aresetn(fft_reset & !reset),
                     .s_axis_config_tvalid(1'b0),
                     .s_axis_config_tdata(8'd0),
                     .s_axis_data_tdata({i_re, i_im}),
                     .s_axis_data_tvalid(s_valid),
                     .s_axis_data_tready(s_ready),
                     .s_axis_data_tlast(s_last),
                     .m_axis_data_tdata({o_re, o_im}),
                     .m_axis_data_tvalid(fft_out_valid),
                     .m_axis_data_tready(m_ready)
//                     .m_axis_data_tlast(m_last)
                     );

    always_comb begin
        if(q_stop_fft) begin
            fft_reset = 1'b0;
            d_valid = 1'b0;
            d_cnt = 0;
            d_stop_fft = 1'b0;
        end else begin
            if(q_cnt[8]) begin
                d_valid = 1'b0;
                d_cnt = 0;
                d_stop_fft = 1'b1;
                fft_reset = 1'b0;
            end
            else begin
                d_valid = fft_out_valid;
                d_stop_fft = 1'b0; 
                fft_reset = 1'b1;           
                if (m_ready & fft_out_valid)
                    d_cnt = q_cnt + 1'b1;
                else
                    d_cnt = q_cnt;
            end
        end
    end
    
    always_ff @(posedge clk) begin
        q_cnt <= d_cnt;
        q_stop_fft <= d_stop_fft;
        q_valid[6] <= d_valid;
        
        for (int i=0; i<6; i++)
            q_valid[i] <= q_valid[i+1];
    end
endmodule

