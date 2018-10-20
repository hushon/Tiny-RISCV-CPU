module REG_FILE #(
	parameter DWIDTH = 32,
	parameter MDEPTH = 32,
	parameter AWIDTH = 5
)  (
	input wire CLK,
	input wire WE,
	input wire RSTn,
	input wire [AWIDTH-1:0] RA1, RA2, WA,
	input wire [DWIDTH-1:0] WD,
	output wire [DWIDTH-1:0] RD1, RD2
);

	//Declare the register that will store the data
	reg [DWIDTH-1:0] RF [MDEPTH-1:0];

	//Define asynchronous read
	assign RD1 = RF[RA1];
	assign RD2 = RF[RA2];

	//Define synchronous write
	always @(posedge CLK)
	begin
		if(WE && (WA != {AWIDTH{1'b0}}))
		begin
        		RF[WA] <= WD;
    		end

		else if (~RSTn)
    		begin
			RF[0] <= 32'b0;
			RF[2] <= 32'hF00;
			RF[3] <= 32'h100;
			RF[1] <= 32'b0;
			RF[4] <= 32'b0;
			RF[5] <= 32'b0;
			RF[6] <= 32'b0;
			RF[7] <= 32'b0;
			RF[8] <= 32'b0;
			RF[9] <= 32'b0;
			RF[10] <= 32'b0;
			RF[11] <= 32'b0;
			RF[12] <= 32'b0;
			RF[13] <= 32'b0;
			RF[14] <= 32'b0;
			RF[15] <= 32'b0;
			RF[16] <= 32'b0;
			RF[17] <= 32'b0;
			RF[18] <= 32'b0;
			RF[19] <= 32'b0;
			RF[20] <= 32'b0;
			RF[21] <= 32'b0;
			RF[22] <= 32'b0;
			RF[23] <= 32'b0;
			RF[24] <= 32'b0;
			RF[25] <= 32'b0;
			RF[26] <= 32'b0;
			RF[27] <= 32'b0;
			RF[28] <= 32'b0;
			RF[29] <= 32'b0;
			RF[30] <= 32'b0;
			RF[31] <= 32'b0;
		end

		else
		begin
			RF[WA] <= RF [WA];//?????
		end
	end

endmodule
