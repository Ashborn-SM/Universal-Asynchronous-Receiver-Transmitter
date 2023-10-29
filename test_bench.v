`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 28.10.2023 22:03:42
// Design Name: 
// Module Name: test_bench
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


module test_bench();

    reg     p_clk;
    reg     reset;
    
    // baud gen
    reg[9:0]    counts;
    reg         enable;
    wire        tick;
    
    // rx
    wire[7:0]   rx_data;
    wire        rx_done;
    
    // tx
    reg[7:0]    tx_data;
    reg         tx_dv;
    reg         tx_start;
    wire        tx;
    wire        tx_done;
    

    receiver rx_0(p_clk, reset, tx, rx_data, rx_done, tick);
    baud_rate_gen #(.BITS(10)) brg(p_clk, reset, counts, enable, tick);
    transmitter tx_0(p_clk, reset, tx_data, tx_dv, tx_start, tx, tx_done, tick);
   
    always #0.5 p_clk = ~p_clk;
    initial begin
        p_clk = 1;
        reset = 1;
        
        counts = 542;
        enable = 0;
        
        tx_data = 8'h77;
        tx_dv = 0;
        tx_start = 0;
        
        #100
        reset = 0;
        tx_dv  = 1;
        
        #100
        tx_dv = 0;
        tx_start = 1;
        enable = 1;
        
        #100 
        tx_start = 0;
    
    end
endmodule
