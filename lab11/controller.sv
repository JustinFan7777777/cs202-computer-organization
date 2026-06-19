module Controller(
    input [31:0] inst, // instruction, 32 bits, see RISC-V reference card for details
    output reg branch, aluSrc, memRead, memWrite, memToReg,
    // branch: 1 bit, if instruction = branch type, then branch = 1, otherwise branch = 0
    // aluSrc: 1 bit, choose the second operand of ALU, if register -> 0, if immediate -> 1
    // memRead: 1 bit, instruction = load (need read memory) -> 1, otherwise 0
    // memWrite: 1 bit, instruction = store (need write memory) -> 1. otherwise 0
    // memToReg: 1 bit, need write back to register from memory -> 1, otherwise 0

    output reg regWrite,
    // regWrite: 1 bit, need write back to register -> 1, otherwise 0
    output reg [1:0] ALUOp
    // ALUOp: 2 bits, control signal for ALU control unit
    // if we need to read / write data memory, then ALUOp = 00 (for load/store, we need to calculate the address)
    // if we need to branch, then ALUOp = 01 (for branch, we check whether two operands are equal?)
    // if instruction is R-type, then ALUOp = 10 (for R-type, check funct3 and funct7 to determine the operation)
);

    wire [6:0] opcode = inst[6:0];
    // opcode: 7 bits, always at the position of inst[6:0] of instruction

    always @(*) begin
        // default value, in case we encounter an instruction that we don't support
        // just set all control signals to 0
        branch = 0;
        aluSrc = 0;
        memRead = 0;
        memWrite = 0;
        memToReg = 0;
        regWrite = 0;
        ALUOp = 2'b00;

        // decode instruction based on different opcode
        case (opcode)
            // R-type: opcode = 0110011
            // e.g. add, sub, and, or, xor, sll, srl, sra, slt, sltu
            // features:
            // 1. two operands are both from register
            // 2. no need to access data memory
            // 3. result should be written back to register
            7'b0110011: begin
                branch = 0;
                aluSrc = 0; // read second operand from register
                memRead = 0;
                memWrite = 0;
                memToReg = 0;
                regWrite = 1; // need to write back to register
                ALUOp = 2'b10; // R-type -> check funct3 & funct7 to determine the operation
            end

            // Type: opcode = 0010011
            // e.g. addi, andi, ori, xori, slli, srli, srai, slti, sltiu
            // features:
            // 1. the second operand is an immediate value (encoded in instruction)
            // 2. also no need to access data memory
            // 3. result should be written back to register
            7'b0010011: begin
                branch = 0;
                aluSrc = 1; // read second operand from immediate value
                memRead = 0;
                memWrite = 0;
                memToReg = 0;
                regWrite = 1; // need to write back to register
                ALUOp = 2'b10; // I-type -> check funct3 to determine the operation
            end

            // Load: opcode = 0000011
            // e.g. lb, lh, lw, lbu, lhu
            // features:
            // 1. the second operand is an immediate value (offset for base address)
            // 2. need to read data memory
            // 3. result should be written back to register
            7'b0000011: begin
                branch = 0;
                aluSrc = 1; // read second operand from immediate value (offset)
                memRead = 1; // need to read data memory
                memWrite = 0;
                memToReg = 1; // write back to register from memory
                regWrite = 1; // need to write back to register
                ALUOp = 2'b00; // for load/store -> forced to 'add' to calculate target address
            end

            // Store: opcode = 0100011
            // e.g. sb, sh, sw
            // features:
            // 1. the second operand is an immediate value (offset for base address)
            // 2. need to write to data memory
            // 3. no need to write back to register
            7'b0100011: begin
                branch = 0;
                aluSrc = 1; // read second operand from immediate value (offset)
                memRead = 0;
                memWrite = 1; // need to write to data memory
                memToReg = 0;
                regWrite = 0; // no need to write back to register
                ALUOp = 2'b00; // for load/store -> forced to 'add' to calculate target address
            end

            // Branch: opcode = 1100011
            // e.g. beq, bne, blt, bge, bltu, bgeu
            // features:
            // 1. both operands are from register
            // 2. no need to access data memory
            // 3. no need to write back to register
            // 4. need to compare two operands and decide whether to branch or not
            7'b1100011: begin
                branch = 1; // need to branch
                aluSrc = 0; // read second operand from register
                memRead = 0;
                memWrite = 0;
                memToReg = 0;
                regWrite = 0; // no need to write back to register
                ALUOp = 2'b01; // branch -> forced to 'sub' to check whether equal
            end

            // default: for unsupported instructions, just set all control signals to 0
            default: begin
                branch = 0;
                aluSrc = 0;
                memRead = 0;
                memWrite = 0;
                memToReg = 0;
                regWrite = 0;
                ALUOp = 2'b00;
            end
        endcase
    end
endmodule