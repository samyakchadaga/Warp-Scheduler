`timescale 1ns / 1ps

module tb_scheduler;

    parameter NUM_WARPS = 8;
    parameter PROG_LEN = 64;

 
    logic clk;
    logic rst;

    logic [NUM_WARPS-1:0] load_bitmap;
    logic [NUM_WARPS-1:0] last_bitmap;

    logic valid_top;
    logic [$clog2(NUM_WARPS)-1:0] issued_warp;


  
    logic instr_mem [0:NUM_WARPS-1][0:PROG_LEN-1];


   
    integer pc [0:NUM_WARPS-1];


   
    integer cycles;
    integer instructions_issued;
    integer memory_requests;
    integer memory_returns;
    integer stall_cycles;

    integer warp_issue_count [0:NUM_WARPS-1];
    integer warp_load_count  [0:NUM_WARPS-1];


   
    top_module #(
        .NUM_WARPS(NUM_WARPS)
    ) DUT (
        .clk         (clk),
        .rst         (rst),
        .load_bitmap (load_bitmap),
        .last_bitmap (last_bitmap),
        .valid_top   (valid_top),
        .issued_warp (issued_warp)
    );



    initial begin
        clk = 1'b0;

        forever #5 clk = ~clk;
    end


    // ============================================================
   
    // 64 instructions per warp.
    //
    // LOADS:
    //      2, 10, 18, 26, 34, 42, 50, 58
    //
    // FINAL INSTRUCTION:
    //      63 = LOAD
    //
    // Therefore:
    //
    // 64 instructions / warp
    // 9 loads / warp
    //
    // 8 warps
    //
    // TOTAL:
    // 512 instructions
    // 72 loads
    // ============================================================

    initial begin

        for (int w = 0; w < NUM_WARPS; w++) begin

            for (int p = 0; p < PROG_LEN; p++) begin

                if ((p == PROG_LEN-1) || ((p % 8) == 2))
                    instr_mem[w][p] = 1'b1;   // LOAD
                else
                    instr_mem[w][p] = 1'b0;   // ALU

            end

        end

    end


   
    always_comb begin

        load_bitmap = '0;
        last_bitmap = '0;

        for (int w = 0; w < NUM_WARPS; w++) begin

            if (pc[w] < PROG_LEN) begin

            
                load_bitmap[w] =
                    instr_mem[w][pc[w]];

        
                last_bitmap[w] =
                    (pc[w] == PROG_LEN-1);

            end

        end

    end


    initial begin

        rst = 1'b0;

        cycles              = 0;
        instructions_issued = 0;
        memory_requests     = 0;
        memory_returns      = 0;
        stall_cycles        = 0;

        for (int w = 0; w < NUM_WARPS; w++) begin

            pc[w]               = 0;
            warp_issue_count[w] = 0;
            warp_load_count[w]  = 0;

        end

     
        repeat (2)
            @(posedge clk);

        rst = 1'b1;

    end


   
    always @(posedge clk) begin

        if (rst) begin

            cycles = cycles + 1;

            
            if (valid_top) begin

                instructions_issued =
                    instructions_issued + 1;

                warp_issue_count[issued_warp] =
                    warp_issue_count[issued_warp] + 1;


               
                if (instr_mem[issued_warp][pc[issued_warp]]) begin

                    memory_requests =
                        memory_requests + 1;

                    warp_load_count[issued_warp] =
                        warp_load_count[issued_warp] + 1;

                end

            end

            else begin

                stall_cycles =
                    stall_cycles + 1;

            end

        end

    end


   
    always @(posedge clk) begin

        if (rst) begin

            if (|DUT.mem_return_wire)
                memory_returns =
                    memory_returns + 1;

        end

    end


   
    always @(posedge clk) begin

        if (rst) begin

            if (valid_top) begin

                if (pc[issued_warp] < PROG_LEN)
                    pc[issued_warp] <=
                        pc[issued_warp] + 1;

            end

        end

    end


 
    initial begin

        wait_for_completion();

    end


    task wait_for_completion;

        bit finished;

        begin

            finished = 1'b0;

            while (!finished) begin

                @(posedge clk);

                finished = 1'b1;

                for (int w = 0; w < NUM_WARPS; w++) begin

                    if (pc[w] < PROG_LEN)
                        finished = 1'b0;

                end

            end

   
            repeat (10)
                @(posedge clk);

            print_results();

            $finish;

        end

    endtask


   
    task print_results;

        real ipc;
        real utilization;

        begin

            ipc =
                instructions_issued * 1.0 /
                cycles;

            utilization =
                (cycles - stall_cycles) * 100.0 /
                cycles;


            $display("");
            $display("================================================");
            $display("           GPU SCHEDULER PERFORMANCE (Round-Robin)");
            $display("================================================");

            $display("Cycles                : %0d",
                     cycles);

            $display("Instructions Issued   : %0d",
                     instructions_issued);

            $display("IPC                   : %0f",
                     ipc);

            $display("Memory Requests       : %0d",
                     memory_requests);

            $display("Memory Returns        : %0d",
                     memory_returns);

            $display("Stall Cycles          : %0d",
                     stall_cycles);

            $display("Scheduler Utilization : %0f%%",
                     utilization);

            $display("");

            $display("-------------- PER WARP STATISTICS -------------");

            for (int w = 0; w < NUM_WARPS; w++) begin

                $display(
                    "Warp %0d : Instructions = %0d | Loads = %0d | PC = %0d",
                    w,
                    warp_issue_count[w],
                    warp_load_count[w],
                    pc[w]
                );

            end

            $display("================================================");
            $display("");

        end

    endtask


endmodule