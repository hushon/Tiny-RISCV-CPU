module Control (
	input wire [6:0] opcode,
	input wire [2:0] funct3,

	output reg RegDst,
	output reg Jump,
	output reg Branch,
	output reg MemRead,
	output reg MemtoReg,
	output reg [6:0] ALUOp,
	output reg MemWrite,
	output reg ALUSrc1,
	output reg [1:0] ALUSrc2,
	output reg RegWrite,
	output reg JALorJALR,
	output reg [3:0] BE,
	output reg [2:0] Concat_control,
	output reg use_rs1_id,
	output reg use_rs2_id
	);

	always @(*) begin
		if (opcode == 7'b0110111) begin // isLUI
			RegDst=1;
			Jump=0;
			Branch=0;
			MemRead=0;
			MemtoReg=0;
			ALUOp=opcode;
			MemWrite=0;
			ALUSrc1=1'bx;
			ALUSrc2=2'b01;
			RegWrite=1;
			JALorJALR=1'bx;
			BE=4'bxxxx;
			Concat_control=3'b001;
			use_rs1_id = 0;
			use_rs2_id = 0;
		end
		else if (opcode == 7'b0010111) begin // isAUIPC
			RegDst=1;
			Jump=0;
			Branch=0;
			MemRead=0;
			MemtoReg=0;
			ALUOp=opcode;
			MemWrite=0;
			ALUSrc1=1;
			ALUSrc2=2'b01;
			RegWrite=1;
			JALorJALR=1'bx;
			BE=4'bxxxx;
			Concat_control=3'b001;
			use_rs1_id = 0;
			use_rs2_id = 0;
		end
		else if (opcode == 7'b0110011) begin // isRtype
			RegDst=1;
			Jump=0;
			Branch=0;
			MemRead=0;
			MemtoReg=0;
			ALUOp=opcode;
			MemWrite=0;
			ALUSrc1=0;
			ALUSrc2=2'b00;
			RegWrite=1;
			JALorJALR=1'bx;
			BE=4'bxxxx;
			Concat_control=3'b000;
			use_rs1_id = 1;
			use_rs2_id = 1;
		end
		else if (opcode == 7'b0010011) begin // isItype
			RegDst=1;
			Jump=0;
			Branch=0;
			MemRead=0;
			MemtoReg=0;
			ALUOp=opcode;
			MemWrite=0;
			ALUSrc1=0;
			ALUSrc2=2'b01;
			RegWrite=1;
			JALorJALR=1'bx;
			BE=4'bxxxx;
			if(funct3 == 3'b001 || funct3 == 3'b101) Concat_control=3'b110; // SLLI or SRLI or SRAI
			else Concat_control=3'b011;
			use_rs1_id = 1;
			use_rs2_id = 0;
		end
		else if (opcode == 7'b0000011) begin // isLW
			RegDst=1;
			Jump=0;
			Branch=0;
			MemRead=1;
			MemtoReg=1;
			ALUOp=opcode;
			MemWrite=0;
			ALUSrc1=0;
			ALUSrc2=2'b01;
			RegWrite=1;
			JALorJALR=1'bx;
			case (funct3)
				3'b000, 3'b100: BE=4'b0001; // LB or LBU
				3'b001, 3'b101: BE=4'b0011; // LH or LHU
				3'b010: BE=4'b1111; // LW
				default: ; 
			endcase
			Concat_control=3'b011;
			use_rs1_id = 1;
			use_rs2_id = 0;
		end
		else if (opcode == 7'b0100011) begin // isSW
			RegDst=1'bx; // don't care
			Jump=0;
			Branch=0;
			MemRead=1;
			MemtoReg=1'bx;
			ALUOp=opcode;
			MemWrite=1;
			ALUSrc1=0;
			ALUSrc2=2'b01;
			RegWrite=0;
			JALorJALR=1'bx;
			case (funct3)
				3'b000: BE=4'b0001; // SB
				3'b001: BE=4'b0011; // SH
				3'b010: BE=4'b1111; // SW
				default: ; 
			endcase
			Concat_control=3'b101;
			use_rs1_id = 1;
			use_rs2_id = 0;
		end
		else if (opcode == 7'b1100011) begin // isBranch
			RegDst=1'bx;
			Jump=0;
			Branch=1;
			MemRead=0;
			MemtoReg=1'bx;
			ALUOp=opcode;
			MemWrite=0;
			ALUSrc1=0;
			ALUSrc2=2'b00;
			RegWrite=0;
			JALorJALR=1'bx;
			BE=4'bxxxx;
			Concat_control=3'b100;
			use_rs1_id = 1;
			use_rs2_id = 1;
		end
		else if (opcode == 7'b1101111) begin // isJAL
			RegDst=1;
			Jump=1;
			Branch=0;
			MemRead=0;
			MemtoReg=1'b0;
			ALUOp=opcode;
			MemWrite=0;
			ALUSrc1=1;
			ALUSrc2=2'b10;
			RegWrite=1;
			JALorJALR=0;
			BE=4'bxxxx;
			Concat_control=3'b010;
			use_rs1_id = 0;
			use_rs2_id = 0;
		end
		else if (opcode == 7'b1100111) begin // isJALR
			RegDst=1;
			Jump=1;
			Branch=0;
			MemRead=0;
			MemtoReg=1'b0;
			ALUOp=opcode;
			MemWrite=0;
			ALUSrc1=1;
			ALUSrc2=2'b10;
			RegWrite=1;
			JALorJALR=1;
			BE=4'bxxxx;
			Concat_control=3'b011;
			use_rs1_id = 1;
			use_rs2_id = 0;
		end
		else begin // when opcode does not belong to any case
			RegDst=1'bx;
			Jump=1'b0;
			Branch=1'bx;
			MemRead=1'bx;
			MemtoReg=1'bx;
			ALUOp=7'bxxxxxxx;
			MemWrite=1'bx;
			ALUSrc2=1'bxx;
			RegWrite=1'bx;
			BE=4'bxxxx;
			Concat_control=3'b000;
			use_rs1_id = 1'bx;
			use_rs2_id = 1'bx;
		end
	end
endmodule