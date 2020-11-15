`timescale 1ns / 1ps

module reshape_output(
    input clk,
    input reset,
    input [15:0] in[40],
    output [15:0] out[1],
    
    input s_valid,
    output s_ready,
    output m_valid,
    input m_ready,
    output m_last
    );
    
    logic [15:0] banks[40][1];
    logic [5:0] q_counter;
    logic [5:0] d_counter;
    
    logic d_valid;
    logic q_valid;
    
    assign m_valid = q_valid;
    assign m_last = q_counter == 39;
    assign out = banks[0];
    assign s_ready = !q_valid;
    
    always_comb begin
        if(s_valid & s_ready) begin
            d_counter = 6'd0;
            d_valid = 1'b0;
        end
        else begin
            d_valid = q_counter<39;
            if(q_valid && m_ready) begin
                d_counter = q_counter+1;
            end else begin
                d_counter = q_counter;
            end
        end
    end
    
    always_ff @(posedge clk or posedge reset) begin
        if(reset) begin
            q_counter <= 40;
            q_valid <= 0;
        end
        else begin
            q_counter <= d_counter;
            q_valid <= d_valid;

              if(s_valid & s_ready) begin
                  for(int i=0; i<40; i++) begin
                      for(int j=0; j<1; j++) begin
                          banks[i][j] <= in[j + i];
                      end
                  end
              end
              else if(m_valid & m_ready) begin
                for(int i=0; i<39; i++) begin
                    banks[i] <= banks[i+1];
                end
              end
        end
    
    end
endmodule
