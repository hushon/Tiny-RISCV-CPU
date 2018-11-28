module Cache (
	input wire CLK,

	// Cache control signals and data input/output signals
	input wire Cache_CSN,
	output wire [31:0] Cache_DOUT,
	input wire [11:0] Cache_ADDR,
	input wire Cache_WEN,
	input wire [3:0] Cache_BE,
	input wire [31:0] Cache_DI,

	// D-memory control signals and data input/output signals
	output wire D_MEM_CSN,
	input wire [31:0] D_MEM_DOUT,
	output wire [11:0] D_MEM_ADDR,//in word address
	output wire D_MEM_WEN,
	output wire [3:0] D_MEM_BE,
	output wire [31:0] D_MEM_DI,
	// SOME OF THEM NEEDS TO CHANGE TO OUTPUT IN ORDER TO TELL .TOP TO CONTROL MEMORY

	//pipeline stall signals
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
		databank = 0;
		tagbank = 0;
		validbank = 0; // THIS IS NOT CORRECT. ARRAY INITIALIZATION
	end

	// clock cycle counter
	always @(negedge CLK) begin
		if (RDY == 1) timer = 0;
		else timer = timer + 1;
	end

	// check cache hit
	always @(*) begin // MAY HAVE TO CHANGE TO NEGEDGE
		if (~CSN) begin
			tag_hit = tagbank[idx]==tag;
			valid = validbank[idx];
			cache_hit = tag_hit && valid;
		end
		else begin
			cache_hit = 1'bx;
		end
	end

	// synchronous cache read
	always @(negedge CLK) begin
		if (~CSN) begin
			if (~WEN) begin // READ MODE

				if (cache_hit) begin // read from cache if cache hit
					Cache_DOUT = databank[idx][(g+1)*32-1 : g*32];
					RDY = 1;
					VALID = 1;
				end
				else if (~cache_hit) begin // read from memory if cache miss
					// LOAD 4 WORDS FROM MEMORY AND UPDATE CACHE BLOCK
					// THEN OUTPUT REQUESTED DATA
					if (timer == 0) begin
						RDY = 0;
						VALID = 0;
						D_MEM_CSN = 0; D_MEM_WEN = 0; D_MEM_BE = 4'b1111, D_MEM_ADDR = {tag, idx, 2'b00}; // load 1st word from memory
					end
					else if (timer == 1) begin
						databank[idx][(2'b00+1)*32-1 : 2'b00*32] = D_MEM_DOUT; // save 1st word to cache
						D_MEM_CSN = 0; D_MEM_WEN = 0; D_MEM_BE = 4'b1111, D_MEM_ADDR = {tag, idx, 2'b01}; // load 2nd word from memory
					end
					else if (timer == 2) begin
						databank[idx][(2'b01+1)*32-1 : 2'b01*32] = D_MEM_DOUT; // save 2nd word to cache
						D_MEM_CSN = 0; D_MEM_WEN = 0; D_MEM_BE = 4'b1111, D_MEM_ADDR = {tag, idx, 2'b10}; // load 3rd word from memory
					end
					else if (timer == 3) begin
						databank[idx][(2'b10+1)*32-1 : 2'b10*32] = D_MEM_DOUT; // save 3rd word to cache
						D_MEM_CSN = 0; D_MEM_WEN = 0; D_MEM_BE = 4'b1111, D_MEM_ADDR = {tag, idx, 2'b11}; // load 4th word from memory
					end
					else if (timer == 4) begin
						databank[idx][(2'b11+1)*32-1 : 2'b11*32] = MEMORY[{tag, idx, 2'b11}] // save 4th word to cache
						tagbank[idx] = tag; // update tag bank
						validbank[idx] = 1; // update valid bank
					end
					else if (timer == 5) begin
						Cache_DOUT = databank[idx][(g+1)*32-1 : g*32]; // output data
						RDY = 1;
						VALID = 1;
					end
				end
			end
		end
	end

	// synchronous cache write
	always @(negedge CLK) begin
		if (~CSN) begin
			if (WEN) begin // WRITE MODE

				if (cache hit) begin // WRITE-THROUGH POLICY
					// WRITE TO CACHE
					databank[idx][(g+1)*32-1 : g*32] = Cache_DI;
					validbank[idx] = 1;
					// WRITE TO MEMORY MEMORY[ADDR] = D_MEM_DI;
					D_MEM_CSN = 0; D_MEM_WEN = 1; D_MEM_BE = 4'b1111, D_MEM_ADDR = Cache_ADDR;
					D_MEM_DI = Cache_DI;
					RDY = 1;
					VALID = 1;
				end
				else if (cache miss) begin // WRITE-ALLOCATE POLICY
					if (timer == 0) begin
						RDY = 0;
						VALID = 0;

						// WRITE TO MEMORY
						MEMORY[ADDR] = D_MEM_DI;
						D_MEM_CSN = 0; D_MEM_WEN = 1; D_MEM_BE = 4'b1111, D_MEM_ADDR = Cache_ADDR;
						D_MEM_DI = Cache_DI;

						// LOAD TO CACHE
						D_MEM_CSN = 0; D_MEM_WEN = 0; D_MEM_BE = 4'b1111, D_MEM_ADDR = {tag, idx, 2'b00}; // load 1st word from memory
					end
					else if (timer == 1) begin
						databank[idx][(2'b00+1)*32-1 : 2'b00*32] = D_MEM_DOUT; // save 1st word to cache
						D_MEM_CSN = 0; D_MEM_WEN = 0; D_MEM_BE = 4'b1111, D_MEM_ADDR = {tag, idx, 2'b01}; // load 2nd word from memory
					end
					else if (timer == 2) begin
						databank[idx][(2'b01+1)*32-1 : 2'b01*32] = D_MEM_DOUT; // save 2nd word to cache
						D_MEM_CSN = 0; D_MEM_WEN = 0; D_MEM_BE = 4'b1111, D_MEM_ADDR = {tag, idx, 2'b10}; // load 3rd word from memory
					end
					else if (timer == 3) begin
						databank[idx][(2'b10+1)*32-1 : 2'b10*32] = D_MEM_DOUT; // save 3rd word to cache
						D_MEM_CSN = 0; D_MEM_WEN = 0; D_MEM_BE = 4'b1111, D_MEM_ADDR = {tag, idx, 2'b11}; // load 4th word from memory
					end
					else if (timer == 4) begin
						databank[idx][(2'b11+1)*32-1 : 2'b11*32] = MEMORY[{tag, idx, 2'b11}] // save 4th word to cache
						tagbank[idx] = tag; // update tag bank
						validbank[idx] = 1; // update valid bank
					end
					else if (timer == 5) begin
						// Cache_DOUT = databank[idx][(g+1)*32-1 : g*32]; // output data
						RDY = 1;
						VALID = 1;
					end
				end

			end
		end
	end

	

endmodule