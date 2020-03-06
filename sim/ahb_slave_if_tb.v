module ahb_slave_if_tb;
	
	reg                   	hclk;
   reg                   	hresetn;
	reg							hsel;
	reg [31:0]					haddr;
	reg							hwrite;
	reg [2:0]					hsize;
	reg [2:0]					hburst;
	reg [1:0]					htrans;
	reg							hready;
	reg [31:0]					hwdata;
	
	wire							hready_resp;
	wire[1:0]					hresp;
	wire[31:0]					hrdata;
	
	reg [7:0]					sram_q0;
	reg [7:0]					sram_q1;
	reg [7:0]					sram_q2;
	reg [7:0]					sram_q3;
	reg [7:0]					sram_q4;
	reg [7:0]					sram_q5;
	reg [7:0]					sram_q6;
	reg [7:0]					sram_q7;

	wire							sram_w_en;
	wire[31:0]					sram_wdata;
	wire[12:0]					sram_addr_out;
	wire[3:0]					bank0_csn;
	wire[3:0]					bank1_csn;
	
	reg [31:0]					data_rt;
	
	 ahb_slave_if ahb_slave_if(
			//input signals
		  .hclk						( hclk ),
		  .hresetn					( hresetn ),
        .hsel						( hsel ),
        .haddr						( haddr ),
        .hwrite					( hwrite ),
        .hsize						( hsize ),
        .hburst					( hburst ),
        .htrans					( htrans ),
        .hready					( hready ),
        .hwdata					( hwdata ),

		   //output signals
		  .hready_resp				( hready_resp ),
		  .hresp						( hresp ),
		  .hrdata					( hrdata ),

			//sram input signals 
		  .sram_q0					( sram_q0 ),
		  .sram_q1					( sram_q1 ),
		  .sram_q2					( sram_q2 ),
		  .sram_q3					( sram_q3 ),
		  .sram_q4					( sram_q4 ),
		  .sram_q5					( sram_q5 ),
		  .sram_q6					( sram_q6 ),
		  .sram_q7					( sram_q7 ),
			
			//sram output signals 
		  .sram_w_en				( sram_w_en ),
		  .sram_addr_out			( sram_addr_out ),
		  .sram_wdata				( sram_wdata ),
		  .bank0_csn				( bank0_csn ),
		  .bank1_csn				( bank1_csn )
);

	parameter 		 IDLE		= 2'b00;
   parameter       BUSY		= 2'b01;
   parameter       NONSEQ	= 2'b10;
   parameter       SEQ		= 2'b11;
			 
	initial begin
		hclk = 0;
		forever
		begin
			#10 hclk = ~hclk;
		end
	end
	
	initial begin
		hclk = 0;
		hresetn = 0;
		hsel = 0;
		haddr = 0;
		hwrite = 0;
		hsize = 0;
		htrans = 0;
		hready = 0;
		hwdata = 0;
		#100;
                hresetn = 1;
                write_t(32'h00001, 32'h123af);
                write_t(32'h00002,32'h12345);
                write_t(32'h00003,32'h23456);
                write_t(32'h00004,32'h34567);
                hsel = 1;
                haddr = 32'h00005;
                hwrite = 1;
                hsize = 2'b10;
                htrans = NONSEQ;
                hready = 1'b0;
                #20;
                hwdata = 32'h45678;
                write_t(32'h00006,32'h567890);
					 write_t(32'h00007,32'h678901);
                #100;
                read_t(32'h00001,data_rt);
                read_t(32'h00001,data_rt);
                read_t(32'h00002,data_rt);
                read_t(32'h00003,data_rt);
                read_t(32'h00004,data_rt);
					 hsel = 1;
                haddr = 32'h00005;
                hwrite = 0;
                hsize = 2'b10;
                htrans = NONSEQ;
                hready = 1'b0;
					 #20;
					 read_t(32'h00006,data_rt);
                read_t(32'h00007,data_rt);

	   #100;
	   //$finish;
		$stop;
	end
	
	task write_t(input [31:0] addr_wt , input [31:0]	data_wt );
	begin
		@(posedge hclk)
			hsel = 1;
			haddr = addr_wt;
			hwrite = 1;
			hsize = 2'b10;
			htrans = NONSEQ;
			hready = 1'b1;
		@(posedge hclk)
			hwdata = data_wt;
	end
	endtask
	
	task read_t(input [31:0] addr_rt ,output [31:0]	data_rt );
	begin
		@(posedge hclk)
			hsel = 1;
			haddr = addr_rt;
			hwrite = 0;
			hsize = 2'b10;
			htrans = NONSEQ;
			hready = 1'b1;
		@(posedge hclk)
			sram_q0 = 0;
			sram_q1 = 1;
			sram_q2 = 2;
			sram_q3 = 3;
			sram_q4 = 4;
			sram_q5 = 5;
			sram_q6 = 6;
			sram_q7 = 7;
			data_rt = hrdata;
	end
	endtask
	
	
	
endmodule
