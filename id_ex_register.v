// ID/EX Pipeline Register
module id_ex_register(
    input           clk,
    input           rst,
    input           ID_EX_Flush,
    // Control Signals from ID
    input           RegWrite_ID,
    input           MemtoReg_ID,
    input           MemRead_ID,
    input           MemWrite_ID,
    input   [1:0]   ALUOp_ID,
    input           ALUSrc_ID,
    input           RegDst_ID,
    // Data from ID
    input   [31:0]  PC_ID,
    input   [31:0]  ReadData1_ID,
    input   [31:0]  ReadData2_ID,
    input   [31:0]  SignExtended_ID,
    input   [4:0]   Rs_ID,
    input   [4:0]   Rt_ID,
    input   [4:0]   Rd_ID,
    // Outputs to EX Stage
    output  reg     RegWrite_EX,
    output  reg     MemtoReg_EX,
    output  reg     MemRead_EX,
    output  reg     MemWrite_EX,
    output  reg [1:0]   ALUOp_EX,
    output  reg     ALUSrc_EX,
    output  reg     RegDst_EX,
    output  reg [31:0]  PC_EX,
    output  reg [31:0]  ReadData1_EX,
    output  reg [31:0]  ReadData2_EX,
    output  reg [31:0]  SignExtended_EX,
    output  reg [4:0]   Rs_EX,
    output  reg [4:0]   Rt_EX,
    output  reg [4:0]   Rd_EX
);

    always @(posedge clk or posedge rst) begin
        if (rst || ID_EX_Flush) begin
            // Flush signals to safe values (effectively a no-op)
            RegWrite_EX <= 1'b0;
            MemtoReg_EX <= 1'b0;
            MemRead_EX  <= 1'b0;
            MemWrite_EX <= 1'b0;
            ALUOp_EX    <= 2'b0;
            ALUSrc_EX   <= 1'b0;
            RegDst_EX   <= 1'b0;
            PC_EX <= 32'b0;
            ReadData1_EX <= 32'b0;
            ReadData2_EX <= 32'b0;
            SignExtended_EX <= 32'b0;
            Rs_EX <= 5'b0;
            Rt_EX <= 5'b0;
            Rd_EX <= 5'b0;
        end else begin
            // Pass signals through
            RegWrite_EX <= RegWrite_ID;
            MemtoReg_EX <= MemtoReg_ID;
            MemRead_EX  <= MemRead_ID;
            MemWrite_EX <= MemWrite_ID;
            ALUOp_EX    <= ALUOp_ID;
            ALUSrc_EX   <= ALUSrc_ID;
            RegDst_EX   <= RegDst_ID;
            PC_EX <= PC_ID;
            ReadData1_EX <= ReadData1_ID;
            ReadData2_EX <= ReadData2_ID;
            SignExtended_EX <= SignExtended_ID;
            Rs_EX <= Rs_ID;
            Rt_EX <= Rt_ID;
            Rd_EX <= Rd_ID;
        end
    end

endmodule