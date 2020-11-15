`timescale 1ns / 1ps
module top(
    input               clk,        //时钟信号100MHz
    input               rst_n,      //异步复位信号(低电平有效)
    input               vauxp,      //辅助差分输入(vauxp0)
    input               vauxn,      //辅助差分输入(vauxp1)
    output              RZ_data     //单极性归零码输出
);
    wire    [11:0]      adc_out;
    wire                eoc;

    wire    [15:0]      reshape_out [0:0];
    wire                reshape_valid;
    wire                reshape_last;

    wire                visualization_valid;
    wire                visualization_ready;

    wire    [23:0]      GRB_raw;
    wire    [23:0]      GRB;

    wire                frame_valid;
    wire                frame_ready;

    wire                RZ_bit_ready;
    wire                RZ_bit;

    wire                rst;

    reg     [15:0]      q_hamming_input;
    wire    [15:0]      d_hamming_input;
    reg     [15:0]      q_power_spec_input;
    wire    [15:0]      d_power_spec_input;
    wire    [31:0]      d_filter_bank_input;
    reg     [31:0]      q_filter_bank_input;
    wire    [15:0]      filter_bank_output  [40];
    
    wire                pow_spec_ready;
    reg                 q_frame_valid;
    reg                 qq_frame_valid;
    wire                d_frame_valid;
    wire                filt_bank_ready;
    wire                d_pow_spec_valid;
    reg                 q_pow_spec_valid;
    wire                reshape_ready;
    wire                filt_bank_valid;

    assign rst = ~rst_n;                //异步复位信号(高电平有效)

    //FPGA内置ADC
    mic_ADC mic_ADC(    
        .clk            (clk),
        .rst            (rst),

        .out            (adc_out),

        .eoc            (eoc),

        .vauxp          (vauxp),
        .vauxn          (vauxn)
    );
    
    //准备输入
    prepare_input prepare_input(
        .clk            (clk),
        .reset          (rst),

        .in             (adc_out),
        .out            (d_hamming_input),

        .s_valid        (eoc),

        .m_ready        (pow_spec_ready),
        .m_valid        (d_frame_valid)
        );
    
    //汉明窗
    hamming hamming(
        .clk            (clk),
        .reset          (rst),

        .in             (q_hamming_input),
        .out            (d_power_spec_input),

        .on             (q_frame_valid & pow_spec_ready)
        );
    
    //功率谱                           
    power_spectrum power_spectrum(
        .clk            (clk),
        .reset          (rst),

        .in             (q_power_spec_input),
        .out            (d_filter_bank_input),

        .s_ready        (pow_spec_ready),
        .s_valid        (qq_frame_valid),

        .m_ready        (filt_bank_ready),
        .m_valid        (d_pow_spec_valid)
        );
    
    //Mel滤波器                                            
    filter_bank filter_bank(
        .clk            (clk),
        .reset          (rst),

        .in             (q_filter_bank_input),
        .out            (filter_bank_output),

        .s_ready        (filt_bank_ready),
        .s_valid        (q_pow_spec_valid),

        .m_ready        (reshape_ready),
        .m_valid        (filt_bank_valid)
        );
    
    //整形输出
    reshape_output reshape_output(
        .clk            (clk),
        .reset          (rst),

        .in             (filter_bank_output),
        .out            (reshape_out),

        .s_ready        (reshape_ready),
        .s_valid        (filt_bank_valid),

        .m_ready        (visualization_ready),
        .m_valid        (reshape_valid),
        .m_last         (reshape_last)
        );

    //可视化
    visualization visualization(
        .clk            (clk),
        .rst            (rst),

        .in             (reshape_out[0][13:6]),
        .out            (GRB_raw),

        .s_last         (reshape_last),
        .s_ready        (visualization_ready),
        .s_valid        (reshape_valid),

        .m_ready        (frame_ready),
        .m_valid        (visualization_valid) 
        
    );

    //gamma校正
    gamma_correction gamma_correction(
        .in             (GRB_raw),
        .out            (GRB)
    );

    //帧发送
    RZ_frame RZ_frame_inst(
        .clk            (clk),
        .rst_n          (rst_n),

        .in             (GRB),
        .out            (RZ_bit),

        .s_valid        (visualization_valid),
        .s_ready        (frame_ready),  

        .m_valid        (frame_valid),
        .m_ready        (RZ_bit_ready)
                        
                        
    );

    //字节发送
    RZ_bit  RZ_bit_inst(
        .clk            (clk),
        .rst_n          (rst_n),

        .in             (RZ_bit),
        .out            (RZ_data),

        .s_valid        (frame_valid),   
        .s_ready        (RZ_bit_ready)

    );

    always @(posedge clk) begin
            begin
                    if(filt_bank_ready) begin
                            q_filter_bank_input <= d_filter_bank_input;
                            q_pow_spec_valid <= d_pow_spec_valid;
                    end
                    if(pow_spec_ready) begin
                            q_power_spec_input <= d_power_spec_input;
                            q_hamming_input <= d_hamming_input;
                    end
                    q_frame_valid <= d_frame_valid;
                    qq_frame_valid <= q_frame_valid;
            end
    end

endmodule