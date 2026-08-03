`timescale 1ns / 1ps
module tb_fk_mem;

 logic clk;
 logic rst;
 
 logic load;
 logic [2:0]issued_warp;
 
 logic mem_done;
 logic [2:0]done_warp;

fk_mem dut(
      .clk(clk),
      .rst(rst),
      .load(load),
      .issued_warp(issued_warp),
      .mem_done(mem_done),
      .done_warp(done_warp)
         );

always #5 clk = ~clk;

initial begin 
 
 clk = 0;
 rst = 0;
 load = 0;
 issued_warp = 3'b0;
 #20;
 
 rst =1;
 
 load = 1;
 issued_warp = 1;
 #10;
 
 load = 1;
 issued_warp = 0;
 #10;

load = 0;
 #10;

load = 1;
 issued_warp = 3;
 #10;

load = 0;
 #10;

load = 1;
 issued_warp = 5;
 #10;

load = 1;
 issued_warp = 7;
 #10;

load = 0 ;
 #10;

load = 1;
 issued_warp = 4;
 #100;

$finish;
end

endmodule
