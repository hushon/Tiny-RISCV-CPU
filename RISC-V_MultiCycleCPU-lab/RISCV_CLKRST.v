`timescale 1ns/1ps

module RISCV_CLKRST (
  output wire CLK,
  output wire RSTn
 );

  reg clock_q = 1'b0;
  reg reset_n_q = 1'b0;

  initial
    begin
      #5 clock_q <= 1'b1;
      #101 reset_n_q <= 1'b1;
    end

  always @(clock_q)
      #5 clock_q <= ~clock_q;

  assign CLK = clock_q;
  assign RSTn = reset_n_q;

endmodule
