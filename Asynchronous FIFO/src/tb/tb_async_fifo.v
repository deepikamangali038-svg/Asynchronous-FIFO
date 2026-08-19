`timescale 1ns/1ps

module tb_async_fifo;

    parameter DATA_WIDTH = 8;
    parameter ADDR_WIDTH = 4;

    reg wr_clk;
    reg rd_clk;

    reg wr_rst_n;
    reg rd_rst_n;

    reg wr_en;
    reg rd_en;

    reg [DATA_WIDTH-1:0] wr_data;

    wire [DATA_WIDTH-1:0] rd_data;
    wire full;
    wire empty;

    // ---------------------------------------------------------
    // DUT
    // ---------------------------------------------------------

    async_fifo #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) dut (
        .wr_clk(wr_clk),
        .wr_rst_n(wr_rst_n),
        .wr_en(wr_en),
        .wr_data(wr_data),
        .full(full),

        .rd_clk(rd_clk),
        .rd_rst_n(rd_rst_n),
        .rd_en(rd_en),
        .rd_data(rd_data),
        .empty(empty)
    );

    // ---------------------------------------------------------
    // Write clock
    // 10 ns period
    // ---------------------------------------------------------

    initial begin
        wr_clk = 1'b0;

        forever #5 wr_clk = ~wr_clk;
    end

    // ---------------------------------------------------------
    // Read clock
    // 14 ns period
    // ---------------------------------------------------------

    initial begin
        rd_clk = 1'b0;

        forever #7 rd_clk = ~rd_clk;
    end

    // ---------------------------------------------------------
    // Test
    // ---------------------------------------------------------

    initial begin

        wr_rst_n = 1'b0;
        rd_rst_n = 1'b0;

        wr_en = 1'b0;
        rd_en = 1'b0;

        wr_data = 8'h00;

        $dumpfile("async_fifo.vcd");
        $dumpvars(0, tb_async_fifo);

        $display("============================================");
        $display("      ASYNCHRONOUS FIFO TESTBENCH");
        $display("============================================");

        #30;

        wr_rst_n = 1'b1;
        rd_rst_n = 1'b1;

        // -----------------------------------------------------
        // Write data
        // -----------------------------------------------------

        @(posedge wr_clk);
        wr_en   = 1'b1;
        wr_data = 8'hA1;

        @(posedge wr_clk);
        wr_data = 8'hB2;

        @(posedge wr_clk);
        wr_data = 8'hC3;

        @(posedge wr_clk);
        wr_data = 8'hD4;

        @(posedge wr_clk);
        wr_data = 8'hE5;

        @(posedge wr_clk);
        wr_en = 1'b0;

        $display("[%0t ns] Write operation completed",
                 $time);

        // Wait for pointer synchronization
        #50;

        // -----------------------------------------------------
        // Read data
        // -----------------------------------------------------

        @(posedge rd_clk);
        rd_en = 1'b1;

        @(posedge rd_clk);
        $display("[%0t ns] Read Data = %h",
                 $time, rd_data);

        @(posedge rd_clk);
        $display("[%0t ns] Read Data = %h",
                 $time, rd_data);

        @(posedge rd_clk);
        $display("[%0t ns] Read Data = %h",
                 $time, rd_data);

        @(posedge rd_clk);
        $display("[%0t ns] Read Data = %h",
                 $time, rd_data);

        @(posedge rd_clk);
        $display("[%0t ns] Read Data = %h",
                 $time, rd_data);

        @(posedge rd_clk);
        rd_en = 1'b0;

        #50;

        $display("--------------------------------------------");
        $display("FIFO EMPTY = %b", empty);
        $display("FIFO FULL  = %b", full);
        $display("--------------------------------------------");

        $display("Simulation completed successfully.");

        #20;
        $finish;

    end

endmodule
