`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/31/2026 07:16:02 PM
// Design Name: 
// Module Name: gto_schder
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


module gto_schder#(
  parameter NUM_WARPS = 8
)(
input clk,
input rst,
input [NUM_WARPS-1:0]warp_rd,
input [NUM_WARPS-1:0]hazards,

output logic valid,
output logic [$clog2(NUM_WARPS)-1:0]issued_warp
    );
    
    logic [$clog2(NUM_WARPS)-1:0]age[0:(NUM_WARPS-1)];
    logic [$clog2(NUM_WARPS)-1:0]curr_warp;
    logic [$clog2(NUM_WARPS)-1:0] min_age;
    logic switch;
    logic [$clog2(NUM_WARPS)-1:0] k;
    
    always_comb begin 
    
    //Initialisation
    valid = 0;
    issued_warp = curr_warp;
    min_age = '1;
    k = issued_warp;
    switch = 0;
    
    //Issue logic 
     if(warp_rd[curr_warp] && !hazards[curr_warp])begin 
         valid = 1;
         issued_warp = curr_warp;  //Issuing if active
         switch = 0;
     end else begin                       
        for(int i=0 ; i<NUM_WARPS ; i++)begin //If not active, finding oldest 'Ready' warp
        if (warp_rd[i] && !hazards[i]) begin
           if(age[i] < min_age)begin  //Logic to find minimum age 
           min_age = age[i];
           k = i;
           valid = 1;
           end 
           end 
        end 
        if(valid)begin
         issued_warp = k; //Issuing new Warp
         switch = 1;      // Switched to new Warp
         end 
     end 
    end    
    
    always_ff @(posedge clk)begin 
    if(!rst)begin 
    curr_warp <= 0;
    for(int j=0;j<NUM_WARPS;j++)begin // Initialisation of Age (Dynamic Warp ID)
    age[j] <= j;
    end 
    end else if(switch) begin  //Switching the active Warp
         curr_warp <= k;
       end 
    end 
endmodule
