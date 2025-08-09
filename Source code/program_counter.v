// Program Counter Module
module program_counter(
    input         clk,
    input         rst,
    input  [31:0] next_pc, // Input for the next PC value (from branch, jump, or PC+4)
    output reg [31:0] current_pc // Output the current PC value
);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            current_pc <= 32'h0000_0000; // Reset PC to 0
        end else begin
            current_pc <= next_pc; // Load the next PC address
        end
    end

endmodule