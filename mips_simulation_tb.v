

// Testbench for the complete MIPS Pipelined Processor
`timescale 1ns/1ps

module mips_simulation_tb;

    // 1. Declare signals to connect to the processor
    // These are 'reg' because this testbench is driving them.
    reg clk;
    reg rst;

    // 2. Instantiate the Unit Under Test (UUT)
    // This is your top-level MIPS processor module.
    mips_pipelined_processor uut (
        .clk(clk),
        .rst(rst)
    );

    // 3. Clock Generation
    // This `always` block creates a clock signal with a 10ns period (100 MHz).
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // Every 5ns, the clock edge flips
    end

    // 4. Simulation Control and Reset Sequence
    // This `initial` block defines the entire test sequence.
    initial begin
        // Start with reset asserted (high)
        rst = 1;
        #15; // Hold reset for 15ns to allow the processor to stabilize

        // De-assert reset (low) to begin program execution
        rst = 0;
        #200; // Let the simulation run for 200ns to complete the program

        // End the simulation
        $display("-------------------------------------------------");
        $display("Simulation Finished.");
        $finish;
    end

    // 5. Monitoring and Display
    // This is the most important part for verification.
    // The `$monitor` system task prints a line every time one of its signals changes.
    initial begin
        $display("--- MIPS Processor Simulation Start ---");
        $display("Time(ns)  PC         $t0(R8)  $t1(R9)  $t2(R10) $t3(R11) $t4(R12)");
        $display("----------------------------------------------------------------------");
        
        // Monitor the program counter and the registers used in your test program.
        // uut.pc_reg.current_pc accesses the PC value from within the processor instance.
        // uut.reg_file.registers[#] accesses the register values directly for monitoring.
        $monitor("%0t       %0h   %d        %d        %d        %d        %d",
                 $time, uut.PC_IF, uut.reg_file.registers[8], uut.reg_file.registers[9],
                 uut.reg_file.registers[10], uut.reg_file.registers[11], uut.reg_file.registers[12]);
    end

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0);
    end 

endmodule