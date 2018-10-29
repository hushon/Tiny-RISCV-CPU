module Immediate_Concatenator (
	input wire [31:0] Instr,
	input wire [2:0] Concat_control,
	output reg [31:0] offset
	);

	reg signed [31:0] signed_offset;

	always@(*) begin
		case(Concat_control)
			3'b001 : begin //LUI, AUIPC, U-type 7'b0110111, 7'b0010111
				signed_offset = {Instr[31:12],12'b0};
				offset = signed_offset;
			end
			3'b010 : begin //JAL , J-type 7'b1101111
				signed_offset = {Instr[31],Instr[19:12], Instr[20], Instr[30:21],12'b0};
				offset = signed_offset >>>11;
			end
			3'b011 : begin //JALR, Load, I-type 7'b1100111, 7'b0000011, 7'b0010011
				signed_offset = {Instr[31:20],20'b0};
				offset = signed_offset >>>20;
			end
			3'b100 : begin //Branch, B-type 7'b1100011
				signed_offset = {Instr[31],Instr[7],Instr[30:25],Instr[11:8],20'b0};
				offset = signed_offset >>>19;
			end
			3'b101 : begin //Store, S-type 7'b0100011
				signed_offset = {Instr[31:25],Instr[11:7],20'b0};
				offset = signed_offset >>>20;
			end
			3'b110 : begin // SLLI, SRLI, SRAI
				offset = {27'b0,Instr[24:20]} ;
			end
			default : offset = 0;
		endcase
	end
endmodule