`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 29.10.2023 13:03:30
// Design Name: 
// Module Name: transmitter
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


module transmitter(
        input       P_CLK,
        input       reset,
        
        // TX
        input[7:0]  i_TX_DATA,
        input       i_TX_DV,
        input       i_TX_START,
        output      o_TX,
        output      o_TX_DONE,
        
        input       i_TICK
    );
    
    localparam OVERSAMPLE_RATE = 16;
    localparam BITS = 8;
    localparam s0 = 2'b00, s1 = 2'b01, s2 = 2'b10, s3 = 2'b11;
    
    reg[7:0]        r_tx_data;
    reg             r_tx_done;
    reg             r_tx;
    
    reg[1:0]        current_state;
    reg[1:0]        next_state;
    
    reg[$clog2(OVERSAMPLE_RATE) - 1:0]  tick_counter;
    reg[$clog2(OVERSAMPLE_RATE) - 1:0]  tick_counter_d;
    
    reg[$clog2(BITS) - 1:0] tx_counter;
    reg[$clog2(BITS) - 1:0] tx_counter_d;
    
    always@(posedge P_CLK, posedge reset) begin
        if(reset) begin
            current_state <= s0;
            next_state <= s0;
            
            r_tx_data <= {BITS{1'b0}};
            r_tx_done <= 1'b0;
            r_tx <= 1'b1;
            
            tick_counter <= {$clog2(OVERSAMPLE_RATE){1'b0}};
            tick_counter_d <= {$clog2(OVERSAMPLE_RATE){1'b0}};
            
            tx_counter <= {$clog2(BITS){1'b0}};
            tx_counter_d <= {$clog2(BITS){1'b0}};            
        end
        if(i_TX_DV) r_tx_data <= i_TX_DATA;
        
        tick_counter_d <= tick_counter;
        tx_counter_d <= tx_counter;
        
        current_state <= next_state;       
    end
    
    always@(current_state, i_TICK, i_TX_START) begin
        case(current_state) 
            s0: begin
                if(i_TX_START) begin
                    tick_counter = 0;
                    next_state = s1;
                    r_tx = 1'b0;
                end
            end
            s1: begin
                if(i_TICK) begin
                    if(tick_counter_d == OVERSAMPLE_RATE - 1) begin
                        next_state = s2;
                        tick_counter = 0;
                        tx_counter = 0;
                        r_tx = r_tx_data[tx_counter_d];
                        tx_counter = tx_counter_d + 1'b1;
                    end
                    else tick_counter = tick_counter_d + 1'b1;
                end
            end
            s2: begin
                if(i_TICK) begin                    
                    if(tick_counter_d == OVERSAMPLE_RATE - 1) begin   
                        r_tx = r_tx_data[tx_counter_d];       
                        tx_counter = tx_counter_d + 1'b1;
                        tick_counter = 0;
                        if(tx_counter_d == BITS - 1)  next_state = s3;
                    end
                    else tick_counter = tick_counter_d + 1'b1;
                end
            end
            s3: begin
                if(i_TICK) begin
                    if(tick_counter_d === OVERSAMPLE_RATE - 1) begin
                        r_tx_done = 1'b1;
                        r_tx = 1'b1;
                        next_state = s0;
                    end
                    else tick_counter = tick_counter_d + 1'b1;
                end
            end
            default: next_state <= s0;
        endcase
    end
    
    assign o_TX_DONE = r_tx_done;
    assign o_TX = r_tx;
    
endmodule
