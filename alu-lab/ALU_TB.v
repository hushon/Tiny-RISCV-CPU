`timescale 100ps / 100ps
`include "alu.v"

// Arithmetic
`define	OP_ADD	4'b0000
`define	OP_SUB	4'b0001
// Bitwise Boolean operation
`define	OP_AND	4'b0010
`define	OP_OR 	4'b0011
`define	OP_NAND	4'b0100
`define	OP_NOR	4'b0101
`define	OP_XOR	4'b0110
`define	OP_XNOR	4'b0111
// Logic
`define	OP_ID	  4'b1000
`define	OP_NOT  4'b1001

// Shift
`define	OP_LRS	4'b1010
`define	OP_ARS	4'b1011
`define	OP_RR	  4'b1100
`define	OP_LLS	4'b1101
`define	OP_ALS	4'b1110
`define	OP_RL	  4'b1111

module ALU_TB;

//Internal signals declarations:
reg [15:0]A;
reg [15:0]B;
reg [3:0]OP;
wire [15:0]C;
wire Cout;

reg [15:0] Passed;
reg [15:0] Failed;

// Unit Under Test port map
	ALU UUT (
		.A(A),
		.B(B),
		.OP(OP),
		.C(C),
		.Cout(Cout));

initial begin
	Passed = 0;
	Failed = 0;

	ArithmeticTest;
	BitwiseBooleanTest;
	ShiftTest;

	$display("Passed = %0d, Failed = %0d", Passed, Failed);
	$finish;
end

task ArithmeticTest;
begin
	AddTest;
	SubTest;
end
endtask

task BitwiseBooleanTest;
begin
	AndTest;
	OrTest;
	NandTest;
	NorTest;
	XorTest;
	XnorTest;
	IdTest;
	NotTest;
end
endtask

task ShiftTest;
begin
	LrsTest;
	ArsTest;
	RrTest;
	LlsTest;
	AlsTest;
	RlTest;
end
endtask

task AddTest;
begin
	OP = `OP_ADD;

	Test("Add-1", 0, 0, 0, 0);
	Test("Add-2", 1, 0, 1, 0);
	Test("Add-3", 2, 3, 5, 0);
	Test("Add-4", 3, 2, 5, 0);
	Test("Add-5", 2, 3, 5, 0);
	Test("Add-6", 3, 2, 5, 0);
	Test("Add-7", 16'h8000, 16'h8000, 0, 1);
	Test("Add-8", 16'hffff, 1, 0, 0);
	Test("Add-9", 16'hffff, 16'hffff, 16'hfffe, 0);
end
endtask

task SubTest;
begin
	OP = `OP_SUB;
	Test("Sub-1", 0, 0, 0, 0);
	Test("Sub-2", 1, 0, 1, 0);
	Test("Sub-3", 0, 1, 16'hffff, 0);
	Test("Sub-4", 16'hffff, 16'hffff, 0, 0);
	Test("Sub-5", 3, 2, 1, 0);
	Test("Sub-6", 0, 2, 16'hfffe, 0);
	Test("Sub-7", 0, 16'hffff, 1, 0);
end
endtask

task IdTest;
begin
	OP = `OP_ID;
	Test("Id-1", 0, 0, 0, 0);
	Test("Id-2", 16'hdead, 0, 16'hdead, 0);
	Test("Id-3", 16'hbeef, 0, 16'hbeef, 0);
end
endtask

task NandTest;
begin
	OP = `OP_NAND;
	Test("Nand-1", {4{4'b1010}}, {4{4'b0101}}, {4{4'b1111}}, 0);
	Test("Nand-2", {4{4'b0110}}, {4{4'b0101}}, {4{4'b1011}}, 0);
end
endtask

task NorTest;
begin
	OP = `OP_NOR;
	Test("Nor-1", {4{4'b0101}}, {4{4'b1101}}, {4{4'b0010}}, 0);
	Test("Nor-2", {4{4'b1000}}, {4{4'b0001}}, {4{4'b0110}}, 0);
end
endtask

task XnorTest;
begin
	OP = `OP_XNOR;
	Test("Xnor-1", {4{4'b0111}}, {4{4'b0001}}, {4{4'b1001}}, 0);
	Test("Xnor-2", {4{4'b1010}}, {4{4'b0101}}, {4{4'b0000}}, 0);
end
endtask

task NotTest;
begin
	OP = `OP_NOT;
	Test("Not-1", 0, 0, 16'hffff, 0);
	Test("Not-2", 1, 0, 16'hfffe, 0);
	Test("Not-3", 16'hcafe, 0, 16'h3501, 0);
end
endtask

task AndTest;
begin
	OP = `OP_AND;
	Test("And-1", {4{4'b0111}}, {4{4'b0101}}, {4{4'b0101}}, 0);
	Test("And-2", {4{4'b1010}}, {4{4'b0101}}, {4{4'b0000}}, 0);
end
endtask

task OrTest;
begin
	OP = `OP_OR;
	Test("Or-1", {4{4'b0111}}, {4{4'b0101}}, {4{4'b0111}}, 0);
	Test("Or-2", {4{4'b1010}}, {4{4'b0101}}, {4{4'b1111}}, 0);
end
endtask

task XorTest;
begin
	OP = `OP_XOR;
	Test("Xor-1", {4{4'b0111}}, {4{4'b0101}}, {4{4'b0010}}, 0);
	Test("Xor-2", {4{4'b1010}}, {4{4'b0101}}, {4{4'b1111}}, 0);
end
endtask

task LrsTest;
begin
	OP = `OP_LRS;
	Test("Lrs-1", 16'ha, 0, 5, 0);
	Test("Lrs-2", 1, 0, 0, 0);
	Test("Lrs-3", 16'hfffa, 0, 16'h7ffd, 0);
	Test("Lrs-4", 16'hffff, 0, 16'h7fff, 0);
end
endtask

task ArsTest;
begin
	OP = `OP_ARS;
	Test("Ars-1", 16'ha, 0, 5, 0);
	Test("Ars-2", 1, 0, 0, 0);
	Test("Ars-3", 16'hfffa, 0, 16'hfffd, 0);
	Test("Ars-4", 16'hffff, 0, 16'hffff, 0);
end
endtask

task RrTest;
begin
	OP = `OP_RR;
	Test("Rr-1", 16'ha, 0, 16'h5, 0);
	Test("Rr-2", 16'hb, 0, 16'h8005, 0);
end
endtask

task LlsTest;
begin
	OP = `OP_LLS;
	Test("Lls-1", 16'ha, 0, 16'h14, 0);
	Test("Lls-2", 16'hf000, 0, 16'he000, 0);
end
endtask

task AlsTest;
begin
	OP = `OP_ALS;
	Test("Als-1", 16'ha, 0, 16'h14, 0);
	Test("Als-2", 16'hf000, 0, 16'he000, 0);
end
endtask

task RlTest;
begin
	OP = `OP_RL;
	Test("Rl-1", 16'h7000, 0, 16'he000, 0);
	Test("Rl-2", 16'hf000, 0, 16'he001, 0);
end
endtask

task Test;
	input [16 * 8 : 0] test_name;
	input [15:0] A_;
	input [15:0] B_;
	input [15:0] C_expected;
	input Cout_expected;
begin
	$display("TEST %s :", test_name);
	A = A_;
	B = B_;
	#1;
	if (C == C_expected && Cout == Cout_expected)
		begin
			$display("PASSED");
			Passed = Passed + 1;
		end
	else
		begin
			$display("FAILED");
			$display("A = %0b, B = %0b, C = %0b (Ans : %0b), Cout = %0b (Ans : %0b)", A_, B_, C, C_expected, Cout, Cout_expected);
			Failed = Failed + 1;
		end
end
endtask

endmodule
