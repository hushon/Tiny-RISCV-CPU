`timescale 1ns / 100ps

module ALU(A,B,OP,C,Cout);

	input [15:0]A;
	input [15:0]B;
	input [3:0]OP;
	output [15:0]C;
	output Cout;

	//TODO
	reg [15:0]C;
	reg Cout;
	reg [16:0]tmp;
	reg [15:0]negB;

	always @(*) begin
		// initialize output
		C = 16'h0000;
		Cout = 1'b0;

		if (OP == 4'b0000) begin
			tmp = {1'b0,A[15:0]} + {1'b0,B[15:0]}; // binary add with an extended bit
			C = tmp[15:0];
			if (A[15]==B[15] && tmp[16]!=tmp[15]) begin //overflow detection
				Cout = 1'b1;
			end
		end

		if (OP == 4'b0001) begin
			negB = ~B + 1'b1; // 2's complement of B
			tmp = {1'b0,A[15:0]} + {1'b0,negB[15:0]}; // binary add with an extended bit
			C = tmp[15:0];
			if (A[15]==negB[15] && tmp[16]!=tmp[15]) begin //overflow detection
				Cout = 1'b1;
			end
		end

		if (OP == 4'b0010) begin
			C = A&B;
		end

		if (OP == 4'b0011) begin
			C = A|B;
		end

		if (OP == 4'b0100) begin
			C = ~(A&B);
		end

		if (OP == 4'b0101) begin
			C = ~(A|B);
		end

		if (OP == 4'b0110) begin
			C = A^B;
		end

		if (OP == 4'b0111) begin
			C = A ~^B;
		end

		if (OP == 4'b1000) begin
			C = A;
		end

		if (OP == 4'b1001) begin
			C = ~A;
		end

		if (OP == 4'b1010) begin
			C = (A>>1);
		end

		if (OP == 4'b1011) begin
			C = (A>>>1);
			if (C[14] == 1'b1) begin
				C[15] = 1'b1;
			end
		end
	
		if (OP == 4'b1100) begin
			C = {A[0], A[15:1]};
		end

		if (OP == 4'b1101) begin
			C = (A<<1);
		end

		if (OP == 4'b1110) begin
			C = (A<<<1);
		end

		if (OP == 4'b1111) begin
			C = {A[14:0], A[15]};
		end
	end
endmodule
