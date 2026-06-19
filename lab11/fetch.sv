`include "/data/workspace/myshixun/imem.v" 
module IFetch(
input clk, rst, branch, zero,
// clk: clock signal, 1 bit
// rst: asynchronous reset signal, 1 bit, active high, when rst = 1, pc should be reset to 0
// branch: 1 bit, if instruction = branch type, then branch = 1
// zero: 1 bit, the output of ALU, if result = 0 -> zero = 1 
input [31:0] imm,
// immediate value, 32 bits, -> pass from the 'imm gen' module
output [31:0] inst
// fetched instruction, 32 bits, output of instruction memory
    );

    reg [31:0] pc;
    // pc = program counter, 32 bits, holds the address of the current instruction
    imem #(
        .DATA_WIDTH(32),
        .ADDR_WIDTH(14),
        .INIT_FILE("ifetch_test.txt")
    ) uimem (
        .clka(clk),
        .addra(pc[15:2]),
        .douta(inst)
    );

    // pc update logic:
    // when rst is low, and at every falling edge of clk, we update pc
    // at posedge of rst (rst -> 1), pc should be reset to 0
    always@(negedge clk, posedge rst) begin
        // if rst = 1, then pc should be reset to 0
        if(rst)
            pc<= 32'h0;

        // if both the branch signal and zero signal are 1, update by imm
        // it means that instruction = branch, and two operands are equal -> jump to target address
        else if( branch && zero )
            pc<= pc + {imm[31:0], 1'b0};
            // imm from 'imm gen' module is already shifted left by 1 bit
            // so we need to add a 0 at the end to make it 32 bits

        // otherwise, just update pc by 4 to fetch next instruction, normally
        else
           pc<= pc + 4;    
    end
endmodule