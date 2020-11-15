`timescale 1ns / 1ps
//  RESET   :300us
//  T   :   1.25us
//  T0H :   0.22us~0.42us
//  T1H :   0.75us~1.6us
module RZ_frame(
    input               clk,
    input               rst_n,
    input   [23:0]      in,

    output              out,

    input               s_valid,
    output              s_ready,

    output              m_valid,
    input               m_ready

);


    reg     [31:0]      cnt;                //RESET计数
    reg     [23:0]      in_reg;             //存RGB数据的数组
    reg     [4:0]       k;                  //发送顺序地址
    reg                 s_ready_reg;
    reg                 m_valid_reg;
    reg                 out_reg;
    reg                 reset_status;       //复位状态
    reg                 read_status;        //读状态
    reg                 s_ready_down;

    assign m_valid  = m_valid_reg;
    assign s_ready  = s_ready_reg && (k == 5'd23) && m_ready && s_ready_down;

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)  begin
            m_valid_reg <= 0;
        end
        else if(k == 5'd23 && s_valid == 0 || s_ready_reg == 0) begin
            m_valid_reg <= 0;
        end
        else if(read_status == 1)begin
            m_valid_reg <= 1;
        end
        else begin
            m_valid_reg <= m_valid_reg;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)  begin
            in_reg <= 0;
        end
        else if(k == 5'd23 && s_valid == 1 && s_ready_reg == 1) begin
            in_reg <= in;
        end
        else begin
            in_reg <= in_reg;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            read_status <= 0;
        end
        else if(k == 5'd23 && s_valid == 1 && s_ready_reg == 1) begin
            read_status <= 1;
        end
        else if(k == 5'd23 && s_valid == 0) begin
            read_status <= 0;
        end
        else    begin
            read_status <= read_status;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)  begin
            k <= 23;
            out_reg <= 0;
        end
        else if(k == 5'd23 && (s_valid == 0 || s_ready_reg == 0))  begin  
              k <= 23;
              out_reg <= 0;
        end
        else if(k == 5'd23 && s_valid == 1 && s_ready_reg == 1 && m_valid == 0)  begin  
              k <= 23;
              out_reg <= in_reg[23];
        end
        else if(m_ready == 1 && m_valid == 1)   begin
            if(k == 5'd23)  begin
                k <= 0;
                out_reg <= in_reg[22];
            end
            else if(k == 22) begin
                k <= k + 1;
                out_reg <= in_reg[23];
            end
            else begin
                k <= k + 1;
                out_reg <= in_reg[21 - k];
            end
        end
        else begin
            k <= k;
            out_reg <= out;
        end
    end

    assign out = out_reg;

    always @(posedge clk or negedge rst_n) begin
        if(s_ready_reg == 1) begin
            cnt <= 32'd29999;
        end
        else if(cnt != 32'd29999)   begin
            cnt <= cnt + 1;
        end
        else if((!rst_n) || (k == 5'd23 && s_valid == 0 && m_ready == 1))   begin
            cnt <= 0;
        end
        else    begin
            cnt <= 32'd29999;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)  begin
            reset_status <= 0;
        end
        else if(s_ready_reg == 1 && s_valid == 1) begin
            reset_status <= 0;
        end
        else if(k == 5'd23 && s_valid == 0 && m_ready == 1) begin
            reset_status <= 1;
        end
        else    begin
            reset_status <= reset_status;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)  begin
            s_ready_reg <= 0;
        end
        else if(cnt == 32'd29998)   begin
            s_ready_reg <= 1;            //重新开始发送
        end
        else if((k == 5'd23) && (s_valid == 0) && reset_status == 0)    begin
            s_ready_reg <= 0;           //一组数据发送结束，RESTE
        end
        else    begin
            s_ready_reg <= s_ready_reg;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            s_ready_down <= 1;// reset
        end
        else if (s_valid == 1 && m_ready == 1 && s_ready_reg) begin
            s_ready_down <= 0;
        end
        else begin
            s_ready_down <= 1;
        end
    end
endmodule