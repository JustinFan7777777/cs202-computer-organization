/*
there are 32 registers in total, numbered from 0 to 31,each with a 32-bit width, complete code;
'rs1' and 'rs2' is the subscript of the read register, 'rd' is the subscript of the write register; 
The data read from the register with subscript 'rs1' is sent to the output port 'readData1';
The data read from the register with subscript 'rs2' is sent to the output port 'readData2';
At the rising edge of the clock('clk'), when the 'writeReg' is 1, write data from the input port "writeData" to the register labeled as 'rd'. If 'rd' is 0, the write is invalid.
Complete the following code
*/ 

module regs (
    input clk, // clock signal, used to synchronize the write operation of the registers
    input writeReg, //  control signal for writing, when it is 1, the data will be written to the register labeled as 'rd' at the rising edge of the clock
    input [4:0] rs1, // the subscript of the first read register, 5 bits are needed to represent 32 registers
    input [4:0] rs2, // also, the subscript of the second read register, 5 bits <-> 32 registers
    input [4:0] rd, // the subscript of the write register, 5 bits <-> 32 registers
    input [31:0] writeData, // the data to be written to the register labeled as 'rd', 32 bits width
    output [31:0] readData1, // the data read from the register with subscript 'rs1', 32 bits width
    output [31:0] readData2 // the data read from the register with subscript 'rs2', also 32 bits width
);

    reg [31:0] regs [0:31]; // 32 registers(numbered from 0 to 31), each with a 32-bit width
    // e.g. regs[0] is the register with subscript 0, regs[1] is the register with subscript 1, ..., regs[31] is the register with subscript 31

    // Initialization registers, the initial value of all registers is 0
    integer i;
    initial begin
        for (i = 0; i < 32; i = i + 1)
            regs[i] = 32'b0; // initialize all registers to 0     
    end

    /*Complete the read and write operations of the registers
    1. The data read from the register with subscript 'rs1' is sent to the output port 'readData1', using combinational logic.
    2. The data read from the register with subscript 'rs2' is sent to the output port 'readData2', using combinational logic
    3. At the rising edge of the clock('clk'), when the 'writeReg' is 1, write data from the input port "writeData" to the register labeled as 'rd'. If 'rd' is 0, the write is invalid  */

    // read operations
    assign readData1 = (rs1 == 5'd0) ? 32'b0 : regs[rs1];
    assign readData2 = (rs2 == 5'd0) ? 32'b0 : regs[rs2];
    // if the subscript of the read register is 0, meaning that we are reading data from x0, which only contains 0
    // otherwise, we read data from the register with subscript 'rs1' / 'rs2'

    always @(posedge clk) begin
        if (writeReg && (rd != 5'd0))
            regs[rd] <= writeData;
            // we are using non-blocking assignment here because the write operation is sequential logic, which is synchronized by the clock signal
            // however, if it is combinational logic, we should use blocking assignment, which is not synchronized by the clock signal
            // the difference is that: non-blocking assignment allows the new value to be used in the same clock cycle
            // while blocking assignment does not allow the new value to be used until the next clock cycle
    end     
    // only wirte data to the register labeled as 'rd' when:
    // 1. encounter the rising edge of the clock, because the write operation is sequential logic, which is synchronized by the clock signal
    // 2. the control signal 'writeReg' is 1, which means it is valid to write data to the register
    // 3. the subscript of the write register is not 0, as x0 only contains 0

endmodule