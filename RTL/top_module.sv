`timescale 1ns / 1ps
///////////////////////////////////////////////////////////////////////////////////
// Module Name: Top Module
// Project Name: Warp-Scheduler 
// Target Devices: GPU
// Tool Versions: Vivado 2024.1
//////////////////////////////////////////////////////////////////////////////////

module top_module#(
  parameter NUM_WARPS = 8
)(
input clk,
input rst,
input last_inst,
input [NUM_WARPS-1:0] load_bitmap,
input [NUM_WARPS-1:0] last_bitmap,

output logic valid_top,
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
    .last_inst(last_bitmap[issued_warp_wire]),
    .warp_rd(warp_rd_wire)
    );
    
    rr_schder rr1(   //rr_schder rr1 gto_schder gto1
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
assign valid_top = scheduler_valid;  
endmodule
