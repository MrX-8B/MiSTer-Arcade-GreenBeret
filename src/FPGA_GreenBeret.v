/********************************************************************
   FPGA Implimentation of "Green Beret" & "Mr.Goemon" (Top Module)
*********************************************************************/
// Copyright (c) 2013,19 MiSTer-X

module FPGA_GreenBeret
(
	input				clk48M,
	input				reset,

	input	  [5:0]	INP0,			// Control Panel
	input	  [5:0]	INP1,
	input	  [2:0]	INP2,

	input   [8:0]  PH,         // PIXEL H
	input   [8:0]  PV,         // PIXEL V
	output         PCLK,       // PIXEL CLOCK (to VGA encoder)
	output [11:0]	POUT, 	   // PIXEL OUT

	output  [7:0]	SND,			// Sound Out


	input				ROMCL,		// Downloaded ROM image
	input  [17:0]  ROMAD,
	input   [7:0]	ROMDT,
	input				ROMEN
);

// Clocks
wire clk24M, clk12M, clk6M, clk3M;
CLKGEN clks( clk48M, clk24M, clk12M, clk6M, clk3M );

wire   VCLKx8 = clk48M;
wire   VCLKx4 = clk24M;
wire   VCLKx2 = clk12M;
wire	   VCLK = clk6M;

wire   CPUCLK = clk3M;
wire    CPUCL = ~clk3M; 


// Main
wire			CPUMX, CPUWR, VIDDV;
wire  [7:0]	CPUWD, VIDRD;
wire [15:0]	CPUAD;

MAIN cpu
(
	CPUCLK, reset,
	PH,PV,
	INP0,INP1,INP2,

	CPUMX, CPUAD,
	CPUWR, CPUWD,
	VIDDV, VIDRD,
	
	ROMCL,ROMAD,ROMDT,ROMEN
);


// Video
VIDEO vid
(
	VCLKx8, VCLKx4, VCLKx2, VCLK,
	PH, PV, 1'b0, 1'b0,
	PCLK, POUT,

	CPUCL,
	CPUMX, CPUAD,
	CPUWR, CPUWD,
	VIDDV, VIDRD,

	ROMCL,ROMAD,ROMDT,ROMEN
);


// Sound
SOUND snd
(
	clk48M, reset,
	SND,

	CPUCL,
	CPUMX, CPUAD,
	CPUWR, CPUWD
);

endmodule


//----------------------------------
//  Clock Generator
//----------------------------------
module CLKGEN
(
	input		clk48M,

	output	clk24M,
	output	clk12M,
	output	clk6M,
	output	clk3M
);
	
reg [3:0] clkdiv;
always @( posedge clk48M ) clkdiv <= clkdiv+4'd1;

assign clk24M = clkdiv[0];
assign clk12M = clkdiv[1];
assign clk6M  = clkdiv[2];
assign clk3M  = clkdiv[3];

endmodule


