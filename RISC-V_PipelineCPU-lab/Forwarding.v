	module Forwarding(
		input wire [4:0] rd_mem,   // input
		input wire [4:0] rd_wb,
		input wire RegWrite_wb,
		input wire RegWrite_mem,
		input wire [4:0] rs1_ex,
		input wire [4:0] rs2_ex,
		
		output reg [1:0] forwardA,   //output
		output reg [1:0] forwardB
		);

		initial begin
			forwardA = 2'bxx;
			forwardB = 2'bxx;
		end

		always @(*) begin

			// forwardA signal
			if ((rs1_ex!=0) && (rs1_ex==rd_mem) && RegWrite_mem) begin // forward operand from MEM stage
				forwardA = 2'b01;
			end
			else if ((rs1_ex!=0) && (rs1_ex==rd_wb) && RegWrite_wb) begin // forward operand from WB stage
				forwardA = 2'b10;
			end
			else begin // use the operand from register file
				forwardA = 2'b00;
			end

			// forwardB signal
			if ((rs2_ex!=0) && (rs2_ex==rd_mem) && RegWrite_mem) begin // forward operand from MEM stage
				forwardB = 2'b01;
			end
			else if ((rs2_ex!=0) && (rs2_ex==rd_wb) && RegWrite_wb) begin // forward operand from WB stage
				forwardB = 2'b10;
			end
			else begin // use the operand from register file
				forwardB = 2'b00;
			end

		end
	endmodule