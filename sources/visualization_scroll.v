`timescale 1ns / 1ps

module visualization_scroll(
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




    reg    [7:0]         blue;
    reg    [7:0]         green;
    reg    [7:0]         red;
    reg                 write_delay;
    reg     [7:0]       addr;
    reg                 _s_ready;
    reg                 _m_valid;
    reg                 rst_status;
    reg                 direction;
    reg                 myflag;
    reg     [7:0]         blue_bins [39:0]  ;
    reg     [7:0]         green_bins [39:0]  ;
    reg     [7:0]         red_bins [39:0]  ;
    reg     [7:0]         bin;
    reg     [7:0]       addr_RGB;
    reg               myclk;
    

    wire    [7:0]       a_bin;
     wire    [7:0]       b_bin;
      wire    [7:0]       r_bin;
       wire    [7:0]       g_bin;
    wire                write;


    assign b_bin        =   blue_bins[addr_RGB];
    assign r_bin        =   red_bins[addr_RGB];
    assign g_bin        =   green_bins[addr_RGB];




    assign out          =   {g_bin, r_bin, b_bin};
    assign s_ready      =   _s_ready;
    assign m_valid      =   _m_valid;
    assign write        =   (s_valid &&_s_ready) || (rst_status&& _s_ready);

    exp_filter_decay_10_rise_50  filt(
        .clk    (clk),
        .rst    (rst_status),
        .in     (in),
        .write  (write),
        .addr   (addr),
        .out    (a_bin)
    );




     
     
     
     
     
     
    always @(posedge clk or posedge rst) begin
        bin<=a_bin;   
        write_delay<=write;



        if (rst) begin
            addr <= 8'd0;
            addr_RGB<= 8'd0;
            _s_ready <= 0;
            _m_valid <= 0;
             myflag <= 0;
            rst_status <= 1;
            direction <= 0;
             blue<= 8'd0;
             red<= 8'd0;
              green<= 8'd0;
            blue_bins[0]<= 8'd0;
            red_bins[0]<= 8'd0;
            green_bins[0]<= 8'd0;
        end
        
        
        
        
        
        
        
        else if (rst_status == 1) begin
            if (addr < 8'd39) begin
                addr <= addr + 1; 
                blue_bins[addr]<= 8'd0;
                red_bins[addr]<= 8'd0;
                green_bins[addr]<= 8'd0;        
            end
           else if (addr == 8'd39) begin
               blue_bins[addr]<= 8'd0;
               red_bins[addr]<= 8'd0;
               green_bins[addr]<= 8'd0;       
               
                addr <= 0;
                rst_status <= 0;
                _s_ready <= 1;
            end
           else begin
           addr <= 0;
            rst_status <= 0;
             _s_ready <= 1;
          end
        end






        else if (s_valid == 1 && _s_ready == 1) begin
           
            if(addr==8'd39) begin
             _s_ready <= 0;
             addr<=8'd0;
            end
            else begin
             addr <= addr + 1;
            end
        end
        
        
        
        
        
        
        else if (_m_valid == 1 && m_ready == 1 && myclk==1&& _s_ready == 0) begin
                    if (addr_RGB > 8'd0 && direction == 0) begin
                        addr_RGB <= addr_RGB - 1;
                    end
                    else if (addr_RGB == 8'd0 && direction == 0) begin
                        direction <= 1;
                    end
                    else if (addr_RGB < 8'd39 && direction == 1) begin
                        addr_RGB <= addr_RGB + 1;
                    end
                    else if (addr_RGB == 8'd39 && direction == 1) begin
                        _s_ready <= 1;
                        _m_valid <= 0;
                        addr_RGB <= 8'd0;
                        addr <= 8'd0;
                         myclk <= 0; 
                         green<=8'd0;
                         red<=8'd0;
                         blue<=8'd0;

                    end
         end
         
         


         
         
         else if(_m_valid == 0 && myflag == 1 && myclk == 0&& _s_ready == 0) begin
              if (addr == 8'd0 ) begin
                        addr <= 8'd0;
                         _s_ready <= 0;
                          _m_valid <= 1;
                          direction <= 0;
                         myflag <= 0;   
                         myclk <= 1;
                         addr_RGB <= 8'd39;
                          blue_bins[0] <=blue; 
                          red_bins[0]<=red;
                           green_bins[0]<=green;
              end
              else if(addr < 8'd40&&addr > 8'd0) begin
                   blue_bins[addr]<= blue_bins[addr-1];
                   red_bins[addr]<= red_bins[addr-1];
                   green_bins[addr]<= green_bins[addr-1];

                   addr <= addr -1;
              end
              else begin
              addr <= 8'd0;
             _s_ready <= 0;
              _m_valid <= 1;
              direction <= 0;
               myflag <= 0;   
               myclk <= 1;
               blue_bins[0] <=blue; 
               red_bins[0]<=red;
               green_bins[0]<=green;
              end
         end
         
         
         
         
         
         else if (_m_valid == 0 && myflag == 0&&myclk == 0&& _s_ready == 0) begin
              if (addr > 8'd38 ) begin
                 addr <= 8'd39;
                 myflag <= 1;    
              end
              else if (addr < 8'd39) begin
                   addr <= addr + 1;  
                   if (addr < 8'd13&&addr > 8'd3) begin
                        if(bin > blue) begin
                        blue<=bin;
                        end  
                   end              
                   else if(addr < 8'd26&&addr > 8'd13) begin
                        if(bin > red) begin
                        red<=bin;
                        end                 
                   end 
                   else if(addr < 8'd40&&addr > 8'd26) begin
                        if(bin > green) begin
                        green<=bin;
                        end                   
                   end                 
                       
               end
          end
          
          
          
          
          
          
          
          
    end

endmodule
