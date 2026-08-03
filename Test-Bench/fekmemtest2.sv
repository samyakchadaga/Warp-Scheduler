`timescale 1ns/1ps

module fk_mem_tb;

logic clk;
logic rst;

logic load;
logic [2:0] issued_warp;

logic [7:0] mem_return;
logic [2:0] done_warp;

fk_mem DUT(
    .clk(clk),
    .rst(rst),
    .load(load),
    .issued_warp(issued_warp),
    .mem_return(mem_return),
    .done_warp(done_warp)
);

//
// Clock
//
always #5 clk = ~clk;

//
// Monitor
//
initial begin
    $monitor("T=%0t load=%b warp=%0d mem_return=%b done_warp=%0d",
              $time, load, issued_warp,
              mem_return, done_warp);
end

//
// Stimulus
//
initial begin

    clk = 0;
    rst = 0;
    load = 0;
    issued_warp = 0;

    // Reset
    #20;
    rst = 1;

    //--------------------------
    // Issue Warp 3
    //--------------------------
    @(posedge clk);
    load <= 1;
    issued_warp <= 3;

    @(posedge clk);
    load <= 0;

    //--------------------------
    // Wait 4 cycles
    //--------------------------
    repeat(4) @(posedge clk);

    //--------------------------
    // Issue Warp 6
    //--------------------------
    load <= 1;
    issued_warp <= 6;

    @(posedge clk);
    load <= 0;

    //--------------------------
    // Wait enough time for both
    //--------------------------
    repeat(15) @(posedge clk);

    $finish;
end

endmodule