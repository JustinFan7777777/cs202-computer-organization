module immediate_extraction (
    input [31:0] m_code, // RISC-V instruction code
    output reg [31:0] imm // immediate number
);

    wire [6:0] opcode = m_code[6:0];
    // through opcode, we can determine R/I/S/B/U/J
    always @(*) begin
        case (opcode)
            7'b0110011: imm = 32'b0;
            // R-type: no immediate
            // e.g. add, sub, sll, slt, xor, srl, sra, or, and
            // fixed output -> 0
            // instruction format:
            //  31      25 24  20 19  15 14  12 11   7 6      0
            // ┌──────────┬──────┬──────┬──────┬──────┬────────┐
            // │  funct7  │ rs2  │ rs1  │funct3│  rd  │ opcode │
            // └──────────┴──────┴──────┴──────┴──────┴────────┘
            //   [31:25]   [24:20] [19:15] [14:12] [11:7]  [6:0]

            7'b0010011,
            7'b0000011,
            7'b1100111: imm = {{20{m_code[31]}}, m_code[31:20]};
            // I-type: imm[11:0] = instruction[31:20]
            // 1. arithmetic/logical: 7'b0010011
            // e.g. addi, slti, sltiu, xori, ori, andi, slli, srli, srai
            // 2. load: 7'b0000011
            // e.g. lb, lh, lw, lbu, lhu
            // 3. jalr: 7'b1100111
            // e.g. jalr
            // jalr: jalr rd, rs1, imm[11:0]
            // {20{m_code[31]}} is sign extension
            // instruction format:
            //  31          20 19  15 14  12 11   7 6      0
            // ┌──────────────┬──────┬──────┬──────┬────────┐
            // │  imm[11:0]   │ rs1  │funct3│  rd  │ opcode │
            // └──────────────┴──────┴──────┴──────┴────────┘

            7'b0100011: imm = {{20{m_code[31]}}, m_code[31:25], m_code[11:7]};
            // S-type: imm[11:0] = instruction[31:25] + instruction[11:7]
            // m_code[31] is the MSB of the immediate, which is the sign bit
            // we need to do sign extension to get the correct immediate value
            // thus repeat it 20 times to fill the upper 20 bits of the immediate
            // e.g. sb, sh, sw
            // sw: sw rs2, imm[11:0](rs1)
            // instruction format:
            //  31      25 24  20 19  15 14  12 11   7 6      0
            // ┌──────────┬──────┬──────┬──────┬──────┬────────┐
            // │ imm[11:5]│ rs2  │ rs1  │funct3│imm[4:0] opcode│
            // └──────────┴──────┴──────┴──────┴──────┴────────┘

            7'b1100011: imm = {{19{m_code[31]}}, m_code[31], m_code[7],
                            m_code[30:25], m_code[11:8], 1'b0};
            // B-type: imm[12:1] = instruction[31] + instruction[7] +
            // instruction[30:25] + instruction[11:8]
            // immediate represents the offset to the target instruction
            // so the LSB must be 0, as instructions are 2 bytes aligned
            // as it supports both 16-bit and 32-bit instructions
            // e.g. beq, bne, blt, bge, bltu, bgeu
            // beq: beq rs1, rs2, type(imm[12:1])
            // instruction format:
            //  31     30    25 24  20 19  15 14  12 11   8  7    6      0
            // ┌──────┬───────┬──────┬──────┬──────┬──────┬─────┬────────┐
            // │i[12] │i[10:5]│ rs2  │ rs1  │funct3│i[4:1]│i[11]│ opcode │
            // └──────┴───────┴──────┴──────┴──────┴──────┴─────┴────────┘

            7'b0110111,
            7'b0010111: imm = {m_code[31:12], 12'b0};
            // U-type: imm[31:12] = instruction[31:12]
            // 1. lui (load upper immediate): 7'b0110111
            // e.g. lui rd, imm[31:12]
            // 2. auipc (add upper immediate to pc): 7'b0010111
            // e.g. auipc rd, imm[31:12]
            // instruction format:
            //  31                  12 11   7 6      0
            // ┌──────────────────────┬──────┬────────┐
            // │      imm[31:12]      │  rd  │ opcode │
            // └──────────────────────┴──────┴────────┘

            7'b1101111: imm = {{11{m_code[31]}}, m_code[31], m_code[19:12],
                            m_code[20], m_code[30:21], 1'b0};
            // J-type: imm[20:1] = instruction[31] + instruction[19:12] + 
            // instruction[20] + instruction[30:21]
            // immediate represents the offset to the target instruction
            // so the LSB must be 0, as instructions are 2 bytes aligned
            // as it supports both 16-bit and 32-bit instructions
            // e.g. jal
            // jal: jal rd, imm[20:1]
            // instruction format:
            //  31     30      21  20   19      12 11   7 6      0
            // ┌──────┬──────────┬─────┬──────────┬──────┬────────┐
            // │i[20] │ i[10:1]  │i[11]│ i[19:12] │  rd  │ opcode │
            // └──────┴──────────┴─────┴──────────┴──────┴────────┘

            default: imm = 32'b0;
            // unknown opcode, output 0
        endcase
    end
endmodule