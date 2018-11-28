module Cache (
	input wire CLK,

	// Cache control signals and data input/output signals
	input wire Cache_CSN, // chip select negative
	output reg [31:0] Cache_DOUT,
	input wire [11:0] Cache_ADDR,
	input wire Cache_WEN, // write enable negative
	input wire [3:0] Cache_BE,
	input wire [31:0] Cache_DI,

	// D-memory control signals and data input/output signals
	output reg D_MEM_CSN,
	output reg [31:0] D_MEM_DOUT,
	output reg [11:0] D_MEM_ADDR,//in word address
	output reg D_MEM_WEN,
	output reg [3:0] D_MEM_BE,
	input wire [31:0] D_MEM_DI,
	// SOME OF THEM NEEDS TO CHANGE TO OUTPUT IN ORDER TO TELL .TOP TO CONTROL MEMORY

	//pipeline stall signals
	output reg RDY,
	output reg VALID
	);
	
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
		//databank = 0;
		//tagbank = 0;
		//validbank = 0; // THIS IS NOT CORRECT. ARRAY INITIALIZATION
	end

	// clock cycle counter
	always @(negedge CLK) begin
		if (RDY == 1) timer = 0;
		else timer = timer + 1;
	end

	// check cache hit
	reg tag_hit, valid, cache_hit;
	always @(*) begin // MAY HAVE TO CHANGE TO NEGEDGE
		if (~Cache_CSN) begin
			tag_hit = tagbank[idx]==tag;
			valid = validbank[idx];
			cache_hit = tag_hit && valid;
		end
		else begin
			cache_hit = 1'bx;
		end
	end

	always @(negedge CLK) begin
		if (~Cache_CSN) begin
			// synchronous cache read
			if (Cache_WEN) begin // READ MODE

				if (cache_hit) begin // read from cache if cache hit
					Cache_DOUT = databank[idx][g*32 +: 32];
					RDY = 1;
					VALID = 1;
				end
				else if (~cache_hit) begin // read from memory if cache miss
					// LOAD 4 WORDS FROM MEMORY AND UPDATE CACHE BLOCK
					// THEN OUTPUT REQUESTED DATA
					if (timer == 0) begin
						RDY = 0;
						VALID = 0;
						D_MEM_CSN = 0; D_MEM_WEN = 1; D_MEM_BE = 4'b1111; D_MEM_ADDR = {tag, idx, 2'b00}; // load 1st word from memory
					end
					else if (timer == 1) begin
						databank[idx][(2'b00+1)*32-1 : 2'b00*32] = D_MEM_DI; // save 1st word to cache
						D_MEM_CSN = 0; D_MEM_WEN = 1; D_MEM_BE = 4'b1111; D_MEM_ADDR = {tag, idx, 2'b01}; // load 2nd word from memory
					end
					else if (timer == 2) begin
						databank[idx][(2'b01+1)*32-1 : 2'b01*32] = D_MEM_DI; // save 2nd word to cache
						D_MEM_CSN = 0; D_MEM_WEN = 1; D_MEM_BE = 4'b1111; D_MEM_ADDR = {tag, idx, 2'b10}; // load 3rd word from memory
					end
					else if (timer == 3) begin
						databank[idx][(2'b10+1)*32-1 : 2'b10*32] = D_MEM_DI; // save 3rd word to cache
						D_MEM_CSN = 0; D_MEM_WEN = 1; D_MEM_BE = 4'b1111; D_MEM_ADDR = {tag, idx, 2'b11}; // load 4th word from memory
					end
					else if (timer == 4) begin
						databank[idx][(2'b11+1)*32-1 : 2'b11*32] = D_MEM_DI; // save 4th word to cache
						tagbank[idx] = tag; // update tag bank
						validbank[idx] = 1; // update valid bank
					end
					else if (timer == 5) begin
						Cache_DOUT = databank[idx][g*32 +: 32]; // output data
						RDY = 1;
						VALID = 1;
					end
				end
			end

	// synchronous cache write
			else if (~Cache_WEN) begin // WRITE MODE

				if (cache_hit) begin // WRITE-THROUGH POLICY
					// WRITE TO CACHE
					databank[idx][g*32 +: 32] = Cache_DI;
					validbank[idx] = 1;
					// WRITE TO MEMORY MEMORY[ADDR] = D_MEM_DOUT;
					D_MEM_CSN = 0; D_MEM_WEN = 1; D_MEM_BE = 4'b1111; D_MEM_ADDR = Cache_ADDR;
					D_MEM_DOUT = Cache_DI;
					RDY = 1;
					VALID = 1;
				end
				else if (~cache_hit) begin // WRITE-ALLOCATE POLICY
					if (timer == 0) begin
						RDY = 0;
						VALID = 0;

						// WRITE TO MEMORY
						// MEMORY[ADDR] = D_MEM_DI;
						D_MEM_CSN = 0; D_MEM_WEN = 0; D_MEM_BE = 4'b1111; D_MEM_ADDR = Cache_ADDR;
						D_MEM_DOUT = Cache_DI;
					end
					else if (timer == 1) begin
						// LOAD TO CACHE
						D_MEM_CSN = 0; D_MEM_WEN = 1; D_MEM_BE = 4'b1111; D_MEM_ADDR = {tag, idx, 2'b00}; // load 1st word from memory
					end
					else if (timer == 2) begin
						databank[idx][(2'b00+1)*32-1 : 2'b00*32] = D_MEM_DI; // save 1st word to cache
						D_MEM_CSN = 0; D_MEM_WEN = 1; D_MEM_BE = 4'b1111; D_MEM_ADDR = {tag, idx, 2'b01}; // load 2nd word from memory
						
					end
					else if (timer == 3) begin
						databank[idx][(2'b01+1)*32-1 : 2'b01*32] = D_MEM_DI; // save 2nd word to cache
						D_MEM_CSN = 0; D_MEM_WEN = 1; D_MEM_BE = 4'b1111; D_MEM_ADDR = {tag, idx, 2'b10}; // load 3rd word from memory
						
					end
					else if (timer == 4) begin
						databank[idx][(2'b10+1)*32-1 : 2'b10*32] = D_MEM_DI; // save 3rd word to cache
						D_MEM_CSN = 0; D_MEM_WEN = 1; D_MEM_BE = 4'b1111; D_MEM_ADDR = {tag, idx, 2'b11}; // load 4th word from memory
					end
					else if (timer == 5) begin
						databank[idx][(2'b11+1)*32-1 : 2'b11*32] = D_MEM_DI; // save 4th word to cache
						tagbank[idx] = tag; // update tag bank
						validbank[idx] = 1; // update valid bank
						RDY = 1;
						VALID = 1;
					end
				end
			end

			else begin
				RDY = 1;
				VALID = 0;
			end
		end
	end

	

endmodule