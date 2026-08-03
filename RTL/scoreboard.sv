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

module scoreboard#(
  parameter NUM_WARPS = 8
)(
input clk,
input rst,

input valid,
input [$clog2(NUM_WARPS)-1:0]issued_warp,
input logic [NUM_WARPS-1:0]mem_return,
input is_load,

output logic [NUM_WARPS-1:0]hazards
    );
    
    integer i;
    integer j;
    logic [NUM_WARPS-1:0]busy;
    
    always_ff @(posedge clk)begin 
    if(!rst) begin 
    busy <= '0;
    end else begin 
    if(valid && is_load)
    busy[issued_warp] <= 1;
    
    for(j=0 ; j<NUM_WARPS; j++)begin 
    if(mem_return[j])
     busy[j] <= 0;
    end 
    
    end 
 end 
 
 always_comb begin 
 for(i=0;i<NUM_WARPS;i++)begin 
 hazards[i] = busy[i];
 end 
 end 
endmodule
