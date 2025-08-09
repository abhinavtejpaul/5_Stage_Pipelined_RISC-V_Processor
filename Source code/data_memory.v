// Data Memory Module
module data_memory(
    input         clk,
    input         MemRead,  // Read enable
    input         MemWrite, // Write enable
    input  [31:0] address,  // Address from ALU
    input  [31:0] WriteData,
    output [31:0] ReadData
);
    // 1024 x 32-bit memory (4KB)
    reg [31:0] mem [0:1023];

    // Read operation is combinational
    // Address is byte-addressed, so align to word by ignoring lower 2 bits
    assign ReadData = MemRead ? mem[address[11:2]] : 32'hxxxxxxxx;

    // Write operation is synchronous
    always @(posedge clk) begin
        if (MemWrite) begin
            mem[address[11:2]] <= WriteData;
        end
    end

endmodule