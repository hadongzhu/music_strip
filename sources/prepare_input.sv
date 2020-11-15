`timescale 1ns / 1ps


module prepare_input(
    input clk,
    input reset,
    input [15:0] in,
    output [15:0] out,
    
    input s_valid,
    output s_ready,
    output m_valid,
    input m_ready
    );
    
    logic [15:0] filt = 16'd17856;                      //预加重中高通滤波器alpha系数
    
    logic [9:0] q_out_counter;                          //输出为一半的计数器
    logic [9:0] d_out_counter;
    logic [7:0] q_stride_counter;                       //帧长度计数器
    logic [7:0] d_stride_counter;
    
    logic [31:0] product;
    logic [15:0] d_pre_emph;                            //预加重的结果
    logic [15:0] q_pre_emph;
    
    logic [15:0] frame[513];                            //储存结果的移位寄存器
    logic [15:0] frame_in;                              //输入的移位寄存器
    logic frame_en;                                     //寄存器移位使能
    logic frame_en_in;
    logic frame_en_out;
    
    logic q_valid;
    logic d_valid;
    logic started;                                     //开始标志
    
    assign frame_en = frame_en_in | frame_en_out;
    assign m_valid = q_valid & frame_en;
    assign out = m_valid ? frame[511] : 0;
    assign d_valid = (q_stride_counter==0 && m_ready && started);
    assign started = q_out_counter < 512;
    assign s_ready= !q_valid;
    
    assign product = $signed(filt)*$signed(in);
    assign d_pre_emph = product >> 15;
    
    always_comb begin
        frame_in = (q_valid) ? frame[511] : in - q_pre_emph;
        //  INPUT
        if(s_valid & s_ready) begin
            d_stride_counter = q_stride_counter + 1'd1;
            frame_en_in = 1'b1;
        end
        else begin
            d_stride_counter = q_stride_counter;
            frame_en_in = 1'b0;
        end
        
        // OUTPUT        
        if(q_stride_counter == 0) begin
            if(q_valid) begin
                d_out_counter = q_out_counter + started;
                frame_en_out = started;
            end
            else begin 
                d_out_counter = q_out_counter;
                frame_en_out = 0;
            end        
        end
        else begin
            d_out_counter = 0;
            frame_en_out = 0;
        end
                
        
    end
    
    always_ff @(posedge clk or posedge reset) begin
        if(reset) begin
            q_out_counter <= 512;
            q_stride_counter <= 256;
            q_valid <= 0;
            q_pre_emph <= 0;
            for(int i=0; i<513; i++) begin
                frame[i] <= 0;
            end
        end
        else begin
            q_out_counter <= d_out_counter;
            q_stride_counter <= d_stride_counter;
            q_valid <= d_valid;
            
            if(s_valid) q_pre_emph <= d_pre_emph;
            
            if(frame_en) begin
                frame[0] <= frame_in;
                frame[1:512] <= frame[0:511];
            end
        end
    end
    
endmodule