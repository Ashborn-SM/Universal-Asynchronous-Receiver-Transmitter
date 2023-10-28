`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.10.2023 20:20:21
// Design Name: 
// Module Name: receiver
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


module receiver(
        input           P_CLK,
        input           reset,
        
        // RX
        input           i_RX,
        output reg[7:0] o_RX_DATA,
        output          o_RX_DONE,
        
        input           i_TICK
    );
    
    localparam OVERSAMPLE_RATE = 16;
    localparam BITS = 8;
    localparam s0 = 2'b00, s1 = 2'b01, s2 = 2'b10, s3 = 2'b11;
    
    reg[1:0]    current_state;
    reg[1:0]    next_state;
    reg[3:0]    tick_counter; // No. of i_TICK
    reg[3:0]    tick_counter_d; 
    reg[2:0]    rx_counter;
    reg[2:0]    rx_counter_d;
    reg         r_rx_done;
    
    always@(posedge P_CLK, posedge reset) begin
        if(reset) begin
            current_state <= s0;
            next_state <= s0;
            rx_counter <= 3'b000;
            rx_counter_d <= 3'b000;
            tick_counter <= 4'b0000;
            tick_counter_d <= 4'b0000;
            r_rx_done <= 1'b0;
        end
        else begin 
            current_state <= next_state;
            tick_counter_d <= tick_counter;
            rx_counter_d <= rx_counter;
        end
    end
    
    always@(current_state, i_TICK) begin
        case(current_state) 
            s0: begin
                if(~i_RX) begin
                    r_rx_done = 1'b0;
                    next_state = s1;
                    tick_counter = 4'b0000; 
                end
            end
            s1: begin
                if(i_TICK) begin
                    if(tick_counter_d == OVERSAMPLE_RATE/2 - 1) begin 
                        next_state = s2;
                        rx_counter = 3'b000;
                        tick_counter = 4'b0000;
                    end
                    else tick_counter = tick_counter_d + 1'b1;
                end
            end
            s2: begin
                if(i_TICK) begin
                    if(tick_counter_d == OVERSAMPLE_RATE - 1) begin
                        o_RX_DATA[rx_counter_d] = i_RX;
                        rx_counter = rx_counter_d + 1;
                        tick_counter = 4'b0000;
                        if(rx_counter_d == BITS - 1) next_state <= s3;
                    end
                    else tick_counter = tick_counter_d + 1'b1;
                end
            end
            s3: begin
                if(i_TICK) begin
                    if(tick_counter_d == OVERSAMPLE_RATE - 1) begin
                        next_state = s0;
                        r_rx_done = 1'b1;
                    end
                end
            end
            default: next_state = s0;
        endcase
    end
    assign o_RX_DONE = r_rx_done;
endmodule
