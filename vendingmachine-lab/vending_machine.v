`include "vending_machine_def.v"

module vending_machine (

	clk,							// Clock signal
	reset_n,						// Reset signal (active-low)

	i_input_coin,				// coin is inserted.
	i_select_item,				// item is selected.
	i_trigger_return,			// change-return is triggered

	o_available_item,			// Sign of the item availability
	o_output_item,			// Sign of the item withdrawal
	o_return_coin,				// Sign of the coin return
	stopwatch,
	current_total,
	return_temp,
);

	// Ports Declaration
	// Do not modify the module interface
	input clk;
	input reset_n;

	input [`kNumCoins-1:0] i_input_coin;
	input [`kNumItems-1:0] i_select_item;
	input i_trigger_return;

	output reg [`kNumItems-1:0] o_available_item;
	output reg [`kNumItems-1:0] o_output_item;
	output reg [`kNumCoins-1:0] o_return_coin;

	output [3:0] stopwatch;
	output [`kTotalBits-1:0] current_total;
	output [`kTotalBits-1:0] return_temp;
	// Normally, every output is register,
	//   so that it can provide stable value to the outside.

//////////////////////////////////////////////////////////////////////	/

	//we have to return many coins
	reg [`kCoinBits-1:0] returning_coin_0;
	reg [`kCoinBits-1:0] returning_coin_1;
	reg [`kCoinBits-1:0] returning_coin_2;
	reg block_item_0;
	reg block_item_1;
	//check timeout
	reg [3:0] stopwatch;
	//when return triggered
	reg have_to_return;
	reg  [`kTotalBits-1:0] return_temp;
	reg [`kTotalBits-1:0] temp;
////////////////////////////////////////////////////////////////////////

	// Net constant values (prefix kk & CamelCase)
	// Please refer the wikepedia webpate to know the CamelCase practive of writing.
	// http://en.wikipedia.org/wiki/CamelCase
	// Do not modify the values.
	wire [31:0] kkItemPrice [`kNumItems-1:0];	// Price of each item
	wire [31:0] kkCoinValue [`kNumCoins-1:0];	// Value of each coin
	assign kkItemPrice[0] = 400;
	assign kkItemPrice[1] = 500;
	assign kkItemPrice[2] = 1000;
	assign kkItemPrice[3] = 2000;
	assign kkCoinValue[0] = 100;
	assign kkCoinValue[1] = 500;
	assign kkCoinValue[2] = 1000;


	// NOTE: integer will never be used other than special usages.
	// Only used for loop iteration.
	// You may add more integer variables for loop iteration.
	integer i, j, k,l,m,n;

	// Internal states. You may add your own net & reg variables.
	reg [`kTotalBits-1:0] current_total;
	reg [`kItemBits-1:0] num_items [`kNumItems-1:0];
	reg [`kCoinBits-1:0] num_coins [`kNumCoins-1:0];


	// Next internal states. You may add your own net and reg variables.
	reg [`kTotalBits-1:0] current_total_nxt;
	reg [`kItemBits-1:0] num_items_nxt [`kNumItems-1:0];
	reg [`kCoinBits-1:0] num_coins_nxt [`kNumCoins-1:0];
	reg isActive; // this signal is fired if any input is made


	// Variables. You may add more your own registers.
	reg [`kTotalBits-1:0] input_total, output_total, return_total_0,return_total_1,return_total_2;

	// Combinational logic for the next states
	always @(*) begin
		// TODO: current_total_nxt
		// You don't have to worry about concurrent activations in each input vector (or array).

		// calculate how much money is inserted from input_coins
		input_total = 100*i_input_coin[0] + 500*i_input_coin[1] + 1000*i_input_coin[2];
		num_coins_nxt[0] = num_coins[0] + i_input_coin[0] - o_return_coin[0];
		num_coins_nxt[1] = num_coins[1] + i_input_coin[1] - o_return_coin[1];
		num_coins_nxt[2] = num_coins[2] + i_input_coin[2] - o_return_coin[2];
		// calculate how much money is spent from output_items and o_return_coin
		output_total = 400*o_output_item[0] + 500*o_output_item[1] + 1000*o_output_item[2] + 2000*o_output_item[3] + 100*o_return_coin[0] + 500*o_return_coin[1] + 1000*o_return_coin[2];
		num_items_nxt[0] = num_items[0] - o_output_item[0];
		num_items_nxt[1] = num_items[1] - o_output_item[1];
		num_items_nxt[2] = num_items[2] - o_output_item[2];
		num_items_nxt[3] = num_items[3] - o_output_item[3];

		// Calculate the next current_total state. current_total_nxt =
		current_total_nxt = current_total + input_total - output_total;

		// set isActive to true if any input is made. this is used to reset stopwatch.
		if(i_input_coin!=0 || i_select_item!=0 || i_trigger_return!=0) isActive = 1;
		else isActive = 0;

	end

	// Combinational logic for the outputs
	always @(*) begin
	// TODO: o_available_item
		// items are available if current_total and stock is enough
		if (current_total < kkItemPrice[0]) o_available_item = 4'b0000;
		else if (current_total < kkItemPrice[1]) o_available_item = 4'b0001;
		else if (current_total < kkItemPrice[2]) o_available_item = 4'b0011;
		else if (current_total < kkItemPrice[3]) o_available_item = 4'b0111;
		else o_available_item = 4'b1111;

		if (num_items[3] <= 0) o_available_item[3] = 1'b0;
		if (num_items[2] <= 0) o_available_item[2] = 1'b0;
		if (num_items[1] <= 0) o_available_item[1] = 1'b0;
		if (num_items[0] <= 0) o_available_item[0] = 1'b0;

	// TODO: o_output_item
	o_output_item = o_available_item & i_select_item;	// item is delivered when available and selected. 

	// o_return_coin
	//if you have to return some coins then you have to turn on the bit
		if (i_trigger_return || stopwatch<=0) begin // if return is triggerd or stopwatch expires, return coins
			if (current_total >= 1000) o_return_coin = 3'b100;
			else if (current_total >= 500) o_return_coin = 3'b010;
			else if (current_total >= 100) o_return_coin = 3'b001;
			else o_return_coin = 3'b000;
	 	end
	 	else o_return_coin = 3'b000;
	end

	// Sequential circuit to reset or update the states
	always @(posedge clk) begin
		if (!reset_n) begin
			// TODO: reset all states.
			// initialize output variables
			o_available_item = 0;
			o_output_item = 0;
			o_return_coin = 0;

			// initialize internal state variables
			current_total = 0;

			num_items[0] = `kEachItemNum;
			num_items[1] = `kEachItemNum;
			num_items[2] = `kEachItemNum;
			num_items[3] = `kEachItemNum;

			num_coins[0] = `kEachCoinNum;
			num_coins[1] = `kEachCoinNum;
			num_coins[2] = `kEachCoinNum;

			stopwatch = `kWaitTime;
			return_temp = 0;
		end
		else begin
			// TODO: update all states.
			current_total = current_total_nxt;

			num_coins[0] = num_coins_nxt[0];
			num_coins[1] = num_coins_nxt[1];
			num_coins[2] = num_coins_nxt[2];

			num_items[0] = num_items_nxt[0];
			num_items[1] = num_items_nxt[1];
			num_items[2] = num_items_nxt[2];
			num_items[3] = num_items_nxt[3];

/////////////////////////////////////////////////////////////////////////
			// decrease stopwatch
			// each cycle, reduce stopwatch by 1. when there is any input, reset stopwatch.
			if(isActive) stopwatch = `kWaitTime;
			else stopwatch = stopwatch - 1;
/////////////////////////////////////////////////////////////////////////
		end		   //update all state end
	end	   //always end

endmodule
