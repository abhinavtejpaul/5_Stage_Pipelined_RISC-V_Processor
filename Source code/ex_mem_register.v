// EX/MEM Pipeline Register
module ex_mem_register(
    input           clk,
    input           rst,
    // Control Signals from EX
    input           RegWrite_EX,
    input           MemtoReg_EX,
    input           MemRead_EX,
    input           MemWrite_EX,
    input           Branch_EX,
    // Data from EX
    input   [31:0]  ALUResult_EX,
    input   [31:0]  ReadData2_EX, // Data to be stored for sw
    input   [4:0]   WriteReg_EX,
    input           Zero_EX,      // ALU Zero flag
    // Outputs to MEM Stage
    output  reg     RegWrite_MEM,
    output  reg     MemtoReg_MEM,
    output  reg     MemRead_MEM,
    output  reg     MemWrite_MEM,
    output  reg     Branch_MEM,
    output  reg [31:0]  ALUResult_MEM,
    output  reg [31:0]  StoreData_MEM,
    output  reg [4:0]   WriteReg_MEM,
    output  reg     Zero_MEM
);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // Reset all outputs to safe/zero values
            RegWrite_MEM <= 1'b0;
            MemtoReg_MEM <= 1'b0;
            MemRead_MEM  <= 1'b0;
            MemWrite_MEM <= 1'b0;
            Branch_MEM   <= 1'b0;
            ALUResult_MEM <= 32'b0;
            StoreData_MEM <= 32'b0;
            WriteReg_MEM  <= 5'b0;
            Zero_MEM      <= 1'b0;
        end else begin
            // Pass signals through
            RegWrite_MEM <= RegWrite_EX;
            MemtoReg_MEM <= MemtoReg_EX;
            MemRead_MEM  <= MemRead_EX;
            MemWrite_MEM <= MemWrite_EX;
            Branch_MEM   <= Branch_EX;
            ALUResult_MEM <= ALUResult_EX;
            StoreData_MEM <= ReadData2_EX;
            WriteReg_MEM  <= WriteReg_EX;
            Zero_MEM      <= Zero_EX;
        end
    end

endmodule