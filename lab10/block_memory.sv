// -----------------------------------------------------------------------------
// Module      : dmem
// Author      : Yuhui Bai
// Description : Single-port synchronous Block RAM (BRAM).
//               Replacement of Vivado blk_mem_gen IP.
//               Size: Depth = 2^ADDR_WIDTH, Width = DATA_WIDTH.
//               Content Init: Set INIT_FILE parameter to a hex file path, or let it empty.
//               Complete the following code
// -----------------------------------------------------------------------------

module dmem #(
    parameter DATA_WIDTH = 32, // Memory bit width
    parameter ADDR_WIDTH = 14, // Memory depth = 2^ADDR_WIDTH
    // Recommend using relative path; put file in same directory
    parameter INIT_FILE  = "memdata.hex"  // Relative path to hex file, empty if all zeros
)(
    input clka, // clock signal, used to synchronize the read & write operation
    input wea, // we = write enable, when it is 1 (active high), the data will be written to the memory at the rising edge of the clock
    input [ADDR_WIDTH-1:0] addra, // address for read/write operation, width is determined by ADDR_WIDTH parameter
    input [DATA_WIDTH-1:0] dina, // din = data input, the data to be written to the memory, width is determined by DATA_WIDTH parameter
    output reg [DATA_WIDTH-1:0] douta // dout = data output, the data read from the memory, width is determined by DATA_WIDTH parameter
);

    localparam DEPTH = (1 << ADDR_WIDTH); // Memory depth calculated from address width
    // (1 << ADDR_WIDTH) is equivalent to 2^ADDR_WIDTH, 1 shifted left by ADDR_WIDTH positions
    // which gives the total number of addressable locations in the memory

    // Must use Block RAM attribute to ensure synthesis as BRAM，Otherwise may run out of resources or cause timing issues
    (* ram_style = "block" *) reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];
    // [0:DEPTH-1] defines the range of memory addresses, from 0 to DEPTH-1
    // reg [DATA_WIDTH-1:0] defines the width of each memory location, which is DATA_WIDTH bits

    // Initialization
    integer i;
    initial begin
        for (i = 0; i < DEPTH; i = i + 1)
            mem[i] = {DATA_WIDTH{1'b0}}; // initialize all memory locations to zero

        // if INIT_FILE is provided (not empty), use $readmemh to read the hex file and initialize the memory content
        if (INIT_FILE != "")
            $readmemh(INIT_FILE, mem);
        // if the file is missing or empty, simulation will continue with the zero-initialized values
    end

    // BRAM is synchronous; data is strictly captured and output at clock edge
    // (Same as IP core functionality)
    always @(posedge clka) begin
        if (wea) begin
            mem[addra] <= dina; // write data to memory at the rising edge of the clock when write enable is active
            douta <= dina; // output the written data immediately (write-first mode)

        end else begin
            douta <= mem[addra]; // read data from memory at the rising edge of the clock when write enable is inactive
        end
    end

endmodule