module Cache (
	//RISV_top DMEM control Signals
	input wire CLK,

	input wire D_MEM_CSN,
	input wire [31:0] D_MEM_DOUT,
	input wire [11:0] D_MEM_ADDR,//in word address
	input wire D_MEM_WEN,
	input wire [3:0] D_MEM_BE,
	input wire [31:0] D_MEM_DI,

	//pipeline stall signals
	output wire [31:0] Cache_DI,
	output wire RDY,
	output wire VALID
	)
	
	wire [6:0] tag;
	wire [2:0] idx;
	wire [1:0] g;
	assign tag = D_MEM_ADDR[11:5];
	assign idx = D_MEM_ADDR[4:2];
	assign g = D_MEM_ADDR[1:0];

	reg	[127:0]	databank[0:7];
	reg [6:0] tagbank[0:7];
	reg validbank[0:7];

	reg timer;

	initial begin
		timer = 0;
	end

	always @(negedge CLK) begin
		if (RDY == 1) timer = 0;
		else timer = timer + 1;
	end

	// cache write
	always @(negedge CLK) begin
		if (cache miss)
	end


	// cache read
	always @(*) begin
		tag hit = tagbank[idx]==tag;
		valid hit = validbank[idx];
		if (tag hit && valid hit) begin
			Cache_DI = databank[idx][(g+1)*32 -1 : g*32];
		end
		else begin
			
		end
		Cache_DI, RDY, VALID 값 출력

	end
	

endmodule