`timescale 1ns / 1ps

module visualization(
    input               clk,
    input               rst,
    input   [7:0]       in,
    output  [23:0]      out,

    input               s_valid,
    input               s_last,
    output              s_ready,

    input               m_ready,
    output              m_valid
    );

    reg                 write_delay;                //延迟的读写控制信号, 用于第二级滤波器
    reg     [7:0]       addr;                       //地址总线
    reg     [7:0]       addr_delay;                 //延迟的地址总线, 用于第二级滤波器
    reg     [7:0]       addr_r;                     //
    reg     [7:0]       in_delay;                   //延迟的输入, 用于第二级滤波器
    reg                 _s_ready;
    reg                 _m_valid;
    reg                 rst_status;
    reg                 direction;                  //输出方向

    reg     [7:0]       r_diff;                     //红色滤波器与共模滤波器之差
    wire    [7:0]       b_bin;                      //蓝色
    wire    [7:0]       g_bin;                      //绿色
    wire    [7:0]       r_bin;                      //红色
    wire    [7:0]       common_bin;                 //共模
    wire                write;                      //读写控制

    assign out          =   {g_bin, r_bin, b_bin};
    assign s_ready      =   _s_ready;
    assign m_valid      =   _m_valid;
    assign write        =   (s_valid || rst_status) && _s_ready;

    exp_filter_decay_10_rise_50  b_filt(
        .clk    (clk),
        .rst    (rst_status),
        .in     (in),
        .write  (write),
        .addr   (addr),
        .out    (b_bin)
    );

    diff  g_diff(
        .clk    (clk),
        .rst    (rst_status),
        .in     (in),
        .write  (write),
        .addr   (addr),
        .out    (g_bin)
    );

    exp_filter_decay_20_rise_99  r_filt(
        .clk    (clk),
        .rst    (rst_status),
        .in     (r_diff),
        .write  (write_delay),
        .addr   (addr_r),
        .out    (r_bin)
    );

    exp_filter_decay_99_rise_01  common_mode(
        .clk    (clk),
        .rst    (rst_status),
        .in     (in),
        .write  (write),
        .addr   (addr),
        .out    (common_bin)
    );

    always @(*) begin
        r_diff  <= in_delay - common_bin;
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            addr <= 8'd0;
            _s_ready <= 0;
            _m_valid <= 0;
            rst_status <= 1;
            direction <= 0;
        end
        else if (rst_status == 1) begin
            if (addr < 8'd39) begin
                addr <= addr + 1;
            end
            else begin
                addr <= 0;
                rst_status <= 0;
                _s_ready <= 1;
            end
        end
        else if (s_last == 1 && _s_ready == 1) begin
            addr <= 8'd39;
            _s_ready <= 0;
            direction <= 0;
        end
        else if (write_delay == 1 && _s_ready == 0) begin
            _m_valid <= 1;
        end
        else if (s_valid == 1 && _s_ready == 1) begin
            addr <= addr + 1;
        end
        else if (_m_valid == 1 && m_ready) begin
            if (addr > 8'd0 && direction == 0) begin
                addr <= addr - 1;
            end
            else if (addr == 8'd0 && direction == 0) begin
                direction <= 1;
            end
            else if (addr < 8'd39 && direction == 1) begin
                addr <= addr + 1;
            end
            else if (addr == 8'd39 && direction == 1) begin
                _s_ready <= 1;
                _m_valid <= 0;
                addr <= 8'd0;
            end
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            write_delay <= 0;
            addr_delay <= 8'd0;
            in_delay <= 8'd0;
        end
        else begin
            write_delay <= write;
            addr_delay <= addr;
            in_delay <= in;
        end
    end

    always @(*) begin
        if (write_delay == 1 && rst_status == 0) begin
            addr_r = addr_delay;
        end
        else begin
            addr_r = addr;
        end
    end

endmodule
