//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Shamas Armar
// 
// Create Date: 05.09.2023 10:50:31
// Design Name: AXI Lite Master
// Module Name: axi_lite_master
// Project Name: UART_LED_Controller_PLD
// Target Devices: Artix 7 Evaluation Board
// Tool Versions: Xilinx 2023.1
//////////////////////////////////////////////////////////////////////////////////

module axi_lite_master(
   //Global signals
   input            	i_axi_aclk_100MHZ,
   input            	i_axi_rst_n,
   input 				i_axi_interrupt,
   //DIP Switch input
   input [3:0]			i_dip_status,
   //read address channel
   input            	i_axi_arready,
   output reg [3:0] 	o_axi_araddr,
   output reg       	o_axi_arvalid,
   //Read data channels
   input [31:0]       	i_axi_rdata,
   input              	i_axi_rvalid,
   input [1:0]        	i_axi_rresp,
   output reg      	  	o_axi_rready,
   //write address channel
   input           		i_axi_awready,
   output reg [31:0]	o_axi_awaddr,
   output reg         	o_axi_awvalid,
   //write data channel
   output reg [31:0]  	o_axi_wdata,
   output reg [3:0]    	o_axi_wstrb,
   output reg           o_axi_wvalid,
   input            	i_axi_wready,
   //write response channel
   input            	i_axi_bvalid,
   input[1:0]       	i_axi_bresp,
   output reg          	o_axi_bready,
   //output signals	
   output reg [2:0] 	o_mode,
   output reg [3:0] 	o_data_out,
   output reg 			o_data_valid
);

reg [135:0] str				= "PLEASE ENTER MODE";
reg [7:0]	str_enter		= 8'ha;
reg [7:0] char_counter		= 0;
reg		  initiaiise_flag	= 0;

//Flags
reg [3:0] axi_master_state;
reg 	  setup             = 0;
reg 	  led_flag			= 0;
reg [2:0] counter			= 3'd0;
reg 	  done_write		= 0;

 

// States of FSM
parameter IDLE              = 4'd1;
parameter PLACE_ADDR_DATA   = 4'd2;
parameter CHECK_AWREADY     = 4'd3;
parameter CHECK_WREADY      = 4'd4;
parameter SET_BREADY        = 4'd5;
parameter PLACE_READ_ADDR   = 4'd6;
parameter CHECK_ARREADY     = 4'd7;
parameter READ_DECODE       = 4'd8;
parameter CHECK_STATUS_REG  = 4'd9;
parameter WAIT_READ_INTR    = 4'd10;
parameter CHECK_BRESP       = 4'd11;


// FSM States Description and driving conditions
always @(posedge i_axi_aclk_100MHZ)
	begin
		if(i_axi_rst_n == 0)
		begin
			axi_master_state 	<= 	IDLE;
			o_mode			= 	2'b00;
			o_data_out		= 	4'b0000;
			o_axi_awaddr	= 	32'h0;
			o_axi_awvalid	=	0;
			o_axi_wdata		=	32'h0;
			o_axi_wstrb		=	4'd0;
			o_axi_bready	=	0;
			o_axi_araddr	=	32'h0;
			o_data_valid	=	0;
			o_axi_rready	=	0;
			o_axi_arvalid	=	0;
			o_axi_wvalid	=	0;
		end
		else
		begin
			case(axi_master_state)
				IDLE				:	begin
											//Initialising values to write into control register
											o_axi_araddr				<=	32'h00;
											axi_master_state 			<= PLACE_ADDR_DATA;
										end
				PLACE_ADDR_DATA 	:	begin
											o_axi_awvalid				<= 	1;
											o_axi_wvalid				<=	1;
											if(!initiaiise_flag && setup)
											begin
												o_axi_awaddr 			<= 	32'h04;
												case(char_counter)
												8'd0 	: o_axi_wdata 	<= str [ 135 : 128 ];
												8'd1 	: o_axi_wdata 	<= str [ 127 : 120 ];
												8'd2 	: o_axi_wdata 	<= str [ 119 : 112 ];
												8'd3 	: o_axi_wdata 	<= str [ 111 : 104 ];
												8'd4 	: o_axi_wdata 	<= str [ 103 : 96 ];
												8'd5 	: o_axi_wdata 	<= str [ 95 : 88 ];
												8'd6 	: o_axi_wdata 	<= str [ 87 : 80 ];
												8'd7 	: o_axi_wdata 	<= str [ 79 : 72 ];
												8'd8 	: o_axi_wdata 	<= str [ 71 : 64 ];
												8'd9 	: o_axi_wdata 	<= str [ 63 : 56 ];
												8'd10 	: o_axi_wdata 	<= str [ 55 : 48 ];
												8'd11 	: o_axi_wdata 	<= str [ 47 : 40 ];
												8'd12 	: o_axi_wdata 	<= str [ 39 : 32 ];
												8'd13 	: o_axi_wdata 	<= str [ 31 : 24 ];
												8'd14 	: o_axi_wdata 	<= str [ 23 : 16 ];
												8'd15 	: o_axi_wdata 	<= str [ 15 : 8 ];
												8'd16 	: o_axi_wdata 	<= str [ 7 : 0 ];	
												8'd17 	: o_axi_wdata 	<= str_enter[7:0];												
												endcase
											end
												//Mode 5 write
											else if(initiaiise_flag && setup) begin
												o_axi_awaddr 			<= 	32'h04;
												o_axi_wdata				<=	i_dip_status + 'h30;
											end
											else begin
												o_axi_awaddr 			<= 	32'h0c;			
												o_axi_wdata				<=	32'h10;
											end
											o_axi_wstrb					<=	4'b1111;
											
											// Placing dipswitch data in transmitter FIFO
											if(setup && i_axi_awready && i_axi_wready)
												begin
												axi_master_state		<=	SET_BREADY;
												end
											else if((!setup) && i_axi_awready && i_axi_wready)
											
											//Initialising the communication
												begin
												axi_master_state		<=	SET_BREADY;
												end
											else if	(i_axi_wready)
												axi_master_state		<=	CHECK_AWREADY;
											else if(i_axi_awready)
												axi_master_state		<=	CHECK_WREADY;
											else axi_master_state 		<= axi_master_state;
										end
				CHECK_AWREADY		:	begin
											if(i_axi_wready)
											begin
												axi_master_state		<=	SET_BREADY;
												o_axi_awvalid			<=	1'b0;
											end
											else axi_master_state 		<= axi_master_state;
										end
				CHECK_WREADY		:	begin
											if(i_axi_awready)
											begin
												axi_master_state		<=	SET_BREADY;
												o_axi_wvalid			<=	1'b0;
											end
											else axi_master_state 		<= axi_master_state;
										end
				SET_BREADY			:	begin
											o_axi_bready 				<= 	1'b1;
											o_axi_awvalid				<=	1'b0;
											o_axi_wvalid				<=	1'b0;
											if(setup && i_axi_bvalid)
												//Write mode - 5 (DIP Switch)
												begin
												axi_master_state 		<= 	CHECK_BRESP;
												end
											else if ((!setup) && i_axi_bvalid)
												begin
												//Read Status register process
													axi_master_state	<=	PLACE_READ_ADDR;
												end
											else axi_master_state 		<= axi_master_state;
										end
				PLACE_READ_ADDR		:	begin
										if(setup && initiaiise_flag)
											begin
												o_axi_araddr			<=	32'h0;//RX_FIFO address
												o_axi_arvalid			<= 	1'b1;
												axi_master_state		<=	CHECK_ARREADY;
											end
										else
											begin
											//Read Status register process
												o_axi_araddr			<=	32'h08;//STAT_REG Address
												o_axi_arvalid			<= 1'b1;
												o_axi_bready			<= 0;
												axi_master_state		<=	CHECK_ARREADY;
											end
										end
				CHECK_ARREADY		:	begin
											if(setup && i_axi_arready) //&& o_axi_arvalid)
												begin
												axi_master_state		<=	READ_DECODE;
												o_axi_arvalid			<=	1'b0;
												o_axi_rready			<=	1;
												end
											else if((!setup) && i_axi_arready) // && o_axi_arvalid)
												//On start setup flow
												begin
												axi_master_state		<=	CHECK_STATUS_REG;
												o_axi_arvalid			<=	1'b0;
												o_axi_rready			<=	1;
												end
											else axi_master_state 		<= axi_master_state;
										end

				READ_DECODE			:	begin
                       //ASCII hex values of 1,2,3,4
											if((led_flag) || ((!led_flag) && i_axi_rvalid && (i_axi_rdata == 32'h31 || i_axi_rdata == 32'h32 || i_axi_rdata == 32'h33 || i_axi_rdata == 32'h34)))
												//Modes 1,2,3,4 -> LED controller module
												begin
													if(!led_flag)
													begin
														counter 		<= 0;
														o_mode 			<=	i_axi_rdata[2:0];
													end
													led_flag <= 1'b1;
													counter 			<= 	counter + 1;
													axi_master_state	<=	WAIT_READ_INTR;
													o_axi_rready		<=	0;
												end
											//ASCII hex value of 5
											else if(i_axi_rdata == 32'h35 & i_axi_rvalid)
											//Write mode -> DIP switch status
											begin
												axi_master_state		<=	PLACE_ADDR_DATA;
												o_mode 					<=	i_axi_rdata[2:0];
												o_axi_rready			<=	0;
											end
											else if(i_axi_rdata == 32'hd && i_axi_rvalid )
											begin
												axi_master_state		<=	PLACE_ADDR_DATA;
												initiaiise_flag			<=	0;
											end
											else if(i_axi_rdata > 32'h35 & i_axi_rvalid)
												//Requires new input
												begin
												axi_master_state		<=	WAIT_READ_INTR;
												o_axi_rready	<=	0;
												end
											else axi_master_state 		<= axi_master_state;


										if(counter == 'd2 && i_axi_rvalid)
												begin
													o_data_out			<=	i_axi_rdata[3:0] - 'h30;
													o_data_valid		<=	1;
												end
										end
				CHECK_STATUS_REG	:	begin
											if(i_axi_rdata[4] == 1 && i_axi_rvalid)
											begin
												setup					<=	1;
												axi_master_state		<=	PLACE_ADDR_DATA;
												o_axi_rready			<=  1'b0;
											end
											else if(i_axi_rdata[4] != 1 && i_axi_rvalid)
												axi_master_state		<=	IDLE;
											else axi_master_state		<=	axi_master_state;
										end
				WAIT_READ_INTR		:	begin
											o_data_valid				<=	0;
											if(done_write && i_axi_interrupt)
											begin
												axi_master_state   		<= axi_master_state;
												done_write				<=	1'b0;
											end
											else if(i_axi_interrupt && counter == 3'd3)
											// Mode(space)Data inputs completed
											begin
												led_flag				<=	0;
												counter					<=	0;
												axi_master_state		<=	PLACE_READ_ADDR;
											end
											else if(i_axi_interrupt && (counter < 3'd3)																	)
											//Data collection after mode select
												axi_master_state		<=	PLACE_READ_ADDR;
											else if (i_axi_interrupt && initiaiise_flag)
											axi_master_state 			<= READ_DECODE; 
										else
											axi_master_state   <= axi_master_state;
										end
				CHECK_BRESP			:	begin
                                        if(!initiaiise_flag && setup && i_axi_bresp == 2'b00 && i_axi_bvalid)
										begin
											char_counter				<=	char_counter + 1;
											o_axi_bready				<= 	0;

											if(char_counter == 17)
												begin
												initiaiise_flag			<= 	1;
												char_counter			<=	0;
												done_write				<=	1'b1;
                                                o_axi_bready			<= 0;
												axi_master_state		<=	WAIT_READ_INTR;
												end
											else
												axi_master_state		<=	PLACE_ADDR_DATA;
										end

										else if(initiaiise_flag && i_axi_bresp == 2'b00 && i_axi_bvalid)
										begin
											done_write					<=	1'b1;
											o_axi_bready				<= 0;
											axi_master_state			<=	WAIT_READ_INTR;
										end
										else
										begin
											done_write					<=	1'b0;
											o_axi_bready	        	<= 0;
											axi_master_state			<=	PLACE_ADDR_DATA;
										end
										end
			endcase
		end
	end
endmodule	
