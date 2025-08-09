// Forwarding Unit
module forwarding_unit(
    // Inputs from Pipeline Registers
    input           RegWrite_MEM,
    input           RegWrite_WB,
    input   [4:0]   Rs_EX,
    input   [4:0]   Rt_EX,
    input   [4:0]   WriteReg_MEM,
    input   [4:0]   WriteReg_WB,
    // Outputs to control ALU input MUXes
    output  reg [1:0]   ForwardA,
    output  reg [1:0]   ForwardB
);

    // Forwarding paths:
    // 00: No forward (use register file value)
    // 10: Forward from MEM stage result (MEM/WB register)
    // 01: Forward from EX stage result (EX/MEM register)

    always @(*) begin
        // Default: no forwarding
        ForwardA = 2'b00;
        ForwardB = 2'b00;

        // --- EX/MEM Hazard Check ---
        // Check if the destination register of the instruction in MEM stage
        // matches one of the source registers of the instruction in EX stage.
        if (RegWrite_MEM && (WriteReg_MEM != 5'b0) && (WriteReg_MEM == Rs_EX)) begin
            ForwardA = 2'b01; // Forward from MEM to ALU input A
        end
        if (RegWrite_MEM && (WriteReg_MEM != 5'b0) && (WriteReg_MEM == Rt_EX)) begin
            ForwardB = 2'b01; // Forward from MEM to ALU input B
        end

        // --- MEM/WB Hazard Check ---
        // Check if the destination register of the instruction in WB stage
        // matches one of the source registers of the instruction in EX stage.
        // This has lower priority than the EX/MEM forward (closer hazard takes precedence).
        if (RegWrite_WB && (WriteReg_WB != 5'b0) && (WriteReg_WB == Rs_EX) && (ForwardA == 2'b00)) begin
            ForwardA = 2'b10; // Forward from WB to ALU input A
        end
        if (RegWrite_WB && (WriteReg_WB != 5'b0) && (WriteReg_WB == Rt_EX) && (ForwardB == 2'b00)) begin
            ForwardB = 2'b10; // Forward from WB to ALU input B
        end
    end
endmodule