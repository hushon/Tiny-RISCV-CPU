	module Hazard_detect(
		input wire rd_ex,  //input
		input wire MemRead_ex,
		input wire rs1_id,
		input wire rs2_id,  
		
		output reg load_delay,   //output
		output reg PCWrite,
		output reg IF_ID_Write
		);

	endmodule