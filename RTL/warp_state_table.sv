import state_pkg::*;
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Design Name: 
// Module Name: Warp State Table
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

module st_tab#(
    parameter NUM_WARPS = 8
)(
 input clk,
 input rst,
 
 input [$clog2(NUM_WARPS)-1:0]issued_warp,
 input scheduler_valid,
 input [NUM_WARPS-1:0]mem_return,
 input is_load, 
 
 output logic [NUM_WARPS-1:0] warp_rd
    );
    
    
   warp_state state [0:NUM_WARPS-1];
    integer i ;
    
    always_ff @(posedge clk) begin 
    if(!rst) begin
     for (int i = 0; i < NUM_WARPS; i++)
        state[i] <= READY;
    end 
    
    else begin
     for (int i=0; i<NUM_WARPS; i++) begin
            if (mem_return[i])
           state[i] <= READY;
        end

        if (scheduler_valid && is_load)
        state[issued_warp] <= MEM_WAIT;
  end  
end   


    always_comb begin 
    for(i=0; i<NUM_WARPS;i++)begin
      if(state[i] == READY) 
      warp_rd[i] = 1'b1;
      else 
       warp_rd[i] = 1'b0;
    end 
    end
    
     
endmodule
