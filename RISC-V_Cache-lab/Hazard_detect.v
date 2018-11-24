	module Hazard_detect(
		input wire [4:0] rd_ex,  //input
		input wire MemRead_ex,
		input wire [4:0] rs1_id,
		input wire [4:0] rs2_id, 
		input wire use_rs1_id,
		input wire use_rs2_id,
		
		output reg load_delay,   //output
		output reg PCWrite,
		output reg IF_ID_Write
		);

		initial begin
			load_delay = 1'b0;
			PCWrite = 1'b1;
			IF_ID_Write = 1'b1;
		end

		always @(*) begin
			if ( (((rs1_id==rd_ex)&&(use_rs1_id)) || ((rs2_id==rd_ex)&&(use_rs2_id))) && MemRead_ex) begin
					load_delay = 1;
					PCWrite = 0;
					IF_ID_Write = 0;	
			end
			else begin
				load_delay = 0;
				PCWrite = 1;
				IF_ID_Write = 1;
			end
		end
		
	endmodule