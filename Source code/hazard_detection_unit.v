// Hazard Detection Unit
module hazard_detection_unit(
    // Inputs from ID Stage
    input   [4:0]   Rs_ID,
    input   [4:0]   Rt_ID,
    // Inputs from EX Stage
    input           MemRead_EX,
    input   [4:0]   Rt_EX,
    // Inputs for branch/jump
    input           Branch_ID,
    input           Jump_ID,
    // Outputs to control pipeline
    output  reg     PCWrite,
    output  reg     IF_ID_Write,
    output  reg     ID_EX_Flush // Control signal for ID/EX mux
);

    always @(*) begin
        // Default: No hazard
        PCWrite = 1'b1;
        IF_ID_Write = 1'b1;
        ID_EX_Flush = 1'b0;

        // 1. Load-Use Hazard Detection
        // If the instruction in EX is a load, and its destination register (rt)
        // is one of the source registers (rs or rt) for the instruction in ID.
        if (MemRead_EX && ((Rt_EX == Rs_ID) || (Rt_EX == Rt_ID))) begin
            PCWrite = 1'b0;       // Stall PC
            IF_ID_Write = 1'b0;   // Stall IF/ID register
            ID_EX_Flush = 1'b1;   // Flush the (wrongly fetched) instruction in EX, turning it into a no-op
        end
    end

endmodule