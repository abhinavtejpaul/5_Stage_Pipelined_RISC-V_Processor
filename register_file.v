// Register File Module
module register_file(
    input         clk,
    input         RegWrite, // Control signal to enable writing
    input  [4:0]  ReadRegister1, // Address of first register to read (rs)
    input  [4:0]  ReadRegister2, // Address of second register to read (rt)
    input  [4:0]  WriteRegister, // Address of register to write to (rd)
    input  [31:0] WriteData,     // Data to write into the register
    output [31:0] ReadData1,     // Data from ReadRegister1
    output [31:0] ReadData2      // Data from ReadRegister2
);

    // 32 registers, each 32 bits wide
    reg [31:0] registers [0:31];

    // Asynchronous read (combinational)
    assign ReadData1 = registers[ReadRegister1];
    assign ReadData2 = registers[ReadRegister2];

    // Synchronous write (on the positive clock edge)
    always @(posedge clk) begin
        if (RegWrite && (WriteRegister != 5'b00000)) begin // Cannot write to register $zero
            registers[WriteRegister] <= WriteData;
        end
    end

    // Initialize all registers to 0 for simulation
    integer i;
    initial begin
        for (i=0; i<32; i=i+1) begin
            registers[i] = 32'h00000000;
        end
    end

endmodule