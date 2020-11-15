`timescale 1ns / 1ps
//  T   :   1.25us
//  T0H :   0.22us~0.42us
//  T1H :   0.75us~1.6us


module RZ_bit(
    input           clk,
    input           rst_n,

    input           in,
    output          out,

    input           s_valid,
    output          s_ready

);

    reg     [7:0]   cnt;                //计数一个码元周期
    reg             s_ready_reg;        //1bit数据结束标志
    reg             in_reg;             //需要转换的RGB数据
    reg             out_reg;            //转换后的单极性归零码
    reg             status;             //转换状态

    assign  s_ready = s_ready_reg;
    assign  out     = out_reg;

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)  begin
            cnt <= 0;
        end
        else if(cnt == 8'd124 && s_valid == 0)    begin
            cnt <= cnt;
        end
        else if(cnt == 8'd124)  begin       //计数一个码元周期(125 = 1.25us * 100MHz)
            cnt <= 8'd0;
        end
        else    begin
            cnt <= cnt + 1'b1;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)  begin
            status <= 0;
        end
        else if(cnt == 8'd124 && s_valid == 0)    begin
            status <= 0;
        end
        else if(s_valid == 1 && s_ready_reg == 1)   begin       //计数一个码元周期(125 = 1.25us * 100MHz)
            status <= 1;
        end
        else    begin
            status <= status;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)  begin
            s_ready_reg <= 0;
        end
        else if(cnt == 8'd123)  begin       //码元周期结束
            s_ready_reg <= 1;
        end
        else if(s_valid == 1) begin
            s_ready_reg <= 0;
        end
        else    begin
            s_ready_reg <= s_ready_reg;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n || (cnt == 8'd124 && s_valid == 0)) begin
            in_reg <= 0;
        end
        else if(cnt == 8'd124 && s_valid == 1)    begin
            in_reg <= in;
        end
        else    begin
            in_reg <= in_reg;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)  begin
            out_reg <= 0;
        end
        else if((in_reg == 0) && (status == 1)) begin
            if(cnt <= 8'd30)    begin       //零码高电平(30 = 0.3us * 100MHz)
                out_reg <= 1;
            end
            else    begin
                out_reg <= 0;
            end
        end
        else if((in_reg == 1) && (status == 1)) begin
            if(cnt <= 8'd90)    begin       //一码高电平(90 = 0.9us * 100MHz)
                out_reg <= 1;
            end
            else    begin
                out_reg <= 0;
            end
        end
        else    begin
            out_reg <= out_reg;
        end
    end

endmodule
