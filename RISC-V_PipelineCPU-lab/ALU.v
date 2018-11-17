module ALU(
	input wire [31:0] Operand1,
	input wire [31:0] Operand2,
	input wire [4:0] ALU_operation,
	output reg Zero,
	output reg [31:0] ALU_Result
	);
	
	reg signed [31:0] signed_Operand1;
	reg signed [31:0] signed_Operand2;
	
	always@(*) begin
		case(ALU_operation)
			5'b00000: begin    // signed Add  / AUIPC
				signed_Operand1 = Operand1; 
				signed_Operand2 = Operand2; 
				ALU_Result = signed_Operand1 + signed_Operand2; 
				Zero = 1'b0;
			end
			5'b00001: begin // signed Sub
				signed_Operand1 = Operand1; 
				signed_Operand2 = Operand2; 
				ALU_Result = signed_Operand1 - signed_Operand2; 
				Zero = 1'b0;
			end
			5'b00010: begin
				ALU_Result = Operand1 & Operand2; 
				Zero = 1'b0;
			end
			5'b00011: begin
				ALU_Result = Operand1 | Operand2; 
				Zero = 1'b0;
			end
			5'b00100: begin
				ALU_Result = ~(Operand1 & Operand2); 
				Zero = 1'b0;
			end
			5'b00101: begin 
				ALU_Result = ~(Operand1 | Operand2); 
				Zero = 1'b0;
			end
			5'b00110: begin 
				ALU_Result = Operand1 ^ Operand2; 
				Zero = 1'b0;
			end
			5'b00111: begin
				ALU_Result = Operand1 ~^ Operand2; 
				Zero = 1'b0;
			end
			5'b01000: begin
				ALU_Result = Operand2; 
				Zero = 1'b0;
			end
			5'b01001: begin
				ALU_Result = ~Operand2; 
				Zero = 1'b0;
			end
			5'b01010: begin
				ALU_Result = Operand1>>Operand2; 
				Zero = 1'b0;
			end
			5'b01011: begin
				signed_Operand1 = Operand1; 
				ALU_Result = signed_Operand1>>>Operand2; 
				Zero = 1'b0;
			end

			5'b01100: begin
				ALU_Result = Operand1 + Operand2; 
				Zero = 1'b0; // Unsigned Add
			end

			5'b01101: begin
				ALU_Result = Operand1<<Operand2; 
				Zero = 1'b0;
			end
			5'b01110: begin 
				ALU_Result = Operand1<<<Operand2; 
				Zero = 1'b0;
			end
		
			5'b01111: begin
				ALU_Result = Operand1 - Operand2; 
				Zero = 1'b0; // Unsigned Sub
			end

			5'b10000: begin
				ALU_Result = (Operand1 == Operand2); 
				Zero = (Operand1 == Operand2); // BEQ
			end
			5'b10001: begin
				ALU_Result = (Operand1 != Operand2); 
				Zero = (Operand1 != Operand2); // BNE
			end
			5'b10010: begin
				   // BLT
				signed_Operand1 = Operand1; 
				signed_Operand2 = Operand2; 
				ALU_Result = (signed_Operand1 < signed_Operand2);
				Zero = (signed_Operand1 < signed_Operand2);
			end
			5'b10011: begin
				  // BGE
				signed_Operand1 = Operand1; 
				signed_Operand2 = Operand2; 
				ALU_Result = (signed_Operand1 >= signed_Operand2);
				Zero = (signed_Operand1 >= signed_Operand2);
			end
			5'b10100: begin
				ALU_Result = (Operand1 < Operand2);
				Zero = (Operand1 < Operand2); //BLTU
			end
			5'b10101: begin
				ALU_Result = (Operand1 >= Operand2);
				Zero = (Operand1 >= Operand2); //BGEU
			end

			5'b10110:begin   // SLTI, SLT
				signed_Operand1 = Operand1; 
				signed_Operand2 = Operand2; 
				ALU_Result = (signed_Operand1 < signed_Operand2);
				Zero = 0; 
			end
			5'b10111: begin
				ALU_Result = (Operand1 < Operand2);
				Zero = 0; //SLTIU , SLTU
			end
			default: begin
				signed_Operand1 = Operand1; 
				signed_Operand2 = Operand2; 
				ALU_Result = signed_Operand1 + signed_Operand2; 
				Zero = 1'b0;
			end
		endcase
	end
endmodule