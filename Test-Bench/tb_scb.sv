`timescale 1ns / 1ps
module tb_scb;

logic clk;
logic rst;

logic valid;
logic [2:0]issued_warp;
logic mem_done;
logic [2:0]done_warp;

logic [7:0]hazards;

  scoreboard dut (
   .clk(clk),
   .rst(rst),
   .valid(valid),
   .issued_warp(issued_warp),
   .mem_done(mem_done),
   .done_warp(done_warp),
   .hazards(hazards)
  );
  
  always #5 clk = ~clk;  
  
  initial begin 
  
   clk = 0;
      rst = 0;
  
      valid = 0;
      mem_done = 0;
      issued_warp = 0;
      done_warp = 0;

      // Reset
      #20;
      rst = 1;

      //-------------------------
      // Issue Warp 3
      //-------------------------
      @(posedge clk);
      valid = 1;
      issued_warp = 3;

      @(posedge clk);
      valid = 0;

      //-------------------------
      // Issue Warp 6
      //-------------------------
      @(posedge clk);
      valid = 1;
      issued_warp = 6;

      @(posedge clk);
      valid = 0;

      //-------------------------
      // Memory returns Warp 3
      //-------------------------
      repeat(3) @(posedge clk);

      mem_done = 1;
      done_warp = 3;

      @(posedge clk);

      mem_done = 0;

      //-------------------------
      // Memory returns Warp 6
      //-------------------------
      repeat(2) @(posedge clk);

      mem_done = 1;
      done_warp = 6;

      @(posedge clk);

      mem_done = 0;

      //-------------------------
      // Issue Warp 1
      //-------------------------
      @(posedge clk);

      valid = 1;
      issued_warp = 1;

      @(posedge clk);

      valid = 0;

      //-------------------------
      // Finish
      //-------------------------
      repeat(5) @(posedge clk);

      $finish;

  end

  // Monitor

  initial begin
      $display("-------------------------------------------------------------");
      $display("Time   Valid  Issue  Done  WarpDone  Hazards");
      $display("-------------------------------------------------------------");

      $monitor("%4t     %b      %0d      %b      %0d      %b",
              $time,
              valid,
              issued_warp,
              mem_done,
              done_warp,
              hazards);
  end
endmodule