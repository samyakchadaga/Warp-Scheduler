import state_pkg::*;
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: Warp State Table
// Project Name: Warp-Scheduler
// Target Devices: GPU
// Tool Versions: Vivado 2024.1
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
 input last_inst,
 
 output logic [NUM_WARPS-1:0] warp_rd
    );
    
    
   warp_state state [0:NUM_WARPS-1];
   logic [NUM_WARPS-1:0] last_mem;
    integer i ;
    
    always_ff @(posedge clk) begin 
    if(!rst) begin
     for (int i = 0; i < NUM_WARPS; i++)begin
        state[i] <= READY;
        last_mem[i] <= 1'b0;
        end
    end 
    
    else begin
     for (int i=0; i<NUM_WARPS; i++) begin
              if (mem_return[i]) begin

                if (last_mem[i]) begin
                    state[i] <= DONE;
                    last_mem[i] <= 1'b0;
                end
                else begin
                    state[i] <= READY;
                end

            end
        end



        if (scheduler_valid)begin
        
        if(is_load)begin
        state[issued_warp] <= MEM_WAIT;
        
        if (last_inst)
                    last_mem[issued_warp] <= 1'b1;
          end 
          else if (last_inst) begin

                state[issued_warp] <= DONE;

            end
            end
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
