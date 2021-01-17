module frame_buffer #(FB_WIDTH, FB_HEIGHT, FB_DATAW, FB_ADDRW)(
    input logic Clk,
    input logic VGA_CLK,
    input logic [9:0] DrawX, DrawY,
    output logic mode_counter,
    input logic [15:0] Data_to_SRAM,
	output logic [FB_ADDRW-1:0] fb_addr,   // Read/Write address of SRAM
	output logic [7:0]  VGA_R,        //VGA Red
						VGA_G,        //VGA Green
						VGA_B,        //VGA Blue
	// SRAM Interface
	output logic        SRAM_CE_N,    //SRAM Chip Enable
	output logic        SRAM_UB_N,    //SRAM Upper Byte Enable
	output logic        SRAM_LB_N,    //SRAM Lower Byte Enable
	output logic        SRAM_OE_N,    //SRAM Output Enable
	output logic        SRAM_WE_N,    //SRAM Write Enable
	output logic [19:0] SRAM_ADDR,    //SRAM Address
	inout  wire  [15:0] SRAM_DQ      //SRAM Data
);

	// ---------------------Declararion of Local Variables--------------------
	//                  Things may need modification:
	// FB_DARAW: Depend on how many colors (in bits) we use in the palette
    // size of the frame buffer
	localparam H_RES_FULL = 800;
	localparam V_RES_FULL = 525;
	localparam FB_PIXELS  = FB_WIDTH * FB_HEIGHT;

	// ---------------------Declaration of Internal Data----------------------
	//                    No need to modify the following part               //
	// fb_addr: FF. Address counter, ranging from 0 to (640*480-1)           //
	// fb_addr_in: Comb                                                      //
	// fb_active: Comb. Indicate whether or not to provide contorl signals   //
	// 		to SRAM in the current VGA cycle.                                //
	// frame_start: Comb. Indicate a new drwaing frame will start in next    //
	//      VGA cycle. Namely, (DrawX, DrwaY) = (798, 524)                   //
	// frame_first: Comb. Indicate it is the first active VGA cycle. Namely, //
	//		(DrawX, DrawY) = (799, 524)                                      //
	// mode_counter: FF. It is used to indicate the operation in current     //
	//		50MHz Clk cycle. 0: read, 1: write. It is refreshed by Clk.      //
	// mode_counter_in: Comb.												 //
	// buffer_read_id: FF. It is used to indicated which buffer is used to   //
	//		be read for VGA display. 0: read from buffer 0 and write to      //
	// 		buffer 1. 1: read from buffer 1 and write to buffer 0. It is     //
	//		refreshed every frame clk (60Hz). Practically, we can invert it  //
	//      whenever frame_start is asserted and drive it via VGA clk.       //
	// buffer_read_id_in: Comb                                               //
	logic [FB_ADDRW-1:0] fb_addr_in;
	logic fb_active;       													 //
	logic frame_start;                                                       //
	logic frame_first;                                                       //
	logic mode_counter_in;                                                   //
	logic buffer_read_id_in;                                                 //
	logic buffer_read_id;                                                    //
    logic CE_in, UB_in, LB_in, OE_in, WE_in;

	// My thinking of timing issues for data reading:
	// When reading from SRAM, the data will first pass through the
	// tri-state buffer (for 1 Clk cycle) and the goes here for VGA
	// (another 1 Clk cycle). So we need totally 1 VGA_CLK cycle to 
	// obtain the data from SRAM. So we begin the reading 1 VGA_CLK
	// unit ahead. Namely, we send the "memory-read-control-signals"
	// When:
	// (DrawX, DrawY) = (799,524)->(0,0)->(1,0)->(2,0)...->(638,0)
	// Then the data will available at:
	// (DrwaX, DrawY) = (0,0)->(1,0)->(2,0)->...(639,0)

	// --------------------Assign Value for Internal Data---------------------
	assign fb_active = ((DrawX+1) < FB_WIDTH && DrawY < FB_HEIGHT) || ((DrawX+1) == H_RES_FULL && (DrawY+1)%V_RES_FULL < FB_HEIGHT);
	assign frame_start = ((DrawX+2) == H_RES_FULL) && ((DrawY+1) == V_RES_FULL);
	assign frame_first = ((DrawX+1) == H_RES_FULL) && ((DrawY+1) == V_RES_FULL);

	// --------------Update Control Signals to SRAM (always_ff)---------------
	//                      VGA CLK Driven Update                            //
	// fb_addr: Increment by one for each cycle when frame buffer is active  //
	// buffer_read_id: Invert only once for each frame (1/60s)               //
	always_ff @ (posedge VGA_CLK) begin                                      //
	    fb_addr        <= fb_addr_in;                                          //
		buffer_read_id <= buffer_read_id_in;                                   //
	end																							  //
	//                    50 MHz Clk Driven Update                           //
	always_ff @ (posedge Clk) begin                                          //                                         
		SRAM_CE_N      <= CE_in;                                               //
		SRAM_UB_N      <= UB_in;                                               //
		SRAM_LB_N      <= LB_in;                                               //
		SRAM_OE_N      <= OE_in;                                               //
		SRAM_WE_N      <= WE_in;                                               //
		mode_counter   <= mode_counter_in;                                     //
	end                                                                      //

	// -------------Update Control Signals to SRAM (always_comb)--------------
	always_comb begin                                                        //
		// Default                                                             //
		fb_addr_in        = fb_addr;                                           //
		mode_counter_in   = mode_counter;                                      //
		buffer_read_id_in = buffer_read_id;                                    //
		CE_in             = 1'b1;                                              //
		UB_in             = 1'b1;                                              //
		LB_in             = 1'b1;                                              //
		OE_in             = 1'b1;                                              //
		WE_in             = 1'b1;                                              //
		SRAM_ADDR         = fb_addr;                                           //
		// When frame_start is asserted                                        //
		if (frame_start) begin                                                 //
			mode_counter_in   = 1'b0;                                           //
			buffer_read_id_in = ~buffer_read_id;                                //
		end
		// When fb_active is asserted                                          //
		else if (fb_active) begin
			if (frame_first)
				fb_addr_in = 0;													
			else
				fb_addr_in = fb_addr + 1;
			// READING
			if (mode_counter == 1'b0) begin
				CE_in = 1'b0;
				UB_in = 1'b0;
				LB_in = 1'b0;
				OE_in = 1'b0;
				WE_in = 1'b1;
				mode_counter_in = 1'b1;
				// BUFFER 0 READING
				if (buffer_read_id == 1'b0)
					SRAM_ADDR = fb_addr;
				// BUFFER 1 READING
				else 
					SRAM_ADDR = fb_addr + FB_PIXELS;
			end
			// WRITING
			else begin
				CE_in = 1'b0;
				UB_in = 1'b0;
				LB_in = 1'b0;
				OE_in = 1'b1;
				WE_in = 1'b0;
				mode_counter_in = 1'b0;
				// BUFFER 1 WRITING
				if (buffer_read_id == 1'b0)
					SRAM_ADDR = fb_addr + FB_PIXELS;
				// BUFFER 0 WRTING
				else
					SRAM_ADDR = fb_addr;
			end
		end
	end	
    	 
	// A Remark:
	// What the above codes do is setting up the interface between the FPGA and
	// the "Double Frame Buffers" in SRAM. So till now, what we should do to 
	// write data into SRAM is simply: Fill the color into Data_to_SRAM.
	// Similarly, what we should do to read the data from SRAM and display it 
	// via VGA is simply feeding Data_from_SRAM to our color look up table.    
    
    // -----------------------------------------------------------------------
	// Interface between the FPGA and SRAM: We need a tri-state buffer
	// then we can obtain the data from the memory in each pixel clk
	logic [15:0] Data_from_SRAM;  // This the data we need!!
	tristate #(.N(16)) tr0(
		.Clk(Clk),
		.tristate_output_enable(~SRAM_WE_N),
		.Data_write(Data_to_SRAM),
		.Data_read(Data_from_SRAM),
		.Data(SRAM_DQ)
	);

	// Use the Palette (CLUT) to match the data to color
	CLUT #(.N(FB_DATAW)) palette0(
		.color_idx(Data_from_SRAM[FB_DATAW-1:0]),
		.DrawX(DrawX),
		.DrawY(DrawY),
		.VGA_R(VGA_R),
		.VGA_G(VGA_G),
		.VGA_B(VGA_B)
	);

endmodule