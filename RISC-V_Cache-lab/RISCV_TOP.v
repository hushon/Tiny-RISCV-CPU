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
	output wire HALT,                   // if set, terminate program
	output reg [31:0] NUM_INST,         // number of instruction completed
	output wire [31:0] OUTPUT_PORT      // equal RF_WD this port is used for test
	);

	//Declare and initialize pipeline register
	reg [200:0] if_id_reg;
	reg [200:0] id_ex_reg;
	reg [200:0] ex_mem_reg;
	reg [200:0] mem_wb_reg;

	initial begin
		if_id_reg <=0;
		id_ex_reg <=0;
		ex_mem_reg <=0;
		mem_wb_reg <=0;
	end

	//Declare id stage variables
	wire [31:0] Inst;
	wire [4:0] rs1_id;
	wire [4:0] rs2_id;
	wire [4:0] rd_id;
	wire [31:0] branch_forward_dataA;
	wire [31:0] branch_forward_dataB;

	//Declare ex stage variables
	wire [4:0] rs1_ex;
	wire [4:0] rs2_ex;
	wire [4:0] rd_ex;
	wire MemRead_ex;

	//Declare mem stage variables
	wire [4:0] rd_mem;
	wire RegWrite_mem;

	//Declare wb stage variables
	wire [4:0] rd_wb;
	wire RegWrite_wb;

	/* ---- instantiate modules ---- */
	Hazard_detect hazarddetect(
		.rd_ex(rd_ex),  //input
		.MemRead_ex(MemRead_ex),
		.rs1_id(rs1_id),
		.rs2_id(rs2_id), 
		.use_rs1_id(use_rs1_id),
		.use_rs2_id(use_rs2_id),
		.load_delay(load_delay),   //output
		.PCWrite(PCWrite),
		.IF_ID_Write(IF_ID_Write)
		);

	wire [1:0] forwardA;
	wire [1:0] forwardB;
	wire [1:0] writedatasel;
	wire [1:0] branch_forwardA;
	wire [1:0] branch_forwardB;
	Forwarding forwarding(
		.rd_ex(rd_ex), // input
		.rd_mem(rd_mem),   
		.rd_wb(rd_wb),
		.RegWrite_wb(RegWrite_wb),
		.RegWrite_mem(RegWrite_mem),
		.rs1_id(rs1_id),
		.rs2_id(rs2_id),
		.rs1_ex(rs1_ex),
		.rs2_ex(rs2_ex),
		.use_rs1_ex(id_ex_reg[155]),
		.use_rs2_ex(id_ex_reg[156]),
		.opcode_id(Inst[6:0]),
		.opcode_ex(id_ex_reg[195:189]),
		.opcode_mem(ex_mem_reg[195:189]),
		.opcode_wb(mem_wb_reg[195:189]),
		.forwardA(forwardA),   //output
		.forwardB(forwardB),
		.writedatasel(writedatasel),
		.branch_forwardA(branch_forwardA),
		.branch_forwardB(branch_forwardB)
		);

	wire [6:0] ALUOp;
	wire [2:0] Concat_control;
	wire [3:0] BE;
	wire [1:0] ALUSrc2;
	Control control(
		.opcode(Inst[6:0]), // input
		.funct3(Inst[14:12]),
   		.RegDst(RegDst),       //output
   		.Jump(Jump),
		.Branch(Branch),
   		.MemRead(MemRead),
   		.MemtoReg(MemtoReg),
   		.ALUOp(ALUOp),
   		.MemWrite(MemWrite),
   		.ALUSrc1(ALUSrc1),
		.ALUSrc2(ALUSrc2),
   		.RegWrite(RegWrite),
		.JALorJALR(JALorJALR),
		.BE(BE),
		.Concat_control(Concat_control),
		.use_rs1_id(use_rs1_id),
		.use_rs2_id(use_rs2_id)
   		);

	wire [4:0] ALU_operation;
	ALUControl alucontrol(
		.ALUOp(ALUOp),   // input
 		.funct3(Inst[14:12]),
		.funct7(Inst[31:25]),
		.ALU_operation(ALU_operation) // output
   		);
	
	wire [31:0] offset;
	Immediate_Concatenator Im_con(
		.Instr(Inst),     //input
		.Concat_control(Concat_control), 
		.offset(offset)   //output
		);
	/* ---- end instantiate modules ---- */

	/* --- for testbench --- */
	reg [31:0] cycle;  /// for test erase later 
	initial begin
		NUM_INST <= 0;
		cycle <= 0; /// for test erase later 
	end

	// Only allow for NUM_INST
	always @ (negedge CLK) begin
		if (RSTn && mem_wb_reg[196]) NUM_INST <= NUM_INST + mem_wb_reg[200];
		if (RSTn) cycle <= cycle + 1;
	end
	/* --- end for testbench --- */	

	// TODO: implement

	//Instruction Memory Output
	wire [31:0] JAL_Address;
	wire [31:0] JALR_Address;
	wire [31:0] Branch_Target;
	reg [31:0] PC;
	wire [31:0] NXT_PC;
	wire Branch_Taken;
	
	
	//instantiate ALU module
	wire [31:0] ALU_Result;
	ALU alu(                                           // ALU_Result         
		.Operand1( (forwardA == 2'b10)? RF_WD:(forwardA == 2'b01)? ex_mem_reg[35:4] : (id_ex_reg[9])? id_ex_reg[43:12]:id_ex_reg[107:76] ), 
		          // (forwardA== 2'b1-)? RF_WD :(forwardA == 2'b01)?       ALU_Result : (ALUsr1) ? PC : read data1
		.Operand2( (forwardB == 2'b10)? RF_WD:(forwardB == 2'b01)? ex_mem_reg[35:4] :(id_ex_reg[11:10] == 2'b10)? 4 : (id_ex_reg[11:10] == 2'b01)? id_ex_reg[139:108] :id_ex_reg[75:44] ),         
		          // (forwardB == 2'b10)? RF_WD :(forwardB == 2'b01)? ALU_Result : (ALUsr2= 2'b10) ? 4 : (ALUsr2=2'b01)? offset : read data2
		.ALU_operation(id_ex_reg[8:4]), 
		.Zero(trash1),    //output
		// not use this zero
		.ALU_Result(ALU_Result)  
		);

	wire [31:0] trash2; // not use this variable
	ALU branch_op(
		.Operand1(branch_forward_dataA),    //input
		.Operand2(branch_forward_dataB), 
		.ALU_operation(ALU_operation), 
		.Zero(Zero),    //output
		.ALU_Result(trash2)  
		);

	//PC update
	assign JAL_Address = if_id_reg[31:0] + offset; // PC + offset
	assign JALR_Address = (branch_forward_dataA + offset)& (32'hfffffffe);
	assign Branch_Target = if_id_reg[31:0] + offset; // PC + offset
	assign Branch_Taken = Branch & Zero;
	assign id_flush = Branch_Taken|Jump; //id_flush signal
	assign NXT_PC = (~RSTn)? 0 : (Jump)? ( (JALorJALR)? JALR_Address : JAL_Address ) : ((Branch_Taken)? Branch_Target : PC+4 );
	
	always @(posedge CLK) begin
		if (~RSTn) begin
			PC <= 0;
			I_MEM_ADDR <= 0;
		end
		if (PCWrite) begin
			PC <= NXT_PC;
			I_MEM_ADDR <= NXT_PC[11:0];
		end
	end
	assign I_MEM_CSN = (~RSTn)? 1'b1 : 1'b0;

	//Branch forwarding data 
	assign branch_forward_dataA = (branch_forwardA==2'b11)? D_MEM_DI:(branch_forwardA==2'b10)? ex_mem_reg[35:4]:(branch_forwardA==2'b01)? ALU_Result:RF_RD1; 
	assign branch_forward_dataB = (branch_forwardB==2'b11)? D_MEM_DI:(branch_forwardB==2'b10)? ex_mem_reg[35:4]:(branch_forwardB==2'b01)? ALU_Result:RF_RD2;

	//Data Memory Output
	assign D_MEM_CSN = (~RSTn)? 1'b1 : ~ex_mem_reg[2]; //(RST)? 1 : ~MemRead
	assign D_MEM_DOUT = ex_mem_reg[67:36]; // RF_RD2
	assign D_MEM_ADDR = ex_mem_reg[17:6];  //ALU_Result[13:2]
	assign D_MEM_WEN = ~ex_mem_reg[3];
	assign D_MEM_BE = 4'b1111;

	//Register File Output
	assign RF_WE = RegWrite_wb;
	assign RF_RA1 = Inst[19:15];
	assign RF_RA2 = Inst[24:20];
	assign RF_WA1 = rd_wb;
	assign RF_WD = (mem_wb_reg[1]) ? mem_wb_reg[33:2]: mem_wb_reg[65:34]; //(MemtoReg)? D_MEM_DI : ALU_Result


	//pipeline register update
	always @(posedge CLK) begin
		//update IF/ID Register
		if (~RSTn) begin
			if_id_reg <=0;
			id_ex_reg <=0;
			ex_mem_reg <=0;
			mem_wb_reg <=0;
		end
		else begin 
			if (IF_ID_Write) begin
				if (~id_flush) begin
					if_id_reg[31:0]<=PC;
					if_id_reg[63:32]<=I_MEM_DI;
					if_id_reg[200]<=1;  //for num_inst
				end
			
				else begin
					if_id_reg <= 0;
				end
			end
			//update ID/EX Register
			id_ex_reg[11:0] <= (load_delay)? 0 : {ALUSrc2,ALUSrc1,ALU_operation,MemWrite,MemRead,MemtoReg,RegWrite}; // control signals
			id_ex_reg[43:12] <= if_id_reg[31:0]; // PC
			id_ex_reg[107:44] <= {branch_forward_dataA,branch_forward_dataB}; // Register Data
			id_ex_reg[139:108] <= offset;  //offset
			id_ex_reg[154:140] <={rs1_id, rs2_id,rd_id}; //register 
			id_ex_reg[156:155] <= {use_rs2_id, use_rs1_id}; // use_rs2_id, use_rs1_id  from control unit

			id_ex_reg[200] <= if_id_reg[200]; //for num_inst
			id_ex_reg[199:197] <= {Branch ,Branch_Taken, MemWrite}; // for output port
			id_ex_reg[196] <= PCWrite; // for num_inst
			id_ex_reg[195:189] <= Inst[6:0]; // for data forwarding unit, Opcode(Inst) -> opcode_ex



			//update EX/MEM Register
			ex_mem_reg[3:0] <= id_ex_reg[3:0]; //control signals
			ex_mem_reg[35:4] <=ALU_Result;
			ex_mem_reg[67:36] <= (writedatasel==2'b11)? RF_WD : (writedatasel==2'b10)?  D_MEM_DI : (writedatasel==2'b01)? ex_mem_reg[35:4] : id_ex_reg[75:44]; 
							// writedatasel = 3 : RF_WD ,writedatasel = 2 : D_OUT(Data out from memory) 
							// writedatasel = 1 : ALU_result(after pipeline) ,writedatasel = 0 : RF_RD2
			ex_mem_reg[72:68] <= rd_ex;
			ex_mem_reg[74:73] <= id_ex_reg[156:155]; // use_rs2_ex, use_rs1_ex from control unit

			ex_mem_reg[200] <= id_ex_reg[200]; //for num_inst 
			ex_mem_reg[199:197] <=id_ex_reg[199:197]; // for output port
			ex_mem_reg[196] <= id_ex_reg[196]; // for num_inst
			ex_mem_reg[195:189]<= id_ex_reg[195:189]; // for data forwarding unit, opcode_ex -> opcode_mem



			//update MEM/WB Register
			mem_wb_reg[1:0] <= ex_mem_reg[1:0]; // control signals
			mem_wb_reg[33:2] <= D_MEM_DI;
			mem_wb_reg[65:34] <= ex_mem_reg[35:4]; // ALU_Result
			mem_wb_reg[70:66] <= rd_mem;
			mem_wb_reg[72:71] <= ex_mem_reg[74:73]; // use_rs2_mem, use_rs1_mem from control unit

			mem_wb_reg[200] <= ex_mem_reg[200]; //for num_inst
			mem_wb_reg[199:197] <= ex_mem_reg[199:197]; // for output port
			mem_wb_reg[196] <= ex_mem_reg[196]; // for num_inst
			mem_wb_reg[195:189] <=ex_mem_reg[195:189]; // for data forwarding unit, opcode_mem -> opcode_wb
		end
	end

	//Assign ID stage variables
	assign Inst = if_id_reg[63:32];
	assign rs1_id = Inst[19:15];
	assign rs2_id = Inst[24:20];
	assign rd_id = (RegDst)? Inst[11:7] :Inst[24:20];

	//Assign EX stage variables
	assign rs1_ex = id_ex_reg[154:150];
	assign rs2_ex = id_ex_reg[149:145];
	assign rd_ex = id_ex_reg[144:140];
	assign MemRead_ex = id_ex_reg[2];

	//Assign Mem stage variables
	assign rd_mem = ex_mem_reg[72:68];
	assign RegWrite_mem = ex_mem_reg[0];
	
	//Assign WB stage variables
	assign rd_wb = mem_wb_reg[70:66];
	assign RegWrite_wb = mem_wb_reg[0];


	//Check two sequence of instructions for HALT
	assign HALT = ((RF_RD1 == 32'h0000000c) && (Inst== 32'h00008067)) || (cycle == 6996);	
	
	assign OUTPUT_PORT = (mem_wb_reg[199]) ? mem_wb_reg[198] : (mem_wb_reg[197])? mem_wb_reg[65:34] : RF_WD; 
                       // (Branch) ? Branch_Taken : (MemWrite)? ALU_Result : RF_WD; 

endmodule //
