module ALUControl (
	input wire [6:0] ALUOp, 
	input wire [2:0] funct3,
	input wire [6:0] funct7,

	output reg [4:0] ALU_operation
	);

	always @(*) begin
		if (ALUOp == 7'b0110111 || ALUOp == 7'b0010111) begin // isUtype
			if (ALUOp == 7'b0110111) ALU_operation = 5'b01000; // LUI
			else if (ALUOp == 7'b0010111) ALU_operation = 5'b00000; // AUIPC
		end
		else if (ALUOp == 7'b0110011) begin // isRtype
			if (funct3 == 3'b000 && funct7 == 7'b0000000) ALU_operation = 5'b00000; // ADD
			else if (funct3 == 3'b000 && funct7 == 7'b0100000) ALU_operation = 5'b00001; // SUB
			else if (funct3 == 3'b001) ALU_operation = 5'b01101; // SLL
			else if (funct3 == 3'b010) ALU_operation = 5'b10110; // SLT
			else if (funct3 == 3'b011) ALU_operation = 5'b10111; // SLTU
			else if (funct3 == 3'b100) ALU_operation = 5'b00110; // XOR
			else if (funct3 == 3'b101 && funct7 == 7'b0000000) ALU_operation = 5'b01010; // SRL
			else if (funct3 == 3'b101 && funct7 == 7'b0100000) ALU_operation = 5'b01011; // SRA
			else if (funct3 == 3'b110) ALU_operation = 5'b00011; // OR
			else if (funct3 == 3'b111) ALU_operation = 5'b00010; // AND
		end
		else if (ALUOp == 7'b0010011) begin // isItype
			if (funct3 == 3'b000) ALU_operation = 5'b00000; // ADDI 16-bit signed addition
			else if (funct3 == 3'b010) ALU_operation = 5'b10110; // SLTI
			else if (funct3 == 3'b011) ALU_operation = 5'b10111; // SLTIU
			else if (funct3 == 3'b100) ALU_operation = 5'b00110; // XORI
			else if (funct3 == 3'b110) ALU_operation = 5'b00011; // ORI
			else if (funct3 == 3'b111) ALU_operation = 5'b00010; // ANDI
			else if (funct3 == 3'b001) ALU_operation = 5'b01101; // SLLI
			else if (funct3 == 3'b101 && funct7 == 7'b0000000) ALU_operation = 5'b01010; // SRLI
			else if (funct3 == 3'b101 && funct7 == 7'b0100000) ALU_operation = 5'b01011; // SRAI
		end
		else if (ALUOp == 7'b0000011) begin // isLW
			if (funct3 == 3'b000) ALU_operation = 5'b00000; // LB
			else if (funct3 == 3'b001) ALU_operation = 5'b00000; // LH
			else if (funct3 == 3'b010) ALU_operation = 5'b00000; // LW
			else if (funct3 == 3'b100) ALU_operation = 5'b00000; // LBU
			else if (funct3 == 3'b101) ALU_operation = 5'b00000; // LHU
		end
		else if (ALUOp == 7'b0100011) begin // isSW
			if (funct3 == 3'b000) ALU_operation = 5'b00000; // SB
			else if (funct3 == 3'b001) ALU_operation = 5'b00000; // SH
			else if (funct3 == 3'b010) ALU_operation = 5'b00000; // SW
		end
		else if (ALUOp == 7'b1100011) begin // isBranch
			if (funct3 == 3'b000) ALU_operation = 5'b10000; // BEQ
			else if (funct3 == 3'b001) ALU_operation = 5'b10001; // BNE
			else if (funct3 == 3'b100) ALU_operation = 5'b10010; // BLT
			else if (funct3 == 3'b101) ALU_operation = 5'b10011; // BGE
			else if (funct3 == 3'b110) ALU_operation = 5'b10100; // BLTU
			else if (funct3 == 3'b111) ALU_operation = 5'b10101; // BGEU
		end
		else if (ALUOp == 7'b1101111 || ALUOp == 7'b1100111) begin // isJump
			if (ALUOp == 7'b1101111) ALU_operation = 5'b00000; // JAL
			else if (ALUOp == 7'b1100111) ALU_operation = 5'b00000; // JALR
		end
		else begin // when ALUOp does not belong to any case
			ALU_operation = 5'bxxxxx;
		end
	end
endmodule