`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.10.2023 19:58:34
// Design Name: 
// Module Name: baud_rate_gen
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module baud_rate_gen #(parameter BITS = 8)(
        input       P_CLK,
        input       reset,
        
        input[BITS-1:0]  i_COUNT,
        input       i_ENABLE,
        output      o_DONE
    );
    
    wire[BITS-1:0]   counter;
    reg[BITS-1:0]    counter_d;
    reg              r_done;
    
    always@(posedge P_CLK, posedge reset) begin
        if(reset) counter_d <= {BITS{1'b0}};
        else begin 
            counter_d <= counter;
            r_done <= 0;
            if(counter_d == i_COUNT) begin 
                r_done <= 1;
                counter_d <= {BITS{1'b0}};
            end
        end
    end   
    assign counter = i_ENABLE? counter_d + 1: counter_d;
    assign o_DONE = r_done;
endmodule
