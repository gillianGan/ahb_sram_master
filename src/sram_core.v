/*-----------------------------------------------------------------------
=========================================================================
CONFIDENTIAL IN CONFIDENCE
The entire notice above must be reproduced on all authorized copies.
Author			:		Ganhuijun
Filename		:		sram_core.v
Date			:		2020-2-13
Description		:	8k*8 sram which instance a bist module and dft	.
Modification History	:
=========================================================================
-----------------------------------------------------------------------*/
module sram_core(
	hclk,
	sram_clk,
	hresetn,
	sram_wen,
	sram_addr,
	sram_wdata_in,
	bank0_csn,
	bank1_csn,
	bist_en,
	dft_en,
	
	sram_q0,
	sram_q1,
	sram_q2,
	sram_q3,
	sram_q4,
	sram_q5,
	sram_q6,
	sram_q7,
	
	bist_done,
	bist_fail
);

	input							hclk;
	input							sram_clk;
	input							hresetn;
	input							sram_wen;
	input	[12:0]				sram_addr;
	input [31:0]				sram_wdata_in;
	input [3:0]					bank0_csn;
	input	[3:0]					bank1_csn;
	input							bist_en;
	input							dft_en;
	
	output [7:0]				sram_q0;
	output [7:0]				sram_q1;
	output [7:0]				sram_q2;
	output [7:0]				sram_q3;
	output [7:0]				sram_q4;
	output [7:0]				sram_q5;
	output [7:0]				sram_q6;
	output [7:0]				sram_q7;
	
	output						bist_done;
	output [7:0]				bist_fail;
	
	wire							bist_fail0,bist_fail1,bist_fail2,bist_fail3,
									bist_fail4,bist_fail5,bist_fail6,bist_fail7;
	wire							bist_done0,bist_done1,bist_done2,bist_done3,
									bist_done4,bist_done5,bist_done6,bist_done7;
	
	assign bist_fail = {bist_fail7,bist_fail6,bist_fail5,bist_fail4,bist_fail3,bist_fail2,bist_fail1,bist_fail0};
	
	assign bist_done = bist_done0 && bist_done1 && bist_done2 && bist_done3 &&
							 bist_done4 && bist_done5 && bist_done6 && bist_done7;
	
	sram_bist U_sram_bist0(
		.hclk								( hclk ),
		.sram_clk						( sram_clk ),
		.sram_rst_n						( hresetn ),
		.sram_csn_in					( bank0_csn[0] ),
		.sram_wen_in					( sram_wen ),
		.sram_addr_in					( sram_addr ),
		.sram_wdata_in					( sram_wdata_in[7:0] ),
		.bist_en							( bist_en ),
		.dft_en							( dft_en ),
		
		.sram_data_out					( sram_q0 ),
		.bist_done						( bist_done0 ),
		.bist_fail						( bist_fail0 )
		
	);

	sram_bist U_sram_bist1(
		.hclk								( hclk ),
		.sram_clk						( sram_clk ),
		.sram_rst_n						( hresetn ),
		.sram_csn_in					( bank0_csn[1] ),
		.sram_wen_in					( sram_wen ),
		.sram_addr_in					( sram_addr ),
		.sram_wdata_in					( sram_wdata_in[15:8] ),
		.bist_en							( bist_en ),
		.dft_en							( dft_en ),
		
		.sram_data_out					( sram_q1 ),
		.bist_done						( bist_done1 ),
		.bist_fail						( bist_fail1 )
		
	);
	
	sram_bist U_sram_bist2(
		.hclk								( hclk ),
		.sram_clk						( sram_clk ),
		.sram_rst_n						( hresetn ),
		.sram_csn_in					( bank0_csn[2] ),
		.sram_wen_in					( sram_wen ),
		.sram_addr_in					( sram_addr ),
		.sram_wdata_in					( sram_wdata_in[23:16] ),
		.bist_en							( bist_en ),
		.dft_en							( dft_en ),
		
		.sram_data_out					( sram_q2 ),
		.bist_done						( bist_done2 ),
		.bist_fail						( bist_fail2 )
		
	);
	
	sram_bist U_sram_bist3(
		.hclk								( hclk ),
		.sram_clk						( sram_clk ),
		.sram_rst_n						( hresetn ),
		.sram_csn_in					( bank0_csn[3] ),
		.sram_wen_in					( sram_wen ),
		.sram_addr_in					( sram_addr ),
		.sram_wdata_in					( sram_wdata_in[31:24] ),
		.bist_en							( bist_en ),
		.dft_en							( dft_en ),
		
		.sram_data_out					( sram_q3 ),
		.bist_done						( bist_done3 ),
		.bist_fail						( bist_fail3 )
		
	);
	
	sram_bist U_sram_bist4(
		.hclk								( hclk ),
		.sram_clk						( sram_clk ),
		.sram_rst_n						( hresetn ),
		.sram_csn_in					( bank1_csn[0] ),
		.sram_wen_in					( sram_wen ),
		.sram_addr_in					( sram_addr ),
		.sram_wdata_in					( sram_wdata_in[7:0] ),
		.bist_en							( bist_en ),
		.dft_en							( dft_en ),
		
		.sram_data_out					( sram_q4 ),
		.bist_done						( bist_done4 ),
		.bist_fail						( bist_fail4 )
		
	);
	
	sram_bist U_sram_bist5(
		.hclk								( hclk ),
		.sram_clk						( sram_clk ),
		.sram_rst_n						( hresetn ),
		.sram_csn_in					( bank1_csn[1] ),
		.sram_wen_in					( sram_wen ),
		.sram_addr_in					( sram_addr ),
		.sram_wdata_in					( sram_wdata_in[15:8] ),
		.bist_en							( bist_en ),
		.dft_en							( dft_en ),
		
		.sram_data_out					( sram_q5 ),
		.bist_done						( bist_done5 ),
		.bist_fail						( bist_fail5 )
		
	);
	
	sram_bist U_sram_bist6(
		.hclk								( hclk ),
		.sram_clk						( sram_clk ),
		.sram_rst_n						( hresetn ),
		.sram_csn_in					( bank1_csn[2] ),
		.sram_wen_in					( sram_wen ),
		.sram_addr_in					( sram_addr ),
		.sram_wdata_in					( sram_wdata_in[23:16] ),
		.bist_en							( bist_en ),
		.dft_en							( dft_en ),
		
		.sram_data_out					( sram_q6 ),
		.bist_done						( bist_done6 ),
		.bist_fail						( bist_fail6 )
		
	);
	
	sram_bist U_sram_bist7(
		.hclk								( hclk ),
		.sram_clk						( sram_clk ),
		.sram_rst_n						( hresetn ),
		.sram_csn_in					( bank1_csn[3] ),
		.sram_wen_in					( sram_wen ),
		.sram_addr_in					( sram_addr ),
		.sram_wdata_in					( sram_wdata_in[31:24] ),
		.bist_en							( bist_en ),
		.dft_en							( dft_en ),
		
		.sram_data_out					( sram_q7 ),
		.bist_done						( bist_done7 ),
		.bist_fail						( bist_fail7 )
		
	);

endmodule
