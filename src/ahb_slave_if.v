/*-----------------------------------------------------------------------
=========================================================================
CONFIDENTIAL IN CONFIDENCE
The entire notice above must be reproduced on all authorized copies.
Author			:		Ganhuijun
Filename		:		ahb_slave_if.v
Date			:		2020-2-13
Description		:		connect the sram controller into AHB bus 	generate sram control signals 64K.
Modification History	:
=========================================================================
-----------------------------------------------------------------------*/

module ahb_slave_if(
			//input signals
		  hclk,
		  hresetn,
        hsel,
        haddr,
        hwrite,
        hsize,
        hburst,
        htrans,
        hready,
        hwdata,

		   //output signals
		  hready_resp,
		  hresp,
		  hrdata,

			//sram input signals
		  sram_q0,
		  sram_q1,
		  sram_q2,
		  sram_q3,
		  sram_q4,
		  sram_q5,
		  sram_q6,
		  sram_q7,
			
			//sram output signals
		  sram_w_en,
		  sram_addr_out,
		  sram_wdata,
		  bank0_csn,
		  bank1_csn

);
   input                   hclk;
   input                   hresetn;
	input							hsel;
	input	[31:0]				haddr;
	input							hwrite;
	input [2:0]					hsize;
	input [2:0]					hburst;
	input	[1:0]					htrans;
	input							hready;
	input	[31:0]				hwdata;
	
	output						hready_resp;
	output[1:0]					hresp;
	output[31:0]				hrdata;
	
	input	[7:0]					sram_q0;
	input	[7:0]					sram_q1;
	input	[7:0]					sram_q2;
	input	[7:0]					sram_q3;
	input	[7:0]					sram_q4;
	input	[7:0]					sram_q5;
	input	[7:0]					sram_q6;
	input	[7:0]					sram_q7;

	output 						sram_w_en;
	output[31:0]				sram_wdata;
	output[12:0]				sram_addr_out;//sram is 1ffff bit space 16位
	output[3:0]					bank0_csn;
	output[3:0]					bank1_csn;

	wire	[31:0]				sram_data_out;
	wire							bank_sel;
	wire  [1:0]					hsize_sel;
	wire  [1:0]					haddr_sel;
	wire							sram_csn_en;
	wire							sram_read;
	wire							sram_write;
	reg   [31:0]				haddr_r;
	reg	[3:0]					sram_csn;
	
	parameter	IDLE = 2'b00;
	parameter	BUSY = 2'b01;
	parameter	NONSEQ = 2'b10;
	parameter	SEQ = 2'b1;
	
	assign sram_data_out = (bank_sel)?{sram_q3,sram_q2,sram_q1,sram_q0}:
												 {sram_q7,sram_q6,sram_q5,sram_q4};

	assign bank_sel = ( sram_csn_en && haddr_r[15] == 0)?1'b1:1'b0; //ADDR[15]
	
	assign hrdata = sram_data_out;

	assign hresp = 2'b00; //OKEY
	assign hready_resp = 1'b1;
	
	assign bank0_csn = (bank_sel == 0)?sram_csn:4'b1111;
	assign bank1_csn = (bank_sel == 1)?sram_csn:4'b1111;
	
	assign sram_read = (htrans == NONSEQ || htrans == SEQ) && !hwrite;
	assign sram_write = (htrans == NONSEQ || htrans == SEQ) && hwrite;
	assign sram_csn_en = (sram_read || sram_write);

	assign sram_w_en = !sram_write;
	
	always@(posedge hclk or negedge hresetn)
	if(!hresetn)
		haddr_r <= 0;
	else
		haddr_r <= haddr;

	assign sram_addr_out = haddr_r[12:0];
	
	assign hsize_sel = hsize[1:0];
	assign haddr_sel = haddr_r[14:13];
	
	always@(haddr_sel or hsize_sel)
	if(hsize_sel == 2'b10) //32bit
		sram_csn <= 4'b0;
	else if(hsize_sel == 2'b01) //16bit
		if(haddr_sel[1] == 0)
			sram_csn <= 4'b1100;
		else
			sram_csn <= 4'b0011;
	else if(hsize_sel == 2'b00) begin //8bit
		case(haddr_sel)
			2'b00:sram_csn <= 4'b1110;
			2'b01:sram_csn <= 4'b1101;
			2'b10:sram_csn <= 4'b1011;
			2'b11:sram_csn <= 4'b0111;
			default:;
		endcase
	end
	else
		sram_csn <= 4'b1111;
		
	assign sram_wdata = hwdata;

endmodule
