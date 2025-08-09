// Arithmetic Logic Unit (ALU)
module alu(
    input  [31:0] A,
    input  [31:0] B,
    input  [3:0]  ALUControl, // Selects the operation
    output reg [31:0] Result,
    output        Zero        // Flag is high if the result is zero
);

    // Define ALU operations using parameters
    localparam ALU_AND  = 4'b0000;
    localparam ALU_OR   = 4'b0001;
    localparam ALU_ADD  = 4'b0010;
    localparam ALU_SUB  = 4'b0110;
    localparam ALU_SLT  = 4'b0111; // Set on Less Than
    localparam ALU_NOR  = 4'b1100;

    always @(*) begin // Combinational logic
        case (ALUControl)
            ALU_AND: Result = A & B;
            ALU_OR:  Result = A | B;
            ALU_ADD: Result = A + B;
            ALU_SUB: Result = A - B;
            ALU_SLT: Result = (A < B) ? 32'd1 : 32'd0;
            ALU_NOR: Result = ~(A | B);
            default: Result = 32'hxxxxxxxx; // Default case
        endcase
    end

    assign Zero = (Result == 32'h00000000);

endmodule