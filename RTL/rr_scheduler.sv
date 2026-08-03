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

module rr_schder#(
   parameter NUM_WARPS = 8
)(
input clk,
input rst,
input [NUM_WARPS-1:0]warp_rd,
input [NUM_WARPS-1:0]hazards,

output logic valid,
output logic [$clog2(NUM_WARPS)-1:0]issued_warp
    );
    integer k;
   logic [$clog2(NUM_WARPS):0] i;
    logic [$clog2(NUM_WARPS)-1:0] curr_warp;
    
    always_comb begin 
    issued_warp = 0;
     k=0;
     valid =0;
     for(i=curr_warp; k<NUM_WARPS ; i++)begin
      k++;
      if(!valid && warp_rd[i%NUM_WARPS] && !hazards[i%NUM_WARPS]) begin
       valid = 1;
       issued_warp = i%NUM_WARPS;
     end 
end
end 
    
    always_ff @(posedge clk) begin 
    if(!rst) begin
    curr_warp <= 0;
    end else if(valid == 1) 
     curr_warp <=  (issued_warp + 1)%NUM_WARPS;
   end
endmodule
