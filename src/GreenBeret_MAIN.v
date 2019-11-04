/********************************************************************
	FPGA Implimentation of "Green Beret" & "Mr.Goemon" (Main Part)
*********************************************************************/
// Copyright (c) 2013,19 MiSTer-X

module MAIN
(
	input				CPUCL,
	input				RESET,

	input   [8:0]	PH,
	input   [8:0]	PV,

	input   [5:0]	INP0,
	input   [5:0]	INP1,
	input   [2:0]	INP2,

	output			CPUMX,
	output [15:0]	CPUAD,
	output			CPUWR,
	output  [7:0]	CPUWD,

	input				VIDDV,
	input   [7:0]	VIDRD,
	

	input				DLCL,
	input  [17:0]  DLAD,
	input   [7:0]	DLDT,
	input				DLEN
);

//
// Z80 SoftCore
//
wire [7:0] CPUID;
wire cpu_irq, cpu_nmi;
wire iCPUMX,iCPUWR;

T80s z80(
	.CLK_n(CPUCL),
	.RESET_n(~RESET),
	.A(CPUAD),
	.DI(CPUID),
	.DO(CPUWD),
	.INT_n(~cpu_irq),
	.NMI_n(~cpu_nmi),
	.MREQ_n(iCPUMX),
	.WR_n(iCPUWR),
	.BUSRQ_n(1'b1),
	.WAIT_n(1'b1)
);

assign CPUMX = ~iCPUMX;
assign CPUWR = ~iCPUWR;


//
// Instruction ROMs (Banked)
//
wire [2:0] ROMBK;
wire [7:0] ROMDT;
wire 		  ROMDV;
wire		  MODE;
MAIN_ROM irom( ~CPUCL,CPUMX,CPUAD,ROMBK,ROMDV,ROMDT, MODE, DLCL,DLAD,DLDT,DLEN ); 


//
// Input Ports (HID & DIPSWs)
//
wire CS_ISYS = (CPUAD[15:0] == 16'hF603) & CPUMX;
wire CS_IP01 = (CPUAD[15:0] == 16'hF602) & CPUMX;
wire CS_IP02 = (CPUAD[15:0] == 16'hF601) & CPUMX;
wire CS_DSW1 = (CPUAD[15:0] == 16'hF600) & CPUMX;
wire CS_DSW2 = (CPUAD[15:8] ==  8'hF2  ) & CPUMX;
wire CS_DSW3 = (CPUAD[15:8] ==  8'hF4  ) & CPUMX;

`include "HIDDEF.i"
wire [7:0]	ISYS = ~{`none,`none,`none,`P2ST,`P1ST,`none,`none,`COIN};
wire [7:0]	IP01 = ~{`none,`none,`P1TB,`P1TA,`P1DW,`P1UP,`P1RG,`P1LF};
wire [7:0]	IP02 = ~{`none,`none,`P2TB,`P2TA,`P2DW,`P2UP,`P2RG,`P2LF};

wire [7:0]	DSWD;
DIPSWs dsws( ~CPUCL, CPUAD[10:9], DSWD, MODE );

//
// CPU Input Data Selector
//
assign CPUID =	VIDDV   ? VIDRD :
					ROMDV   ? ROMDT :
					CS_ISYS ? ISYS  : 
					CS_IP01 ? IP01  :
					CS_IP02 ? IP02  :
					CS_DSW1 ? DSWD  :
					CS_DSW2 ? DSWD  :
					CS_DSW3 ? DSWD  :
					8'h00;


//
// Interrupt Generator & ROM Bank Selector
//
IRQGEN irqg(
	RESET,PH,PV,
	CPUCL,CPUAD,CPUWD,CPUMX & CPUWR,
	cpu_irq,cpu_nmi,
	ROMBK
);


endmodule


module IRQGEN
(
	input 			RESET,
	input	 [8:0]	PH,
	input	 [8:0]	PV,

	input 			CPUCL,
	input [15:0]	CPUAD,
	input  [7:0]	CPUWD,
	input				CPUWE,

	output reg		cpu_irq,
	output reg		cpu_nmi,

	output reg [2:0] ROMBK
);
	

wire CS_FSCW = (CPUAD[15:0] == 16'hE044) & CPUWE;
wire CS_CCTW = (CPUAD[15:0] == 16'hF000) & CPUWE;

reg  [2:0] irqmask;
reg  [8:0] tick;
wire [8:0] irqs = (~tick) & (tick+9'd1);
reg  [8:0] pPV;
reg		  sync;

always @( negedge CPUCL ) begin
	if (RESET) begin
		ROMBK   <= 0;
		irqmask <= 0;
		cpu_nmi <= 0;
		cpu_irq <= 0;
		tick    <= 0;
		pPV     <= 1;
		sync    <= 1;
	end
	else begin
		if ( CS_CCTW ) ROMBK <= CPUWD[7:5];
		if ( CS_FSCW ) begin
			irqmask <= CPUWD[2:0];
			if (~CPUWD[0]) cpu_nmi <= 0;
			if (~CPUWD[1]) cpu_irq <= 0;
			else if (~CPUWD[2]) cpu_irq <= 0;
		end
		else if (pPV != PV) begin
			if (PV[3:0]==0) begin
				if (sync & (PV==9'd0)) begin tick <= 9'd0; sync <= 0; end
				else tick <= (tick+9'd1);
				cpu_nmi <= irqs[0] & irqmask[0];
				cpu_irq <=(irqs[3] & irqmask[1]) | (irqs[4] & irqmask[2]);
				pPV <= PV;
			end
		end
	end
end

endmodule


module DIPSWs
(
	input					CL,
	input	[1:0]			AD,
	output reg [7:0]	DT,

	input					MODE
);
// DIPSWs Setting of "Green Beret"
`define GB_DSW1	8'hFF
`define GB_DSW2	8'h4A
`define GB_DSW3	8'h0F

// DIPSWs Setting of "Mr.Goemon"
`define MG_DSW1	8'hFF
`define MG_DSW2	8'h5A
`define MG_DSW3	8'h0F

always @( posedge CL ) begin
	case (AD)
		2'd3: DT <= MODE ? `MG_DSW1 : `GB_DSW1;
		2'd1: DT <= MODE ? `MG_DSW2 : `GB_DSW2;
		2'd2: DT <= MODE ? `MG_DSW3 : `GB_DSW3;
		default: DT <= 8'hxx;
	endcase
end
endmodule

