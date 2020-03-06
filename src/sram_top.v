/*-----------------------------------------------------------------------
=========================================================================
CONFIDENTIAL IN CONFIDENCE
The entire notice above must be reproduced on all authorized copies.
Author			:		Ganhuijun
Filename		:		sram_top.v
Date			:		2020-2-13
Description		:	8k*8 sram which instance a bist module and dft	.
Modification History	:
=========================================================================
-----------------------------------------------------------------------*/
module sram_top(

	hclk,
	sram_clk,
	hresetn,
	hsel,
	haddr,
	hwrite,
	hsize,
	hburst,
	htrans,
	hready,
	hwdata,
	
	dft_en,
	bist_en,
	
	hrdata,
	hready_resp,
	hresp,
	
	bist_done,
	bist_fail
	
);

	input							hclk;
	input							sram_clk;
	input							hresetn;
	input							hsel;
	input	[31:0]				haddr;
	input							hwrite;
	input	[2:0]					hsize;
	input	[2:0]					hburst;
	input	[1:0]					htrans;
	input							hready;
	input	[31:0]				hwdata;
	
	input							dft_en;
	input							bist_en;
	
	output [31:0]				hrdata;
	output						hready_resp;
	output [1:0]				hresp;
	
	output						bist_done;
	output [7:0]				bist_fail;

	wire [7:0]					sram_q0;
	wire [7:0]					sram_q1;
	wire [7:0]					sram_q2;
	wire [7:0]					sram_q3;
	wire [7:0]					sram_q4;
	wire [7:0]					sram_q5;
	wire [7:0]					sram_q6;
	wire [7:0]					sram_q7;
	wire							sram_w_en;
	wire [12:0]					sram_addr;
	wire [3:0]					bank0_csn;
	wire [3:0]					bank1_csn;
	wire [31:0]					sram_wdata;
	
ahb_slave_if U_ahb_slave_if(
			//input signals
		  .hclk							( hclk ),
		  .hresetn						( hresetn ),
        .hsel							( hsel ),
        .haddr							( haddr ),
        .hwrite						( hwrite ),
        .hsize							( hsize ),
        .hburst						( hburst ),
        .htrans						( htrans ),
        .hready						( hready ),
        .hwdata						( hwdata ),

		   //output signals
		  .hready_resp					( hready_resp ),
		  .hresp							( hresp ),
		  .hrdata						( hrdata ),

			//sram output
		  .sram_q0						( sram_q0 ),
		  .sram_q1						( sram_q1 ),
		  .sram_q2						( sram_q2 ),
		  .sram_q3						( sram_q3 ),
		  .sram_q4						( sram_q4 ),
		  .sram_q5						( sram_q5 ),
		  .sram_q6						( sram_q6 ),
		  .sram_q7						( sram_q7 ),

		  .sram_w_en					( sram_w_en ),
		  .sram_addr_out				( sram_addr ),
		  .sram_wdata					( sram_wdata ),
		  .bank0_csn					( bank0_csn ),
		  .bank1_csn					( bank1_csn )

);

sram_core U_sram_core(
		  .hclk							( hclk ),
		  .sram_clk						( sram_clk ),
		  .hresetn						( hresetn ),
		  .sram_wen						( sram_w_en ),
		  .sram_addr					( sram_addr ),
		  .sram_wdata_in				( sram_wdata ),
		  .bank0_csn					( bank0_csn ),
		  .bank1_csn					( bank1_csn ),
		  .bist_en						( bist_en ),
		  .dft_en						( dft_en ),
			
		  .sram_q0						( sram_q0 ),
		  .sram_q1						( sram_q1 ),
		  .sram_q2						( sram_q2 ),
		  .sram_q3						( sram_q3 ),
		  .sram_q4						( sram_q4 ),
		  .sram_q5						( sram_q5 ),
		  .sram_q6						( sram_q6 ),
		  .sram_q7						( sram_q7 ),
			
		  .bist_done					( bist_done ),
		  .bist_fail					( bist_fail )
);

endmodule
