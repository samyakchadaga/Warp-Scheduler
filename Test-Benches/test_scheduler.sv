`timescale 1ns/1ps

module tb_rr_scheduler;

logic clk;
logic rst;
logic [7:0] warp_rd;

logic valid;
logic [2:0] issued_warp;

rr_schder dut(
    .clk(clk),
    .rst(rst),
    .warp_rd(warp_rd),
    .valid(valid),
    .issued_warp(issued_warp)
);

always #5 clk = ~clk;

initial begin

    clk = 0;
    rst = 0;
    warp_rd = 8'b00000000;

    #20;
    rst = 1;

   
    warp_rd = 8'b00000000;
    #20;

  
    warp_rd = 8'b00001000;
    #20;

    
    warp_rd = 8'b10000000;
    #20;

    warp_rd = 8'b10101010;
    #50;

    warp_rd = 8'b11111111;
    #100;

   
    warp_rd = 8'b01010101;
    #100;

    $finish;

end

initial begin

$monitor("Time=%0t  rst=%b  warp_rd=%b  valid=%b  issued=%0d",
          $time,rst,warp_rd,valid,issued_warp);

end

endmodule