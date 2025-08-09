`include "alu.v"
`include "control_unit.v"
`include "data_memory.v"
`include "ex_mem_register.v"
`include "forwarding_unit.v"
`include "hazard_detection_unit.v"
`include "id_ex_register.v"
`include "if_id_register.v"
`include "instruction_memory.v"
`include "mem_wb_register.v"
`include "program_counter.v"
`include "register_file.v" 


module mips_pipelined_processor(
    input clk,
    input rst
);

    // Wires for pipeline control
    wire PCWrite, IF_ID_Write, ID_EX_Flush, PCSrc;
    wire [1:0] ForwardA, ForwardB;

    // IF Stage Wires
    wire [31:0] PC_Next, PC_IF, PC_Plus4_IF, Instruction_IF;
    
    // ID Stage Wires
    wire [31:0] PC_ID, Instruction_ID, ReadData1_ID, ReadData2_ID, SignExtended_ID;
    wire RegWrite_ID, MemtoReg_ID, MemRead_ID, MemWrite_ID, ALUSrc_ID, RegDst_ID, Branch_ID, Jump_ID;
    wire [1:0] ALUOp_ID;

    // EX Stage Wires
    wire [31:0] PC_EX, ReadData1_EX, ReadData2_EX, SignExtended_EX, ALUResult_EX, ALUInputA, ALUInputB;
    wire [4:0] Rs_EX, Rt_EX, Rd_EX, WriteReg_EX;
    wire RegWrite_EX, MemtoReg_EX, MemRead_EX, MemWrite_EX, ALUSrc_EX, RegDst_EX, Branch_EX, Zero_EX;
    wire [1:0] ALUOp_EX;

    // MEM Stage Wires
    wire [31:0] ALUResult_MEM, StoreData_MEM, ReadData_MEM;
    wire [4:0] WriteReg_MEM;
    wire RegWrite_MEM, MemtoReg_MEM, MemRead_MEM, MemWrite_MEM, Branch_MEM, Zero_MEM;

    // WB Stage Wires
    wire [31:0] ALUResult_WB, ReadData_WB, WriteData_WB;
    wire [4:0] WriteReg_WB;
    wire RegWrite_WB, MemtoReg_WB;

    //=============== IF STAGE ===============//
    assign PC_Plus4_IF = PC_IF + 4;
    assign PCSrc = Branch_MEM && Zero_MEM;
    assign PC_Next = PCSrc ? ALUResult_MEM : PC_Plus4_IF; // Branch uses ALU result from MEM stage

    program_counter pc_reg (.clk(clk), .rst(rst), .next_pc(PC_Next), .current_pc(PC_IF));
    instruction_memory i_mem (.address(PC_IF), .instruction(Instruction_IF));
    
    //=============== IF/ID REGISTER ===============//
    if_id_register if_id_reg (
        .clk(clk), .rst(rst), .IF_ID_Write(IF_ID_Write), .IF_ID_Flush(PCSrc),
        .PC_IF(PC_Plus4_IF), .Instruction_IF(Instruction_IF),
        .PC_ID(PC_ID), .Instruction_ID(Instruction_ID)
    );

    //=============== ID STAGE ===============//
    control_unit ctrl (
        .opcode(Instruction_ID[31:26]), .RegDst(RegDst_ID), .ALUSrc(ALUSrc_ID), .MemtoReg(MemtoReg_ID),
        .RegWrite(RegWrite_ID), .MemRead(MemRead_ID), .MemWrite(MemWrite_ID), .Branch(Branch_ID), 
        .ALUOp1(ALUOp_ID[1]), .ALUOp0(ALUOp_ID[0]), .Jump(Jump_ID)
    );
    register_file reg_file (
        .clk(clk), .RegWrite(RegWrite_WB), .ReadRegister1(Instruction_ID[25:21]),
        .ReadRegister2(Instruction_ID[20:16]), .WriteRegister(WriteReg_WB),
        .WriteData(WriteData_WB), .ReadData1(ReadData1_ID), .ReadData2(ReadData2_ID)
    );
    assign SignExtended_ID = {{16{Instruction_ID[15]}}, Instruction_ID[15:0]};

    //=============== ID/EX REGISTER ===============//
    id_ex_register id_ex_reg (
        .clk(clk), .rst(rst), .ID_EX_Flush(ID_EX_Flush), .RegWrite_ID(RegWrite_ID), .MemtoReg_ID(MemtoReg_ID), 
        .MemRead_ID(MemRead_ID), .MemWrite_ID(MemWrite_ID), .ALUOp_ID(ALUOp_ID), .ALUSrc_ID(ALUSrc_ID), 
        .RegDst_ID(RegDst_ID), .PC_ID(PC_ID), .ReadData1_ID(ReadData1_ID), .ReadData2_ID(ReadData2_ID),
        .SignExtended_ID(SignExtended_ID), .Rs_ID(Instruction_ID[25:21]), .Rt_ID(Instruction_ID[20:16]), .Rd_ID(Instruction_ID[15:11]),
        .RegWrite_EX(RegWrite_EX), .MemtoReg_EX(MemtoReg_EX), .MemRead_EX(MemRead_EX),
        .MemWrite_EX(MemWrite_EX), .ALUOp_EX(ALUOp_EX), .ALUSrc_EX(ALUSrc_EX), .RegDst_EX(RegDst_EX),
        .PC_EX(PC_EX), .ReadData1_EX(ReadData1_EX), .ReadData2_EX(ReadData2_EX), .SignExtended_EX(SignExtended_EX), 
        .Rs_EX(Rs_EX), .Rt_EX(Rt_EX), .Rd_EX(Rd_EX)
    );

    //=============== EX STAGE ===============//
    assign ALUInputA = (ForwardA == 2'b10) ? WriteData_WB : (ForwardA == 2'b01) ? ALUResult_MEM : ReadData1_EX;
    assign ALUInputB = (ForwardB == 2'b10) ? WriteData_WB : (ForwardB == 2'b01) ? ALUResult_MEM : ReadData2_EX;
    wire [31:0] alu_op_b_mux = ALUSrc_EX ? SignExtended_EX : ALUInputB;
    // Simple ALU control, needs a dedicated decoder in a full design
    wire [3:0] alu_ctrl_EX = (ALUOp_EX == 2'b10) ? 4'b0010 : (ALUOp_EX == 2'b01) ? 4'b0110 : 4'b0010;
    alu alu_inst (
        .A(ALUInputA), .B(alu_op_b_mux), .ALUControl(alu_ctrl_EX), .Result(ALUResult_EX), .Zero(Zero_EX)
    );
    assign WriteReg_EX = RegDst_EX ? Rd_EX : Rt_EX;
    
    //=============== EX/MEM REGISTER ===============//
    ex_mem_register ex_mem_reg (
        .clk(clk), .rst(rst), .RegWrite_EX(RegWrite_EX), .MemtoReg_EX(MemtoReg_EX), .MemRead_EX(MemRead_EX),
        .MemWrite_EX(MemWrite_EX), .Branch_EX(Branch_ID), .ALUResult_EX(ALUResult_EX), .ReadData2_EX(ALUInputB), // Forwarded data for SW
        .WriteReg_EX(WriteReg_EX), .Zero_EX(Zero_EX), .RegWrite_MEM(RegWrite_MEM), .MemtoReg_MEM(MemtoReg_MEM),
        .MemRead_MEM(MemRead_MEM), .MemWrite_MEM(MemWrite_MEM), .Branch_MEM(Branch_MEM), .ALUResult_MEM(ALUResult_MEM),
        .StoreData_MEM(StoreData_MEM), .WriteReg_MEM(WriteReg_MEM), .Zero_MEM(Zero_MEM)
    );

    //=============== MEM STAGE ===============//
    data_memory d_mem (
        .clk(clk), .MemRead(MemRead_MEM), .MemWrite(MemWrite_MEM), .address(ALUResult_MEM),
        .WriteData(StoreData_MEM), .ReadData(ReadData_MEM)
    );

    //=============== MEM/WB REGISTER ===============//
    mem_wb_register mem_wb_reg (
        .clk(clk), .rst(rst), .RegWrite_MEM(RegWrite_MEM), .MemtoReg_MEM(MemtoReg_MEM), 
        .ReadData_MEM(ReadData_MEM), .ALUResult_MEM(ALUResult_MEM), .WriteReg_MEM(WriteReg_MEM),
        .RegWrite_WB(RegWrite_WB), .MemtoReg_WB(MemtoReg_WB), .ReadData_WB(ReadData_WB),
        .ALUResult_WB(ALUResult_WB), .WriteReg_WB(WriteReg_WB)
    );

    //=============== WB STAGE ===============//
    assign WriteData_WB = MemtoReg_WB ? ReadData_WB : ALUResult_WB;

    //=============== HAZARD & FORWARDING UNITS ===============//
    hazard_detection_unit hazard_unit (
        .Rs_ID(Instruction_ID[25:21]), .Rt_ID(Instruction_ID[20:16]), .MemRead_EX(MemRead_EX),
        .Rt_EX(Rt_EX), .Branch_ID(Branch_ID), .Jump_ID(Jump_ID), .PCWrite(PCWrite), 
        .IF_ID_Write(IF_ID_Write), .ID_EX_Flush(ID_EX_Flush)
    );
    forwarding_unit forward_unit (
        .RegWrite_MEM(RegWrite_MEM), .RegWrite_WB(RegWrite_WB), .Rs_EX(Rs_EX), .Rt_EX(Rt_EX),
        .WriteReg_MEM(WriteReg_MEM), .WriteReg_WB(WriteReg_WB), .ForwardA(ForwardA), .ForwardB(ForwardB)
    );
endmodule