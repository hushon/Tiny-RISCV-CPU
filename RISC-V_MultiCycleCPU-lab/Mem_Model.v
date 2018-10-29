`timescale 1ns/10ps
module SP_SRAM #(parameter ROMDATA = "", AWIDTH = 12, SIZE = 4096) (
	input	wire			CLK,
	input	wire			CSN,//chip select negative??
	input	wire	[AWIDTH-1:0]	ADDR,
	input	wire			WEN,//write enable negative??
	input	wire	[3:0]		BE,//byte enable
	input	wire	[31:0]		DI, //data in
	output	wire	[31:0]		DOUT // data out
);

	reg		[31:0]		outline;
	reg		[31:0]		ram[0 : SIZE-1];
	reg		[31:0]		temp;

	initial begin
		if (ROMDATA != "")
			$readmemh(ROMDATA, ram);
	end

	assign #1 DOUT = outline;

	always @ (posedge CLK) begin
		// Synchronous write
		if (~CSN)
		begin
			if (~WEN)
			begin
				temp = ram[ADDR];
				if (BE[0]) temp[7:0] = DI[7:0];
				if (BE[1]) temp[15:8] = DI[15:8];
				if (BE[2]) temp[23:16] = DI[23:16];
				if (BE[3]) temp[31:24] = DI[31:24];

				ram[ADDR] = temp;
			end
		end
	end

	always @ (*) begin
		// Asynchronous read
		if (~CSN)
		begin
			if (WEN)
				outline = ram[ADDR];
		end
	end

endmodule
