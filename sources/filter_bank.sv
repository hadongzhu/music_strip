`timescale 1ns / 1ps

module filter_bank(
    input           clk,
    input           reset,
    input   [31:0]  in,
    output  [15:0]  out[40],
    input           s_valid,
    output          s_ready,
    output          m_valid,
    input           m_ready
    );

    logic   [15:0]  filt_shift_reg[256] = {16'd32768, 16'd32768, 16'd32768, 16'd16384, 16'd32768, 16'd16384, 16'd32768, 16'd32768, 16'd16384, 16'd32768, 16'd16384, 16'd32768, 16'd16384, 16'd32768, 16'd16384, 16'd32768, 16'd10923, 16'd21845, 16'd32768, 16'd16384, 16'd32768, 16'd10923, 16'd21845, 16'd32768, 16'd10923, 16'd21845, 16'd32768, 16'd10923, 16'd21845, 16'd32768, 16'd8192, 16'd16384, 16'd24576, 16'd32768, 16'd10923, 16'd21845, 16'd32768, 16'd8192, 16'd16384, 16'd24576, 16'd32768, 16'd8192, 16'd16384, 16'd24576, 16'd32768, 16'd8192, 16'd16384, 16'd24576, 16'd32768, 16'd6554, 16'd13107, 16'd19661, 16'd26214, 16'd32768, 16'd6554, 16'd13107, 16'd19661, 16'd26214, 16'd32768, 16'd6554, 16'd13107, 16'd19661, 16'd26214, 16'd32768, 16'd5461, 16'd10923, 16'd16384, 16'd21845, 16'd27307, 16'd32768, 16'd5461, 16'd10923, 16'd16384, 16'd21845, 16'd27307, 16'd32768, 16'd4681, 16'd9362, 16'd14043, 16'd18725, 16'd23406, 16'd28087, 16'd32768, 16'd4681, 16'd9362, 16'd14043, 16'd18725, 16'd23406, 16'd28087, 16'd32768, 16'd4681, 16'd9362, 16'd14043, 16'd18725, 16'd23406, 16'd28087, 16'd32768, 16'd4096, 16'd8192, 16'd12288, 16'd16384, 16'd20480, 16'd24576, 16'd28672, 16'd32768, 16'd3641, 16'd7282, 16'd10923, 16'd14564, 16'd18204, 16'd21845, 16'd25486, 16'd29127, 16'd32768, 16'd3641, 16'd7282, 16'd10923, 16'd14564, 16'd18204, 16'd21845, 16'd25486, 16'd29127, 16'd32768, 16'd3641, 16'd7282, 16'd10923, 16'd14564, 16'd18204, 16'd21845, 16'd25486, 16'd29127, 16'd32768, 16'd2979, 16'd5958, 16'd8937, 16'd11916, 16'd14895, 16'd17873, 16'd20852, 16'd23831, 16'd26810, 16'd29789, 16'd32768, 16'd2979, 16'd5958, 16'd8937, 16'd11916, 16'd14895, 16'd17873, 16'd20852, 16'd23831, 16'd26810, 16'd29789, 16'd32768, 16'd2731, 16'd5461, 16'd8192, 16'd10923, 16'd13653, 16'd16384, 16'd19115, 16'd21845, 16'd24576, 16'd27307, 16'd30037, 16'd32768, 16'd2731, 16'd5461, 16'd8192, 16'd10923, 16'd13653, 16'd16384, 16'd19115, 16'd21845, 16'd24576, 16'd27307, 16'd30037, 16'd32768, 16'd2341, 16'd4681, 16'd7022, 16'd9362, 16'd11703, 16'd14043, 16'd16384, 16'd18725, 16'd21065, 16'd23406, 16'd25746, 16'd28087, 16'd30427, 16'd32768, 16'd2341, 16'd4681, 16'd7022, 16'd9362, 16'd11703, 16'd14043, 16'd16384, 16'd18725, 16'd21065, 16'd23406, 16'd25746, 16'd28087, 16'd30427, 16'd32768, 16'd2048, 16'd4096, 16'd6144, 16'd8192, 16'd10240, 16'd12288, 16'd14336, 16'd16384, 16'd18432, 16'd20480, 16'd22528, 16'd24576, 16'd26624, 16'd28672, 16'd30720, 16'd32768, 16'd2048, 16'd4096, 16'd6144, 16'd8192, 16'd10240, 16'd12288, 16'd14336, 16'd16384, 16'd18432, 16'd20480, 16'd22528, 16'd24576, 16'd26624, 16'd28672, 16'd30720, 16'd32768, 16'd1820, 16'd3641, 16'd5461, 16'd7282, 16'd9102, 16'd10923, 16'd12743, 16'd14564, 16'd16384, 16'd18204, 16'd20025, 16'd21845, 16'd23666, 16'd25486, 16'd27307, 16'd29127, 16'd30948, 16'd32768};
    logic   [15:0]  filt;                       //滤波器系数
    logic           new_window[3];              //开始, 中心频率, 结束标志
    logic   [15:0]  bank_shift_reg[40];         //移位寄存器, 用于储存结果
    logic   [5:0]   d_counter;
    logic   [5:0]   q_counter;                  //输出计数器
    logic           in_ready;
    logic           in_valid[3];
    logic   [31:0]  q_in;                       //输入的延迟
    logic   [31:0]  product[2];                 //与滤波器相乘的系数
    logic   [31:0]  inverse[2];                 // in - scaled_product
    logic   [31:0]  q_ascending;
    logic   [31:0]  d_ascending;
    logic   [31:0]  q_descending;
    logic   [31:0]  d_descending;               //上升边与下降边
    logic   [31:0]  accumulation;               //储存加法结果
    
    assign s_ready = in_ready;
    assign in_valid[0] = s_valid;
    assign filt = filt_shift_reg[0];
    assign new_window[0] = (filt == 16'd32768);
    
//    assign product = in * filt;
    assign inverse[0] = q_in - product[0];
    assign accumulation = q_ascending + product[1];
    
    assign out = bank_shift_reg;
    assign m_valid = (q_counter == 41);
    
    mult_gen_1 mult_im (
      .CLK(clk),  // input wire CLK
      .A(in),      // input wire [31 : 0] A
      .B(filt),      // input wire [15 : 0] B
      .P(product[0])      // output wire [63 : 0] P
    );
    
    always_comb begin        
        if(in_valid[2] && s_ready) begin
            if(new_window[2]) begin
               d_ascending = 0;
                d_descending = accumulation;
                d_counter = q_counter + 1;
            end
            else begin
                d_ascending = accumulation;
                d_descending = q_descending + inverse[1];
                d_counter = q_counter;
            end
        end
        else begin
            d_ascending = q_ascending;
            d_descending = q_descending;
            if(m_valid & m_ready) begin
                d_counter = 0;                
            end
            else begin
                d_counter = q_counter;
            end
        end
    end
    
    always_ff @(posedge clk or posedge reset) begin
        if(reset) begin
            in_ready <= 0;
            q_in <= 0;
            new_window[1:2] <= {0,0};
            in_valid[1:2] <= {0,0};
            product[1] <= 0;
            inverse[1] <= 0;
            q_counter <= 0;
            q_ascending <= 0;
            q_descending <= 0;
            
        end
        else begin
            in_ready <= 1'b1;
            q_in <= in;
            new_window[1:2] <= new_window[0:1];
            in_valid[1:2] <= in_valid[0:1];
            product[1] <= product[0];
            inverse[1] <= inverse[0];
            q_counter <= d_counter;
            q_ascending <= d_ascending;
            q_descending <= d_descending;
        
            if(s_valid & s_ready) begin
                filt_shift_reg[255] <= filt_shift_reg[0];
                filt_shift_reg[0:254] <= filt_shift_reg[1:255];
            end
            
            if(new_window[2] & in_valid[2]) begin
                bank_shift_reg[39] <= q_descending[31:16];
                bank_shift_reg[0:38] <= bank_shift_reg[1:39];
            end
            
        end
    end
endmodule

