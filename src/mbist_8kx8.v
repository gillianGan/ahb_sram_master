/*-----------------------------------------------------------------------
=========================================================================
CONFIDENTIAL IN CONFIDENCE
The entire notice above must be reproduced on all authorized copies.
Author			:		Ganhuijun
Filename		:		mbist_8kx8.v
Date			:		2020-2-13
Description		:	Bist test for checking sram function.
Modification History	:
=========================================================================
-----------------------------------------------------------------------*/
module mbist_8kx8#(
	parameter	WE_WIDTH = 1,
	parameter	ADDR_WIDTH = 13,
	parameter	DATA_WIDTH = 8
)(
		b_clk,
		b_rst_n,
		b_te,
		addr_fun,
		wen_fun,
		cen_fun,
		oen_fun,
		data_fun,
		ram_read_out,
		
		addr_test,
		wen_test,
		cen_test,
		oen_test,
		data_test,
		b_done,
		b_fail
);
	
	input								b_clk;
	input								b_rst_n;
	input								b_te;
	input	[ADDR_WIDTH-1:0]		addr_fun;
	input	[WE_WIDTH-1:0]			wen_fun;
	input								cen_fun;
	input								oen_fun;
	input	[DATA_WIDTH-1:0]		data_fun;
	input [DATA_WIDTH-1:0]		ram_read_out;
	
	output [ADDR_WIDTH-1:0]		addr_test;
	output [WE_WIDTH-1:0]		wen_test;
	output							cen_test;
	output							oen_test;
	output [DATA_WIDTH-1:0]		data_test;
	output							b_done;
	output reg						b_fail;
	
	reg	 [4:0]					cstate;
	reg	 [4:0]					nstate;
	
	reg								test_addr_rst;
	
	reg	[(WE_WIDTH-1):0] 		wen_test_inner;	
	reg								count_en;
	reg								up1_down0;
	reg	[(ADDR_WIDTH-1):0]   test_addr;
	reg								check_en;
	reg								pattern_sel;
	
	wire	[DATA_WIDTH-1:0]		test_pattern;
	
	assign test_pattern = (pattern_sel == 0)?{DATA_WIDTH{1'b0}}:{DATA_WIDTH{1'b1}};
	
	assign addr_test = (b_te == 1'b1) ? test_addr : addr_fun;
	assign wen_test = (b_te == 1'b1) ? wen_test_inner : wen_fun;
	assign data_test = (b_te == 1'b1) ? test_pattern : data_fun;
	assign cen_test = (b_te == 1'b1) ? 1'b0 : cen_fun;
	assign oen_test = (b_te == 1'b1) ? 1'b0 : oen_fun;
	
	always@(posedge b_clk or negedge b_rst_n)
	begin
		if(!b_rst_n)
			test_addr <= {ADDR_WIDTH{1'b0}};
		else if(b_te == 1)
			if(test_addr_rst == 1'b1)
				if(up1_down0 == 1'b1)
					test_addr <= {ADDR_WIDTH{1'b0}};
				else
					test_addr <= {ADDR_WIDTH{1'b1}};
			else
				if(count_en == 1'b1)
					if(up1_down0 === 1'b1)
						test_addr <= test_addr + 1'b1;
					else
						test_addr <= test_addr - 1'b1;
	end
	
	always@(posedge b_clk or negedge b_rst_n)
	if(!b_rst_n)
		b_fail <= 1'b0;
	else begin
		if(b_te == 1'b1 && test_pattern != ram_read_out)
			b_fail <= 1'b1;
		else
			b_fail <= 1'b0;
	end
	
	localparam IDLE1		 =  5'b00000;
	localparam P1_WRITE0   =  5'b00001;
	localparam IDLE2		 =  5'b00010;
	localparam P2_READ0 	 =  5'b00011;
	localparam P2_COMPARE0 =  5'b00100;
   localparam P2_WRITE1	 =  5'b00101;
   localparam IDLE3   	 =  5'b00110;
   localparam P3_READ1 	 =  5'b00111;
   localparam P3_COMPARE1 =  5'b01000;
   localparam P3_WRITE0   =  5'b01001;
   localparam P3_READ0    =  5'b01010;
   localparam P3_COMPARE0 =  5'b01011;
   localparam P3_WRITE1   =  5'b01100;
   localparam IDLE4       =  5'b01101;
   localparam P4_READ1    =  5'b01110;
   localparam P4_COMPARE1 =  5'b01111;
   localparam P4_WRITE0   =  5'b10000;
   localparam IDLE5       =  5'b10001;
   localparam P5_READ0    =  5'b10010;
   localparam P5_COMPARE0 =  5'b10011;
   localparam P5_WRITE1   =  5'b10100;
   localparam P5_READ1    =  5'b10101;
   localparam P5_COMPARE1 =  5'b10110;
   localparam P5_WRITE0   =  5'b10111;
   localparam IDLE6       =  5'b11000;
   localparam P6_READ0    =  5'b11001;
   localparam P6_COMPARE0 =  5'b11010;
	//------------------------------------------------------------------------------
  //                    Bist test state machine.
  //   write "0"(initial sram)                         test_address 0-->1fff
  //   read  "0"------> compare -------->write "1"     test_address 1fff-->0
  //   read  "1"------> compare -------->write "0"     test_address 0-->1fff
  //   write "1"------> read "1"-------->compare       test_address 1fff-->0        
  //   write "0"------> read "0"-------->compare       test_address 0-->1fff        
  //   write "1"------> read "1"-------->compare       test_address 1fff-->0        
  //   write "0"------> read "0"-------->compare       test_address 0-->1fff        
  //------------------------------------------------------------------------------

//-----------------------------------------
// FSM: always1
	always@(posedge b_clk or negedge b_rst_n)
		if(!b_rst_n)
			cstate <= IDLE1;
		else if( b_te )
			cstate <= nstate;
		else
			cstate <= cstate;
			
//-----------------------------------------
// FSM: always2
	always@(*)
		begin
			nstate = IDLE1;
			case(cstate)
			IDLE1	:
				if( b_te )		nstate = P1_WRITE0;
				else				nstate = IDLE1;
			P1_WRITE0 : // 0~1fff
				if( test_addr == {ADDR_WIDTH{1'b1}} )		nstate = IDLE2;
				else												nstate = P1_WRITE0;
			IDLE2	:
				nstate = P2_READ0;
			P2_READ0	:  //1fff~0
				nstate = P2_COMPARE0;
			P2_COMPARE0	:
				nstate = P2_WRITE1;
			P2_WRITE1 : //1fff~0
				if( test_addr == {ADDR_WIDTH{1'b0}} )		nstate = IDLE3;
				else												nstate = P2_READ0;
			IDLE3	:
				nstate = P3_READ1;
			P3_READ1	:  //1fff~0
				nstate = P3_COMPARE1;
			P3_COMPARE1	:
				nstate = P3_WRITE0;
			P3_WRITE0	:
				nstate = P3_READ0;
			P3_READ0	:
				nstate = P3_COMPARE0;
			P3_COMPARE0	:
				nstate = P3_WRITE1;
			P3_WRITE1	: //0~1fff
				if( test_addr == {ADDR_WIDTH{1'b1}} )		nstate = IDLE4;
				else												nstate = P3_READ1;
			IDLE4	:
				nstate = P4_READ1;
			P4_READ1	:
				nstate = P4_COMPARE1;
			P4_COMPARE1	:
				nstate = P4_WRITE0;
			P4_WRITE0	: //0_1fff
				if( test_addr == {ADDR_WIDTH{1'b1}} )		nstate = IDLE5;
				else												nstate = P4_READ1;
			IDLE5	:
				nstate = P5_READ0;
			P5_READ0	:
				nstate = P5_COMPARE0;
			P5_COMPARE0	:
				nstate = P5_WRITE1;
			P5_WRITE1	:
				nstate = P5_READ1;
			P5_READ1	:
				nstate = P5_COMPARE1;
			P5_COMPARE1	:
				nstate = P5_WRITE0;
			P5_WRITE0	:
				if( test_addr == {ADDR_WIDTH{1'b1}} )		nstate = IDLE6;
				else												nstate = P5_READ0;
			IDLE6	:
				nstate = P6_READ0;
			P6_READ0	:
				nstate = P6_COMPARE0;
			P6_COMPARE0	:
				if( test_addr == {ADDR_WIDTH{1'b1}} )		nstate = IDLE1;
				else												nstate = P6_READ0;
			default:
				nstate = IDLE1;
			endcase
		end

//-----------------------------------------
// FSM: always3
	always@( posedge b_clk or negedge b_rst_n )	
	begin
		if( !b_rst_n ) begin
			count_en 				<= 1'b0;
			test_addr_rst			<= 1'b0;
			up1_down0				<= 1'b0;
			pattern_sel				<= 1'b0;
			wen_test_inner 		<= {WE_WIDTH{1'b1}};
		end
		case( cstate )
			IDLE1	: //0~1fff
				begin
					count_en <= 1'b0;
					test_addr_rst <= 1'b1; 
					wen_test_inner <= {WE_WIDTH{1'b1}};
					up1_down0 <= 1'b0;
				end
			P1_WRITE0 :
				begin
					count_en <= 1'b1;
					test_addr_rst <= 1'b1; 
					wen_test_inner <= {WE_WIDTH{1'b0}};
					up1_down0 <= 1'b1;
				end
			IDLE2	: //1fff~0
				begin
					count_en <= 1'b0;
					test_addr_rst <= 1'b1; 
					wen_test_inner <= {WE_WIDTH{1'b1}};
					up1_down0 <= 1'b0;
				end
		//	P2_READ0	:
			P2_COMPARE0	:
					pattern_sel <= 1'b0;
			P2_WRITE1 :
				begin
					count_en <= 1'b1;
					test_addr_rst <= 1'b1; 
					wen_test_inner <= {WE_WIDTH{1'b0}};
					up1_down0 <= 1'b0;
				end
			IDLE3	: //0~1fff
				begin
					count_en <= 1'b0;
					test_addr_rst <= 1'b1; 
					wen_test_inner <= {WE_WIDTH{1'b1}};
					up1_down0 <= 1'b0;
				end
			//P3_READ1	:
			P3_COMPARE1	:
					pattern_sel <= 1'b1;
			P3_WRITE0 :
				begin
					count_en <= 1'b1;
					test_addr_rst <= 1'b1; 
					wen_test_inner <= {WE_WIDTH{1'b0}};
					up1_down0 <= 1'b1;
				end
			//P3_READ0	:
			P3_COMPARE0	:
					pattern_sel <= 1'b0;
			P3_WRITE1 :
				begin
					count_en <= 1'b1;
					test_addr_rst <= 1'b1; 
					wen_test_inner <= {WE_WIDTH{1'b0}};
					up1_down0 <= 1'b1;
				end
			IDLE4	: //1fff~0
				begin
					count_en <= 1'b0;
					test_addr_rst <= 1'b1; 
					wen_test_inner <= {WE_WIDTH{1'b1}};
					up1_down0 <= 1'b0;
				end
			//P4_READ1	:
			P4_COMPARE1	:
					pattern_sel <= 1'b1;
			P4_WRITE0 :
				begin
					count_en <= 1'b1;
					test_addr_rst <= 1'b1; 
					wen_test_inner <= {WE_WIDTH{1'b0}};
					up1_down0 <= 1'b0;
				end
			IDLE5	: //0~1fff
				begin
					count_en <= 1'b0;
					test_addr_rst <= 1'b1; 
					wen_test_inner <= {WE_WIDTH{1'b1}};
					up1_down0 <= 1'b0;
				end
			//P5_READ0	:
			P5_COMPARE0	:
					pattern_sel <= 1'b1;
			P5_WRITE1 :
				begin
					count_en <= 1'b1;
					test_addr_rst <= 1'b1; 
					wen_test_inner <= {WE_WIDTH{1'b0}};
					up1_down0 <= 1'b1;
				end
			//P5_READ1	:
			P5_COMPARE1	:
					pattern_sel <= 1'b1;
			P5_WRITE0 :
				begin
					count_en <= 1'b1;
					test_addr_rst <= 1'b1; 
					wen_test_inner <= {WE_WIDTH{1'b0}};
					up1_down0 <= 1'b0;
				end
			IDLE6	: //1fff~0
				begin
					count_en <= 1'b0;
					test_addr_rst <= 1'b1; 
					wen_test_inner <= {WE_WIDTH{1'b1}};
					up1_down0 <= 1'b0;
				end
			///P6_READ0	:
			P6_COMPARE0	:
				begin
					count_en <= 1'b1;
					test_addr_rst <= 1'b1; 
					up1_down0 <= 1'b0;
					pattern_sel <= 1'b0;
				end
			default:
				begin
					count_en <= 1'b0;
					test_addr_rst <= 1'b0;
					wen_test_inner <= {WE_WIDTH{1'b1}};	
					up1_down0 <= 1'b0;
					pattern_sel <= 1'b0;
				end
			endcase
	end
	
endmodule
