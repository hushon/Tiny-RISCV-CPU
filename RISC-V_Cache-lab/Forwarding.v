	module Forwarding(
		input wire [4:0] rd_ex, // input
		input wire [4:0] rd_mem,   
		input wire [4:0] rd_wb,
		input wire RegWrite_wb,
		input wire RegWrite_mem,
		input wire [4:0] rs1_id,
		input wire [4:0] rs2_id,
		input wire [4:0] rs1_ex,
		input wire [4:0] rs2_ex,
		input wire use_rs1_ex,
		input wire use_rs2_ex,
		input wire [6:0] opcode_id,
		input wire [6:0] opcode_ex,
		input wire [6:0] opcode_mem,
		input wire [6:0] opcode_wb,
		
		output reg [1:0] forwardA,   //output
		output reg [1:0] forwardB,
		output reg [1:0] writedatasel,
		output reg [1:0] branch_forwardA,
		output reg [1:0] branch_forwardB
		);

		initial begin
			forwardA = 2'bxx;
			forwardB = 2'bxx;
			writedatasel = 2'bxx;
			branch_forwardA = 2'bxx;
			branch_forwardB = 2'bxx;
		end

		reg [6:0] opSW = 7'b0100011;
		reg [6:0] opR = 7'b0110011;
		reg [6:0] opI = 7'b0010011;
		reg [6:0] opLW = 7'b0000011;
		reg [6:0] opBr = 7'b1100011;
		reg [6:0] opJALR = 7'b1100111;

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

			// opcode_ex==SW and opcode_mem==(R or I) and rs_ex==rd_mem
			if (opcode_ex==opSW && (opcode_mem==opR || opcode_mem==opI) && rs2_ex==rd_mem) begin // dist=1 between I/R and SW
				writedatasel = 2'b01;
			end
			// opcode_ex==SW and opcode_mem==LW and rs_ex==rd_mem
			else if (opcode_ex==opSW && opcode_mem==opLW && rs2_ex==rd_mem) begin // dist=1 between LW and SW
				writedatasel = 2'b10;
			end
			// opcode_ex==SW and opcode_wb==(R or I) and rs_ex==rd_wb
			else if (opcode_ex==opSW && (opcode_wb==opR || opcode_wb==opI) && (rs2_ex==rd_wb)) begin // dist=2 between I/R and SW
				writedatasel = 2'b11;
			end
			//opcode_ex==SW and opcode_wb==(R or I) and rs2_ex==rd_wb
			else if (opcode_ex==opSW && opcode_wb==opLW && (rs2_ex==rd_wb)) begin // dist=2 between LW and SW
				writedatasel = 2'b11;
			end
			else begin
				writedatasel = 2'b00;
			end

			//branch_forwardA signal
			if ((opcode_ex==opR || opcode_ex==opI) && (opcode_id==opBr || opcode_id==opJALR) && rs1_id==rd_ex ) begin //dist=1 between I/R and branch/JALR
				branch_forwardA = 2'b01;
			end
			else if ((opcode_mem==opR || opcode_mem==opI) && (opcode_id==opBr || opcode_id==opJALR) && rs1_id==rd_mem) begin //dist=2 between I/R and branch/JALR
				branch_forwardA = 2'b10;
			end
			else if ((opcode_mem==opLW) && (opcode_id==opBr || opcode_id==opJALR) && rs1_id==rd_mem) begin //dist=2 between LW and branch/JALR
				branch_forwardA = 2'b11;
			end
			else begin
				branch_forwardA = 2'b00;
			end

			//branch_forwardB signal
			if ( (opcode_ex==opR || opcode_ex==opI) && (opcode_id==opBr) && rs2_id==rd_ex ) begin //dist=1 between I/R and branch
				branch_forwardB = 2'b01;
			end
			else if ((opcode_mem==opR || opcode_mem==opI) && (opcode_id==opBr) && rs2_id==rd_mem) begin //dist=2 between I/R and branch
				branch_forwardB = 2'b10;
			end
			else if ((opcode_mem==opLW) && (opcode_id==opBr) && rs2_id==rd_mem) begin //dist=2 between LW and branch
				branch_forwardB = 2'b11;
			end
			else begin
				branch_forwardB = 2'b00;
			end
		end
	endmodule