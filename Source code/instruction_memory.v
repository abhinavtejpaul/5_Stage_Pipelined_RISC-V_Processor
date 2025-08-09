// Instruction Memory Module
module instruction_memory(
    input  [31:0] address,
    output [31:0] instruction
);

    // 1024 x 32-bit memory (4KB)
    // The memory is initialized from an external file (e.g., "instructions.mem")
    reg [31:0] mem [0:1023];

    initial begin
        $readmemh("instructions.mem", mem);
    end

    // Address is byte-addressed, so we discard the lower 2 bits for word alignment.
    assign instruction = mem[address[11:2]];

endmodule