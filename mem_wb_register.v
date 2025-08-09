// MEM/WB Pipeline Register
module mem_wb_register(
    input           clk,
    input           rst,
    // Control Signals from MEM
    input           RegWrite_MEM,
    input           MemtoReg_MEM,
    // Data from MEM
    input   [31:0]  ReadData_MEM,
    input   [31:0]  ALUResult_MEM,
    input   [4:0]   WriteReg_MEM,
    // Outputs to WB Stage
    output  reg     RegWrite_WB,
    output  reg     MemtoReg_WB,
    output  reg [31:0]  ReadData_WB,
    output  reg [31:0]  ALUResult_WB,
    output  reg [4:0]   WriteReg_WB
);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            RegWrite_WB  <= 1'b0;
            MemtoReg_WB  <= 1'b0;
            ReadData_WB  <= 32'b0;
            ALUResult_WB <= 32'b0;
            WriteReg_WB  <= 5'b0;
        end else begin
            RegWrite_WB  <= RegWrite_MEM;
            MemtoReg_WB  <= MemtoReg_MEM;
            ReadData_WB  <= ReadData_MEM;
            ALUResult_WB <= ALUResult_MEM;
            WriteReg_WB  <= WriteReg_MEM;
        end
    end

endmodule