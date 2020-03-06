/*-----------------------------------------------------------------------
=========================================================================
CONFIDENTIAL IN CONFIDENCE
The entire notice above must be reproduced on all authorized copies.
Author			:		Ganhuijun
Filename		:		sram_bist.v
Date			:		2020-2-13
Description		:	8k*8 sram which instance a bist module and dft	.
Modification History	:
=========================================================================
-----------------------------------------------------------------------*/
module sram_bist(
		hclk,
		sram_clk,
		sram_rst_n,
		sram_csn_in,
		sram_wen_in,
		sram_addr_in,
		sram_wdata_in,
		bist_en,
		dft_en,
		
		sram_data_out,
		bist_done,
		bist_fail
		
);

	input					hclk;
	input					sram_clk;
	input					sram_rst_n;
	input					sram_csn_in;
	input					sram_wen_in;
	input [12:0]		sram_addr_in;
	input [7:0]			sram_wdata_in;
	input					bist_en;
	input					dft_en;
	
	output [7:0]		sram_data_out;
	output				bist_done;
	output				bist_fail;
	
	wire	[7:0]			dft_data;
	reg	[7:0]			dft_data_r;
	
	wire	[12:0]		sram_addr;
	wire	[7:0]			sram_wdata;
	wire	[12:0]		sram_a;
	wire	[7:0]			sram_d;
	wire					sram_csn;
	wire					sram_wen;
	wire					sram_oen;
	
	assign dft_data = (sram_d ^ sram_a[7:0]) ^ {sram_csn, sram_wen, sram_oen, sram_a[12:8]}; 

   always @(posedge hclk or negedge sram_rst_n) begin
     if(!sram_rst_n)
       dft_data_r <= 0;
     else if(dft_en)
       dft_data_r <= dft_data;
   end
	
//	assign sram_data_out = dft_en?dft_data_r:data_out;
	
	assign sram_addr = sram_csn_in?0:sram_addr_in;
	assign sram_wdata = sram_csn_in?0:sram_wdata_in;
	
	mbist_8kx8 U_mbist_8kx8(
		.b_clk					( sram_clk ),
		.b_rst_n					( sram_rst_n ),
		.b_te						( bist_en ),
		
		.addr_fun				( sram_addr ),
		.wen_fun					( sram_wen_in ),
		.cen_fun					( sram_csn_in ),
		.oen_fun					( 1'b0 ),
		.data_fun				( sram_wdata ),
		.ram_read_out			(  ),
		
		.addr_test				( sram_a ),
		.wen_test				( sram_wen ),
		.cen_test				( sram_csn ),
		.oen_test				( sram_oen ),
		.data_test				( sram_d ),
		
		.b_done					( bist_done ),
		.b_fail					( bist_fail )
);

	sram_sp_hse_8kx8 u_sram_sp_hse_8kx8( //8K
		.Q							( data_out ),
		.CLK						( sram_clk ),
		.CEN						( sram_csn ),
		.WEN						( sram_wen ),
		.A							( sram_a ),
		.D							( sram_d ),
		.OEN						( sram_oen )
);

endmodule
