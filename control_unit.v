// Main Control Unit
module control_unit(
    input  [5:0] opcode, // Instruction bits [31:26]
    output reg   RegDst,   // Selects destination register (rd vs rt)
    output reg   ALUSrc,   // Selects ALU operand (register vs immediate)
    output reg   MemtoReg, // Selects data source for register write (ALU result vs memory)
    output reg   RegWrite, // Enables writing to the register file
    output reg   MemRead,  // Enables reading from data memory
    output reg   MemWrite, // Enables writing to data memory
    output reg   Branch,   // Indicates a branch instruction
    output reg   ALUOp1,   // ALU operation control bits
    output reg   ALUOp0,
    output reg   Jump      // Indicates a jump instruction
);

    // Opcodes for various instructions
    localparam R_TYPE = 6'b000000;
    localparam LW     = 6'b100011;
    localparam SW     = 6'b101011;
    localparam BEQ    = 6'b000100;
    localparam ADDI   = 6'b001000;
    localparam JUMP   = 6'b000010;

    always @(*) begin
        // Default values (for "don't care" or inactive signals)
        RegDst   = 1'b0;
        ALUSrc   = 1'b0;
        MemtoReg = 1'b0;
        RegWrite = 1'b0;
        MemRead  = 1'b0;
        MemWrite = 1'b0;
        Branch   = 1'b0;
        {ALUOp1, ALUOp0} = 2'b00; // Default to 'add' for lw/sw base addr calc
        Jump     = 1'b0;

        case (opcode)
            R_TYPE: begin // R-type (add, sub, and, or, slt)
                RegDst   = 1'b1;
                RegWrite = 1'b1;
                {ALUOp1, ALUOp0} = 2'b10; // Use funct field to decide
            end
            LW: begin // Load Word
                ALUSrc   = 1'b1;
                MemtoReg = 1'b1;
                RegWrite = 1'b1;
                MemRead  = 1'b1;
                {ALUOp1, ALUOp0} = 2'b00; // Add for address calculation
            end
            SW: begin // Store Word
                ALUSrc   = 1'b1;
                MemWrite = 1'b1;
                {ALUOp1, ALUOp0} = 2'b00; // Add for address calculation
            end
            BEQ: begin // Branch on Equal
                Branch   = 1'b1;
                {ALUOp1, ALUOp0} = 2'b01; // Subtract to check for zero
            end
            ADDI: begin // Add Immediate
                ALUSrc   = 1'b1;
                RegWrite = 1'b1;
                {ALUOp1, ALUOp0} = 2'b00; // Add
            end
            JUMP: begin // Jump
                Jump     = 1'b1;
            end
            default: begin // Undefined instruction
                // Use default values
            end
        endcase
    end

endmodule