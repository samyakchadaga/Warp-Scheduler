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

module top_module#(
  parameter NUM_WARPS = 8
)(
input clk,
input rst,

input [NUM_WARPS-1:0]load_bitmap,

output logic [$clog2(NUM_WARPS)-1:0]issued_warp
    );
    
    logic [NUM_WARPS-1:0]warp_rd_wire;
    logic [NUM_WARPS-1:0]hazard_wire;
    logic [$clog2(NUM_WARPS)-1:0]issued_warp_wire;
    logic scheduler_valid;
    logic [NUM_WARPS-1:0] mem_return_wire;

    st_tab st1(
    .clk(clk),
    .rst(rst),
    .issued_warp(issued_warp_wire),
    .mem_return(mem_return_wire),
    .scheduler_valid(scheduler_valid),
    .is_load(load_bitmap[issued_warp_wire]),
    .warp_rd(warp_rd_wire)
    );
    
     rr_schder rr1(
    .clk(clk),
    .rst(rst),
    .warp_rd(warp_rd_wire),
    .hazards(hazard_wire),
    .valid(scheduler_valid),
    .issued_warp(issued_warp_wire)
    );
    
     scoreboard sb1(
    .clk(clk),
    .rst(rst),
    .valid(scheduler_valid),
    .is_load(load_bitmap[issued_warp_wire]),
    .issued_warp(issued_warp_wire),
    .mem_return(mem_return_wire),
    
    .hazards(hazard_wire)
    );
    
     fk_mem fk1(
    .clk(clk),
    .rst(rst),
    .load(scheduler_valid && load_bitmap[issued_warp_wire]),
    .issued_warp(issued_warp_wire),
    .mem_return(mem_return_wire)
    );

assign issued_warp = issued_warp_wire;    
endmodule
