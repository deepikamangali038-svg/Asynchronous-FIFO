`timescale 1ns/1ps

module async_fifo #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 4
)(
    // Write clock domain
    input  wire                  wr_clk,
    input  wire                  wr_rst_n,
    input  wire                  wr_en,
    input  wire [DATA_WIDTH-1:0] wr_data,
    output wire                  full,

    // Read clock domain
    input  wire                  rd_clk,
    input  wire                  rd_rst_n,
    input  wire                  rd_en,
    output reg  [DATA_WIDTH-1:0] rd_data,
    output wire                  empty
);

    localparam DEPTH = (1 << ADDR_WIDTH);

    // Memory
    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];

    // Binary and Gray-code pointers
    reg [ADDR_WIDTH:0] wr_ptr_bin;
    reg [ADDR_WIDTH:0] wr_ptr_gray;

    reg [ADDR_WIDTH:0] rd_ptr_bin;
    reg [ADDR_WIDTH:0] rd_ptr_gray;

    // Synchronized pointers
    reg [ADDR_WIDTH:0] rd_ptr_gray_sync1;
    reg [ADDR_WIDTH:0] rd_ptr_gray_sync2;

    reg [ADDR_WIDTH:0] wr_ptr_gray_sync1;
    reg [ADDR_WIDTH:0] wr_ptr_gray_sync2;

    // Next pointers
    wire [ADDR_WIDTH:0] wr_ptr_bin_next;
    wire [ADDR_WIDTH:0] wr_ptr_gray_next;

    wire [ADDR_WIDTH:0] rd_ptr_bin_next;
    wire [ADDR_WIDTH:0] rd_ptr_gray_next;

    wire wr_do;
    wire rd_do;

    assign wr_do = wr_en && !full;
    assign rd_do = rd_en && !empty;

    // Binary to Gray conversion
    assign wr_ptr_bin_next =
        wr_ptr_bin + wr_do;

    assign wr_ptr_gray_next =
        (wr_ptr_bin_next >> 1) ^ wr_ptr_bin_next;

    assign rd_ptr_bin_next =
        rd_ptr_bin + rd_do;

    assign rd_ptr_gray_next =
        (rd_ptr_bin_next >> 1) ^ rd_ptr_bin_next;

    // ---------------------------------------------------------
    // Write pointer and memory
    // ---------------------------------------------------------

    always @(posedge wr_clk or negedge wr_rst_n) begin
        if (!wr_rst_n) begin
            wr_ptr_bin  <= 0;
            wr_ptr_gray <= 0;
        end
        else begin
            if (wr_do)
                mem[wr_ptr_bin[ADDR_WIDTH-1:0]] <= wr_data;

            wr_ptr_bin  <= wr_ptr_bin_next;
            wr_ptr_gray <= wr_ptr_gray_next;
        end
    end

    // ---------------------------------------------------------
    // Read pointer and output data
    // ---------------------------------------------------------

    always @(posedge rd_clk or negedge rd_rst_n) begin
        if (!rd_rst_n) begin
            rd_ptr_bin  <= 0;
            rd_ptr_gray <= 0;
            rd_data     <= 0;
        end
        else begin
            if (rd_do)
                rd_data <= mem[rd_ptr_bin[ADDR_WIDTH-1:0]];

            rd_ptr_bin  <= rd_ptr_bin_next;
            rd_ptr_gray <= rd_ptr_gray_next;
        end
    end

    // ---------------------------------------------------------
    // Synchronize read pointer into write clock domain
    // ---------------------------------------------------------

    always @(posedge wr_clk or negedge wr_rst_n) begin
        if (!wr_rst_n) begin
            rd_ptr_gray_sync1 <= 0;
            rd_ptr_gray_sync2 <= 0;
        end
        else begin
            rd_ptr_gray_sync1 <= rd_ptr_gray;
            rd_ptr_gray_sync2 <= rd_ptr_gray_sync1;
        end
    end

    // ---------------------------------------------------------
    // Synchronize write pointer into read clock domain
    // ---------------------------------------------------------

    always @(posedge rd_clk or negedge rd_rst_n) begin
        if (!rd_rst_n) begin
            wr_ptr_gray_sync1 <= 0;
            wr_ptr_gray_sync2 <= 0;
        end
        else begin
            wr_ptr_gray_sync1 <= wr_ptr_gray;
            wr_ptr_gray_sync2 <= wr_ptr_gray_sync1;
        end
    end

    // ---------------------------------------------------------
    // FIFO FULL detection
    // ---------------------------------------------------------

    assign full =
        (wr_ptr_gray_next ==
        {
            ~rd_ptr_gray_sync2[ADDR_WIDTH:ADDR_WIDTH-1],
             rd_ptr_gray_sync2[ADDR_WIDTH-2:0]
        });

    // ---------------------------------------------------------
    // FIFO EMPTY detection
    // ---------------------------------------------------------

    assign empty =
        (rd_ptr_gray_next == wr_ptr_gray_sync2);

endmodule
