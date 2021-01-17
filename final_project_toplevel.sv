module final_project_toplevel(
    input CLOCK_50,
    input [3:0] KEY,
    output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7,
    // CY7C67200 Interface
    inout  wire  [15:0] OTG_DATA,     //CY7C67200 Data bus 16 Bits
    output logic [1:0]  OTG_ADDR,     //CY7C67200 Address 2 Bits
    output logic        OTG_CS_N,     //CY7C67200 Chip Select
                        OTG_RD_N,     //CY7C67200 Write
                        OTG_WR_N,     //CY7C67200 Read
                        OTG_RST_N,    //CY7C67200 Reset
    input [1:0]         OTG_INT,      //CY7C67200 Interrupt
    // SDRAM Interface for Nios II Software
    output logic [12:0] DRAM_ADDR,    //SDRAM Address 13 Bits
    inout  wire  [31:0] DRAM_DQ,      //SDRAM Data 32 Bits
    output logic [1:0]  DRAM_BA,      //SDRAM Bank Address 2 Bits
    output logic [3:0]  DRAM_DQM,     //SDRAM Data Mast 4 Bits
    output logic        DRAM_RAS_N,   //SDRAM Row Address Strobe
                        DRAM_CAS_N,   //SDRAM Column Address Strobe
                        DRAM_CKE,     //SDRAM Clock Enable
                        DRAM_WE_N,    //SDRAM Write Enable
                        DRAM_CS_N,    //SDRAM Chip Select
                        DRAM_CLK,      //SDRAM Clock
    // VGA Interface 
	output logic [7:0]  VGA_R,        //VGA Red
						VGA_G,        //VGA Green
						VGA_B,        //VGA Blue
	output logic        VGA_CLK,      //VGA Clock
						VGA_SYNC_N,   //VGA Sync signal
						VGA_BLANK_N,  //VGA Blank signal
						VGA_VS,       //VGA virtical sync signal
						VGA_HS, 		 //VGA horizontal sync signal
	// SRAM Interface
	output logic        SRAM_CE_N,    //SRAM Chip Enable
	output logic        SRAM_UB_N,    //SRAM Upper Byte Enable
	output logic        SRAM_LB_N,    //SRAM Lower Byte Enable
	output logic        SRAM_OE_N,    //SRAM Output Enable
	output logic        SRAM_WE_N,    //SRAM Write Enable
	output logic [19:0] SRAM_ADDR,    //SRAM Address
	inout  wire  [15:0] SRAM_DQ,      //SRAM Data
    // FLASH Interface
    input wire [7:0]    FL_DQ,        //FLASH Data
    output logic [22:0] FL_ADDR,      //FLASH Address
    output logic        FL_CE_N,      //FLASH Chip Enable
    output logic        FL_OE_N,      //FLASH Output Enable
    output logic        FL_WE_N,      //FLASH Write Enable
    output logic        FL_RESET_N,   //FLASH Hardware Reset
    output logic        FL_WP_N,      //FLASH Hardware Write Protect
    input logic         FL_RY,        //FLASH Ready
	// PS2 Interface
	inout wire PS2_CLK,
	inout wire PS2_DAT,
	inout wire PS2_CLK2,
	inout wire PS2_DAT2,
    // Others
    output logic [17:0] LEDR,
	output logic [8:0] LEDG,
	input logic [17:0] SW
    );

    logic Reset_h, Clk;    
    assign Clk = CLOCK_50;
    always_ff @ (posedge Clk)
    begin
        Reset_h <= ~(KEY[0]);        // The push buttons are active low
    end

	// Detecting the rising edge of frame_Clk: the time when all pixels
	// update their values. Every modification of the fruit coordinates
	// only occurs when frame_clk_rising_edge is asserted
    logic frame_clk;
	logic frame_clk_delayed;
	logic frame_clk_rising_edge;
    assign frame_clk = VGA_VS;
	always_ff @ (posedge Clk) begin
		frame_clk_delayed <= frame_clk;
		frame_clk_rising_edge <= (frame_clk == 1'b1) && (frame_clk_delayed == 1'b0);
	end

    // mouse
	logic two_mouse;
	logic is_mouse, is_mouse_second;
    logic [7:0] mouse_usb_click; //middle, right, left
    logic [15:0] mouse_usb_x, mouse_usb_y;
	logic [2:0] mouse_ps2_click; //left, right, middle
	int mouse_ps2_x, mouse_ps2_y;

	mouse mouse_inst(
		.Clk(Clk),
		.Reset_h(Reset_h),
		.VGA_VS(VGA_VS),
		.KEY(KEY),
		.DrawX(DrawX),
		.DrawY(DrawY),
		.two_mouse(two_mouse),
		.mouse_usb_click(mouse_usb_click),
		.mouse_usb_x(mouse_usb_x),
		.mouse_usb_y(mouse_usb_y),
		.is_mouse_second(is_mouse_second),
		.PS2_CLK(PS2_CLK),
		.PS2_DAT(PS2_DAT),
		.PS2_CLK2(PS2_CLK2),
		.PS2_DAT2(PS2_DAT2),
		.mouse_ps2_click(mouse_ps2_click),
		.mouse_ps2_x(mouse_ps2_x),
		.mouse_ps2_y(mouse_ps2_y),
		.is_mouse(is_mouse)
	);

    // SOC
	final_project_soc final_project_soc_instance(
        .clk_clk(Clk),
        .reset_reset_n(KEY[0]),
        .sdram_wire_addr(DRAM_ADDR),
        .sdram_wire_ba(DRAM_BA),
        .sdram_wire_cas_n(DRAM_CAS_N),
        .sdram_wire_cke(DRAM_CKE),
        .sdram_wire_cs_n(DRAM_CS_N),
        .sdram_wire_dq(DRAM_DQ),
        .sdram_wire_dqm(DRAM_DQM),
        .sdram_wire_ras_n(DRAM_RAS_N),
        .sdram_wire_we_n(DRAM_WE_N),
        .sdram_clk_clk(DRAM_CLK),
        .cy7c67200_INT(OTG_INT[0]),
        .cy7c67200_DATA(OTG_DATA),
        .cy7c67200_RST_N(OTG_RST_N),
        .cy7c67200_ADDR(OTG_ADDR),
        .cy7c67200_CS_N(OTG_CS_N),
        .cy7c67200_RD_N(OTG_RD_N),
        .cy7c67200_WR_N(OTG_WR_N),
        .mouse_click_export(mouse_usb_click),
        .mouse_x_export(mouse_usb_x),
        .mouse_y_export(mouse_usb_y)
    );

    // ------------------VGA Controllers-------------------
    //                  No need to modify the following codes
    // Generate 25MHz clock to control VGA
	vga_clk vga_clk_instance(.inclk0(Clk), .c0(VGA_CLK));

	logic [9:0] DrawX, DrawY;
	VGA_controller vga_controller_instance(.Reset(Reset_h),.*);	 

	// Frame Buffer
	localparam FB_WIDTH   = 640;
	localparam FB_HEIGHT  = 480;
	localparam FB_DATAW  = 6;       // Meaningful bits out of 16 (which represents colors)
	// localparam FB_ADDRW  = $clog2(FB_PIXELS);
	localparam FB_ADDRW  = 20;		// SRAM has data width 20

	logic [15:0] Data_to_SRAM;
	logic mode_counter;
	logic [FB_ADDRW-1:0] fb_addr;

	frame_buffer #(.FB_WIDTH(FB_WIDTH),.FB_HEIGHT(FB_HEIGHT),.FB_DATAW(FB_DATAW),.FB_ADDRW(FB_ADDRW)) frame_buffer_inst(
		.Clk(Clk),
		.VGA_CLK(VGA_CLK),
		.DrawX(DrawX),
		.DrawY(DrawY),
		.mode_counter(mode_counter),
		.Data_to_SRAM(Data_to_SRAM),
		.fb_addr(fb_addr),
		.VGA_R(VGA_R),
		.VGA_G(VGA_G),
		.VGA_B(VGA_B),
		.SRAM_CE_N(SRAM_CE_N),
		.SRAM_UB_N(SRAM_UB_N),
		.SRAM_LB_N(SRAM_LB_N),
		.SRAM_OE_N(SRAM_OE_N),
		.SRAM_WE_N(SRAM_WE_N),
		.SRAM_ADDR(SRAM_ADDR),
		.SRAM_DQ(SRAM_DQ)
	);

    // FLASH
    assign FL_CE_N = 1'b0;
    assign FL_OE_N = 1'b0;
    assign FL_WE_N = 1'b1;
    assign FL_RESET_N = 1'b1;
    assign FL_WP_N = 1'bz;
	//assign FL_ADDR = {3'b0,fb_addr};

	// Top level control logic
	logic next_init;
	logic [1:0] graph_index;
	
	mode_control #(.fruit_index(fruit_index)) mode_control_inst (
			.Clk(Clk),
			.Reset(Reset_h),
			.frame_clk_rising_edge(frame_clk_rising_edge),
			.total_cut(total_cut),
			.total_cut_second(total_cut_second),
			.total_miss(total_miss),
			.mode1(mouse_ps2_click[2]),
			.mode2(mouse_ps2_click[1]),
			.back_to_start(mouse_ps2_click[0]),
			.next_init(next_init),
			.two_mouse(two_mouse),
			.graph_index(graph_index),
			.next_available(next_available),
			.next_which(next_which)
	);
	 
	localparam FLASH_offset1 = 307200;
	localparam FLASH_offset2 = 614400;
	
	always_comb begin
		FL_ADDR = {3'b0, fb_addr};
		if (graph_index == 2'b00) begin
			FL_ADDR = {3'b0,fb_addr};
		end
		else if (graph_index == 2'b01) begin
			FL_ADDR = {3'b0,fb_addr+FLASH_offset1};
		end
		else if (graph_index == 2'b10) begin
			FL_ADDR = {3'b0,fb_addr+FLASH_offset2};
		end
	end

    // the color of next pixel
	always_comb begin
        if (is_mouse)
            begin
                Data_to_SRAM = 6'h06; // FCFCFC in palette
            end
        else if (is_mouse_second)
            begin
                Data_to_SRAM = 6'h1e; // EAAA2B in palette
            end		
        else if (fruit_print_true)
            begin
                Data_to_SRAM = fruit_color;
            end
        else if (half1_print_true)
            begin
                Data_to_SRAM = half1_color;
            end
        else if (half2_print_true)
            begin
                Data_to_SRAM = half2_color;
            end
		else if ((2'd00!=graph_index) && game_point_print_true) 
			begin
				Data_to_SRAM = game_point_color;
			end
		else if ((2'd00!=graph_index) && (1'd0 == two_mouse) && (game_life_print_true))
			begin
				Data_to_SRAM = game_life_print_true;
			end
		else if ((2'd00!=graph_index) && two_mouse && game_point_second_print_true) 
			begin
				Data_to_SRAM = game_point_second_color;
			end
        else
            begin
                Data_to_SRAM = FL_DQ[FB_DATAW-1:0];
            end
    end

    logic [15:0] random_number;
    LFSR random_number_generator_16_bit(.Clk(Clk),.load(Reset_h),.seed({mouse_ps2_y[7:0],mouse_ps2_x[7:0]}),.random_number(random_number));

	// fruit_core
    localparam fruit_number = 4; // need to change the print_checker, count_list, next_finder manually
    localparam fruit_index = $clog2(fruit_number); // need to change mode_control manually
	int total_cut, total_cut_second, total_miss;
    logic [fruit_number-1:0] [1:0] states; // 00 not exists, 01 fruit, 10 two halves, 11 one halves
    logic fruit_print_true, half1_print_true, half2_print_true; // whether to print
    logic [FB_DATAW-1:0] fruit_color, half1_color, half2_color;
    logic next_available;
	logic [fruit_index-1:0] next_which;

	fruit_core #(.FB_DATAW(FB_DATAW),.fruit_number(fruit_number), .fruit_index(fruit_index), .FB_WIDTH(FB_WIDTH), .FB_HEIGHT(FB_HEIGHT)) fruit_core_inst(
		.Clk(Clk),
		.Reset_h(Reset_h),
		.frame_clk_rising_edge(frame_clk_rising_edge),
		.DrawX(DrawX),
		.DrawY(DrawY),
		.mode_counter(mode_counter),
		.next_init(next_init),
		.graph_index(graph_index),
		.is_mouse(is_mouse),
		.is_mouse_second(is_mouse_second),
		.mouse_usb_click(mouse_usb_click[2:0]),
		.random_number(random_number),
		.total_cut(total_cut),
		.total_cut_second(total_cut_second),
		.total_miss(total_miss),
		.states(states),
		.fruit_print_true(fruit_print_true),
		.half1_print_true(half1_print_true),
		.half2_print_true(half2_print_true),
		.fruit_color(fruit_color),
		.half1_color(half1_color),
		.half2_color(half2_color),
		.next_available(next_available),
		.next_which(next_which)
	);

	// point and life print	
	logic [FB_DATAW-1:0] 	game_life_color;
	logic 					game_life_print_true;
	logic 					game_over;
	logic [FB_DATAW-1:0]	game_point_color, game_point_second_color;
	logic					game_point_print_true, game_point_second_print_true;
	
	Game_Life #(.N(FB_DATAW)) game_life_inst (
			.Clk(Clk),
			.Reset(Reset_h),
			.Initialize((2'd00==graph_index)),
			.frame_clk_rising_edge(frame_clk_rising_edge),
			.DrawX(DrawX),
			.DrawY(DrawY),
			.miss_num(total_miss),
			.game_life_color(game_life_color),
			.game_life_print_true(game_life_print_true),
			.game_over(game_over)
			);
			
	Game_Point #(.NUM_INDEX_2_X(490),.N(FB_DATAW)) game_point_right (
			.Clk(Clk),
			.Reset(Reset_h),
			.Initialize((2'd00==graph_index)),
			.frame_clk_rising_edge(frame_clk_rising_edge),
			.DrawX(DrawX),
			.DrawY(DrawY),
			.cut_num(total_cut),
			.game_point_color(game_point_color),
			.game_point_print_true(game_point_print_true)
			);

	Game_Point #(.NUM_INDEX_2_X(50),.N(FB_DATAW)) game_point_left (
			.Clk(Clk),
			.Reset(Reset_h),
			.Initialize((2'd00==graph_index)),
			.frame_clk_rising_edge(frame_clk_rising_edge),
			.DrawX(DrawX),
			.DrawY(DrawY),
			.cut_num(total_cut_second),
			.game_point_color(game_point_second_color),
			.game_point_print_true(game_point_second_print_true)
			);

	// hex and LED
	int left_hex;

	always_comb
		begin
		unique case(two_mouse)
			1'b0: left_hex = total_miss;
			1'b1: left_hex = total_cut_second;
		endcase
	end

	HexDriver HexDriver1(total_cut[3:0],HEX0);
    HexDriver HexDriver2(total_cut[7:4],HEX1);
    HexDriver HexDriver3(total_cut[11:8],HEX2);
    HexDriver HexDriver4(total_cut[15:12],HEX3);
    HexDriver HexDriver5(left_hex[3:0],HEX4);
    HexDriver HexDriver6(left_hex[7:4],HEX5);
    HexDriver HexDriver7(left_hex[11:8],HEX6);
    HexDriver HexDriver8(left_hex[15:12],HEX7);

	assign LEDR[1:0] = states[0][1:0];
	assign LEDR[3:2] = states[1][1:0];
	assign LEDR[5:4] = states[2][1:0];
	assign LEDR[7:6] = states[3][1:0];
	assign LEDR[8] = two_mouse;
	assign LEDR[9] = next_init;
	assign LEDR[11:10] = graph_index;
	assign LEDR[13:12] = next_which;
	assign LEDR[14] = next_init && next_available;
	assign LEDR[17:15] = mouse_usb_click[2:0];

	assign LEDG[2:0] = mouse_ps2_click;

	// test code
	//assign two_mouse = SW[0];
	//assign next_init = run_halt;
	//assign graph_index = 2'd0;

	//logic run_halt, run_halt_in;

	//always_ff @(posedge Clk)
	//begin
	//	if (Reset_h)
	//	begin
	//		run_halt <= 1'b0;
	//	end
	//	else
	//	begin
	//		run_halt <= run_halt_in;
	//	end
	//end

	//always_comb
	//begin
	//	run_halt_in = run_halt;
	//	if (~KEY[1])
	//	begin
	//		run_halt_in = 1'b1;
	//	end
	//	if (~KEY[2])
	//	begin
	//		run_halt_in = 1'b0;
	//	end
	//end
	
endmodule
