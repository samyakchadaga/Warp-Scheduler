`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/17/2026 09:18:10 PM
// Design Name: 
// Module Name: hhhh
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

module fk_mem#(
  parameter NUM_WARPS   = 8,
  parameter MEM_LATENCY = 8
)(
 input clk,
 input rst,
 
 input load,
 input [$clog2(NUM_WARPS)-1:0]issued_warp,
 
 output logic [NUM_WARPS-1:0]mem_return
    );
    
    logic [0:MEM_LATENCY-1][$clog2(NUM_WARPS)-1:0]shift_reg;
    logic [0:NUM_WARPS-1]valids;
    
    always_ff @(posedge clk) begin 
    if(!rst)begin 
      valids <= '0;
    end else begin
    
    valids <= valids >> 1;
    shift_reg <= shift_reg >> $clog2(NUM_WARPS);
    
        if(load) begin 
         shift_reg[0] <= issued_warp;
         valids[0] <= 1;
        end 
        
     end    
end 

 always_comb begin
    mem_return = '0;
    if (valids[MEM_LATENCY-1])
      mem_return[shift_reg[MEM_LATENCY-1]] = 1'b1;
  end
  
endmodule
