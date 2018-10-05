module Control (
	input wire [6:0] opcode,

	output reg RegDst,
	output reg Jump,
	output reg Branch,
	output reg MemRead,
	output reg MemtoReg,
	output reg [6:0] ALUOp,
	output reg MemWrite,
	output reg ALUSrc1,
	output reg ALUSrc2,
	output reg RegWrite,
	output reg JALorJALR
	);

	always @(*) begin
		if (opcode == 7'b0110111) begin // isLUI
			// needs implemention in datapath
			// needs to re-check
			RegDst=1;
			Jump=0;
			Branch=0;
			MemRead=0;
			MemtoReg=0;
			ALUOp=opcode;
			MemWrite=0;
			ALUSrc1=0;
			ALUSrc2=1'bx;
			RegWrite=1;
			JALorJALR=1'bx;
		end
		if (opcode == 7'b0010111) begin // isAUIPC
			// needs implementation in datapath
			// needs to re-check
			RegDst=1;
			Jump=1;
			Branch=0;
			MemRead=0;
			MemtoReg=0;
			ALUOp=opcode;
			MemWrite=0;
			ALUSrc1=0;
			ALUSrc2=1'bx;
			RegWrite=1;
			JALorJALR=1'bx;
		end
		if (opcode == 7'b0110011) begin // isRtype
			RegDst=1;
			Jump=0;
			Branch=0;
			MemRead=0;
			MemtoReg=0;
			ALUOp=opcode;
			MemWrite=0;
			ALUSrc1=0;
			ALUSrc2=0;
			RegWrite=1;
			JALorJALR=1'bx;
		end
		else if (opcode == 7'b0010011) begin // isItype
			RegDst=0;
			Jump=0;
			Branch=0;
			MemRead=0;
			MemtoReg=0;
			ALUOp=opcode;
			MemWrite=0;
			ALUSrc1=0;
			ALUSrc2=1;
			RegWrite=1;
			JALorJALR=1'bx;
		end
		else if (opcode == 7'b0000011) begin // isLW
			RegDst=0;
			Jump=0;
			Branch=0;
			MemRead=1;
			MemtoReg=1;
			ALUOp=opcode;
			MemWrite=0;
			ALUSrc1=0;
			ALUSrc2=1;
			RegWrite=1;
			JALorJALR=1'bx;
		end
		else if (opcode == 7'b0100011) begin // isSW
			RegDst=1'bx; // don't care
			Jump=0;
			Branch=0;
			MemRead=0;
			MemtoReg=1'bx;
			ALUOp=opcode;
			MemWrite=1;
			ALUSrc1=0;
			ALUSrc2=1;
			RegWrite=0;
			JALorJALR=1'bx;
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
			ALUSrc2=0;
			RegWrite=0;
			JALorJALR=1'bx;
		end
		else if (opcode == 7'b1101111) begin // isJAL
			RegDst=1;
			Jump=1;
			Branch=0;
			MemRead=0;
			MemtoReg=1'bx;
			ALUOp=opcode;
			MemWrite=0;
			ALUSrc1=0;
			ALUSrc2=1;
			RegWrite=1;
			JALorJALR=0;
		end
		else if (opcode == 7'b1100111) begin // isJALR
			RegDst=1;
			Jump=1;
			Branch=0;
			MemRead=0;
			MemtoReg=1'bx;
			ALUOp=opcode;
			MemWrite=0;
			ALUSrc1=0;
			ALUSrc2=1;
			RegWrite=1;
			JALorJALR=1;
		end
		else begin // when opcode does not belong to any case
			$display("No vaild instruction"); 
			RegDst=1'bx;
			Jump=1'bx;
			Branch=1'bx;
			MemRead=1'bx;
			MemtoReg=1'bx;
			ALUOp=7'bxxxxxxx;
			MemWrite=1'bx;
			ALUSrc2=1'bx;
			RegWrite=1'bx;
		end
	end
endmodule