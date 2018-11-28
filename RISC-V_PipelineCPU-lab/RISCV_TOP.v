module RISCV_TOP (
	//General Signals
	input wire CLK,
	input wire RSTn,

	//I-Memory Signals
	output wire I_MEM_CSN,
	input wire [31:0] I_MEM_DI,//input from IM
	output reg [11:0] I_MEM_ADDR,//in byte address

	//D-Memory Signals
	output wire D_MEM_CSN,
	input wire [31:0] D_MEM_DI,
	output wire [31:0] D_MEM_DOUT,
	output wire [11:0] D_MEM_ADDR,//in word address
	output wire D_MEM_WEN,
	output wire [3:0] D_MEM_BE,

	//RegFile Signals
	output wire RF_WE,
	output wire [4:0] RF_RA1,
	output wire [4:0] RF_RA2,
	output wire [4:0] RF_WA1,
	input wire [31:0] RF_RD1,
	input wire [31:0] RF_RD2,
	output wire [31:0] RF_WD,
	output wire HALT,
	output reg [31:0] NUM_INST,
	output wire [31:0] OUTPUT_PORT
	);

	/* ---- instantiate modules ---- */
	wire [6:0] ALUOp;
	wire [2:0] Concat_control;
	wire [3:0] BE;
	Control control(
		.CLK(CLK), //input
		.opcode(I_MEM_DI[6:0]),
		.funct3(I_MEM_DI[14:12]),
		.RSTn(RSTn),
   		.RegDst(RegDst),       //output
   		.Jump(Jump),
		.Branch(Branch),
   		.MemRead(MemRead),// Always set to 1
   		.MemtoReg(MemtoReg),
   		.ALUOp(ALUOp),
   		.MemWrite(MemWrite),
   		.ALUSrc1(ALUSrc1),
		.ALUSrc2(ALUSrc2),
   		.RegWrite(RegWrite),
		.JALorJALR(JALorJALR),
		.BE(BE),
		.Concat_control(Concat_control),
		.PCWrite(PCWrite)
   		);

	wire [4:0] ALU_operation;
	ALUControl alucontrol(
		.ALUOp(ALUOp),   // input
 		.funct3(I_MEM_DI[14:12]),
		.funct7(I_MEM_DI[31:25]),
		.ALU_operation(ALU_operation) // output
   		);
	
	wire [31:0] offset;
	Immediate_Concatenator Im_con(
		.Instr(I_MEM_DI),     //input
		.Concat_control(Concat_control), 
		.offset(offset)   //output
		);

	//Instruction Memory Output
	wire [31:0] JAL_Address;
	wire [31:0] JALR_Address;
	wire [31:0] Branch_Target;
	reg [31:0] PC;
	wire [31:0] NXT_PC;
	wire Branch_Taken;
	
	//instantiate ALU module
	wire [31:0] ALU_Result;
	ALU alu(
		.Operand1( (ALUSrc1) ? PC : RF_RD1),    //input
		.Operand2( (ALUSrc2) ? offset : RF_RD2 ), 
		.ALU_operation(ALU_operation), 
		.Zero(Zero),    //output
		.ALU_Result(ALU_Result)  
		);
	/* ---------------- */

	/* --- for testbench --- */
	assign OUTPUT_PORT = (Branch) ? Branch_Taken : (MemWrite)? ALU_Result : RF_WD;

	initial begin
		NUM_INST <= 0;
	end

	// Only allow for NUM_INST
	always @ (negedge CLK) begin
		if (RSTn && PCWrite) NUM_INST <= NUM_INST + 1;
	end
	/* ---------------- */

	assign JAL_Address = ALU_Result;
	assign JALR_Address = ALU_Result & (32'hfffffffe);
	assign Branch_Target = offset + PC;
	assign Branch_Taken = Branch & Zero;
	assign I_MEM_CSN = (~RSTn)? 1'b1 : 1'b0;

	// PC update
	assign NXT_PC = (~RSTn)? 0 : (Jump)? ( (JALorJALR)? JALR_Address : JAL_Address ) : ((Branch_Taken)? Branch_Target : PC+4 );

	always @(posedge CLK) begin
		if (~RSTn) begin
			PC = 0;
			I_MEM_ADDR = 0;
		end
		else if (PCWrite) begin
			PC = NXT_PC;
			I_MEM_ADDR = NXT_PC[11:0];
		end
	end


	//Data Memory Output
	wire [31:0] temp_ALU_Result = ALU_Result;

	assign D_MEM_CSN = (~RSTn)? 1'b1 : 1'b0;
	assign D_MEM_DOUT = RF_RD2;
	assign D_MEM_ADDR = temp_ALU_Result[13:2]; 
	assign D_MEM_WEN = ~MemWrite;
	assign D_MEM_BE = BE;

	//Register File Output
	assign RF_WE = RegWrite;
	assign RF_RA1 = I_MEM_DI[19:15];
	assign RF_RA2 = I_MEM_DI[24:20];
	assign RF_WA1 = (RegDst) ? I_MEM_DI[11:7] : I_MEM_DI[24:20];
	assign RF_WD = (Jump) ? PC+4 : (MemtoReg) ? D_MEM_DI : ALU_Result;


	//Check two sequence of instructions for HALT
	assign HALT = (RF_RD1 == 32'h0000000c) && (I_MEM_DI == 32'h00008067);	
	
	

endmodule