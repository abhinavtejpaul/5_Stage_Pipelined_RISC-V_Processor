// IF/ID Pipeline Register
module if_id_register(
    input           clk,
    input           rst,
    input           IF_ID_Write, // Stall control
    input           IF_ID_Flush, // Branch control
    input   [31:0]  PC_IF,
    input   [31:0]  Instruction_IF,
    output  reg [31:0]  PC_ID,
    output  reg [31:0]  Instruction_ID
);

    always @(posedge clk or posedge rst) begin
        if (rst || IF_ID_Flush) begin
            PC_ID <= 32'b0;
            Instruction_ID <= 32'b0; // Flush to a no-op
        end else if (IF_ID_Write) begin
            PC_ID <= PC_IF;
            Instruction_ID <= Instruction_IF;
        end
    end

endmodule