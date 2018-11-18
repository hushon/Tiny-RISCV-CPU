	module Forwarding(
		input wire [4:0] rd_mem,   // input
		input wire [4:0] rd_wb,
		input wire RegWrite_wb,
		input wire RegWrite_mem,
		input wire [4:0] rs1_ex,
		input wire [4:0] rs2_ex,
		input wire use_rs1_ex,
		input wire use_rs2_ex,
		input wire [6:0] opcode_ex,
		input wire [6:0] opcode_mem,
		input wire [6:0] opcode_wb,
		
		output reg [1:0] forwardA,   //output
		output reg [1:0] forwardB,
		output reg [1:0] writedatasel
		);

		initial begin
			forwardA = 2'bxx;
			forwardB = 2'bxx;
		end

		always @(*) begin

			// forwardA signal
			if (use_rs1_ex && (rs1_ex!=0) && (rs1_ex==rd_mem) && RegWrite_mem) begin // forward operand from MEM stage
				forwardA = 2'b01;
			end
			else if (use_rs1_ex && (rs1_ex!=0) && (rs1_ex==rd_wb) && RegWrite_wb) begin // forward operand from WB stage
				forwardA = 2'b10;
			end
			else begin // use the operand from register file
				forwardA = 2'b00;
			end

			// forwardB signal
			if (use_rs2_ex &&(rs2_ex!=0) && (rs2_ex==rd_mem) && RegWrite_mem) begin // forward operand from MEM stage
				forwardB = 2'b01;
			end
			else if (use_rs2_ex &&(rs2_ex!=0) && (rs2_ex==rd_wb) && RegWrite_wb) begin // forward operand from WB stage
				forwardB = 2'b10;
			end
			else begin // use the operand from register file
				forwardB = 2'b00;
			end

			// writedatasel signal

		end
	endmodule