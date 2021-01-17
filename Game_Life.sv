// -----------------------Game_Life------------------------------
// This module is used to display the left lives (out of five)
// Inputs:
// (1) (DrawX, DrawY): The coordinate of the current pixel
// (2) miss_num: The number of missing fruits in the previous VGA cycle
//               Used to update the number of lifes the current cycle
//               It is only used at the frame rising edge/
// Outputs:
// (1) game_life_print_true: whether this pixel should display "heart"
// (2) game_life_color: if display, what is the color index of the pixel
// (3) game_over: when asserted, in the next VGA frame clk, we will 
//                display the "game-over" figure (stored in FLASH)
// ---------------------------------------------------------------
module Game_Life #(N = 6) (
	input logic				Clk,
	input logic				Reset,
	input logic				Initialize,
	input logic				frame_clk_rising_edge,
	input logic [9:0] 	DrawX, DrawY,
	input int				miss_num,
	output logic [N-1:0] game_life_color,
	output logic 			game_life_print_true,
	output logic         game_over
	);
	
	// ---Load the figure and edge of the heart into on-chip memory---
	localparam 		HEART_FIG    = "heart.txt";
	localparam		HEART_EDGE   = "heart_edge.txt";
	localparam 		HEART_WIDTH  = 35;
	localparam		HEART_HEIGHT = 35;
	localparam 		HEART_SIZE   = HEART_WIDTH * HEART_HEIGHT;
	localparam 		HEART_DEPTH	 = $clog2(HEART_SIZE);			// Address bits
	logic [N-1:0] 	heart_figure[HEART_SIZE];
	logic 			heart_figure_edge[HEART_SIZE];
	initial begin
		$display("Loading the figure of the heart into OCM");
		$readmemh(HEART_FIG, heart_figure);
		$display("Loading the edge of the heart into OCM");
		$readmemh(HEART_EDGE, heart_figure_edge);
	end
	// --------------------------------------------------------------
	
	// -------------------Define Local Parameters--------------------
	// center position of 5 hearts & the "radius" of the figure
	localparam HEART_WIDTH_HALF = 17;
	localparam HEART_HEIGHT_HALF = 17;
	localparam HEART_1_X = 20;
	localparam HEART_2_X = 60;
	localparam HEART_3_X = 100;
	localparam HEART_4_X = 140;
	localparam HEART_5_X = 180;
	localparam HEART_Y   = 50;
	// --------------------------------------------------------------
	
	// -------------------Define Local Variables---------------------
	int 	heart_left; 				// number of lives left
	int   heart_left_in;
	logic game_over_in;
	int 	miss_num_ff;
	int 	miss_num_in;
	// --------------------------------------------------------------
	
	// --------------always_ff (driven by 50MHz Clk)------------------
	always_ff @ (posedge Clk)
	begin
		// When reset of initialize, then reset all five lives
		if (Reset || Initialize) begin
			heart_left	 		<= 5;
			game_over    		<= 0;
			miss_num_ff 		<= 0;
		end
		else begin
			heart_left 	 		<= heart_left_in;
			game_over    		<= game_over_in;
			miss_num_ff			<= miss_num_in;
		end
	end
	// ---------------------------------------------------------------
	
	int miss_num_incre;
	assign miss_num_incre = miss_num - miss_num_ff;
	// ------------always_comb (slow-driven 60Hz frame clk)-----------
	always_comb begin
		// DEFAULT
		heart_left_in   = heart_left;
		game_over_in    = game_over;
		miss_num_in     = miss_num_ff;
		// Update the state of the heart only at the rising edge of frame clock'
		if (frame_clk_rising_edge) begin
			miss_num_in  = miss_num;
			if (heart_left > miss_num_incre ) begin
				heart_left_in = heart_left - miss_num_incre;
				game_over_in  = 0;
			end
			else begin
				heart_left_in = 0;
				game_over_in  = 1;
			end
		end
	end
	
	// ---------------Determine the color of the pixel-----------

	// Using box-check instead of circle-check to avoid DSP usage
	logic check_in_box_1;
	logic check_in_box_2;
	logic check_in_box_3;
	logic check_in_box_4;
	logic check_in_box_5;
	
	Check_In_Box check_box_inst1 (
		.DrawX(DrawX),
		.DrawY(DrawY),
		.CX(HEART_1_X),
		.CY(HEART_Y),
		.X_width(HEART_WIDTH_HALF),
		.Y_height(HEART_HEIGHT_HALF),
		.check_inside(check_in_box_1)
		);
		
	Check_In_Box check_box_inst2 (
		.DrawX(DrawX),
		.DrawY(DrawY),
		.CX(HEART_2_X),
		.CY(HEART_Y),
		.X_width(HEART_WIDTH_HALF),
		.Y_height(HEART_HEIGHT_HALF),
		.check_inside(check_in_box_2)
		);
		
	Check_In_Box check_box_inst3 (
		.DrawX(DrawX),
		.DrawY(DrawY),
		.CX(HEART_3_X),
		.CY(HEART_Y),
		.X_width(HEART_WIDTH_HALF),
		.Y_height(HEART_HEIGHT_HALF),
		.check_inside(check_in_box_3)
		);
		
	Check_In_Box check_box_inst4 (
		.DrawX(DrawX),
		.DrawY(DrawY),
		.CX(HEART_4_X),
		.CY(HEART_Y),
		.X_width(HEART_WIDTH_HALF),
		.Y_height(HEART_HEIGHT_HALF),
		.check_inside(check_in_box_4)
		);
		
	Check_In_Box check_box_inst5 (
		.DrawX(DrawX),
		.DrawY(DrawY),
		.CX(HEART_5_X),
		.CY(HEART_Y),
		.X_width(HEART_WIDTH_HALF),
		.Y_height(HEART_HEIGHT_HALF),
		.check_inside(check_in_box_5)
		);
		
	logic [HEART_DEPTH-1:0] figure_color_index;	
	
	always_comb begin
		// Defalt:
		figure_color_index = 0;
		game_life_color = 0;
		game_life_print_true = 0;
		// HEART 1:
		if (check_in_box_1) begin
			if (heart_left < 5) begin
				game_life_print_true = 0;
			end
			else begin
				figure_color_index = (DrawX-HEART_1_X+HEART_WIDTH_HALF) + (DrawY-HEART_Y+HEART_HEIGHT_HALF)*HEART_WIDTH;
				game_life_print_true = heart_figure_edge[figure_color_index];
				game_life_color = heart_figure[figure_color_index];
			end
		end
		// HEART 2:
		else if (check_in_box_2) begin
			if (heart_left < 4) begin
				game_life_print_true = 0;
			end
			else begin
				figure_color_index = (DrawX-HEART_2_X+HEART_WIDTH_HALF) + (DrawY-HEART_Y+HEART_HEIGHT_HALF)*HEART_WIDTH;
				game_life_print_true = heart_figure_edge[figure_color_index];
				game_life_color = heart_figure[figure_color_index];
			end
		end
		// HEART 3:
		else if (check_in_box_3) begin
			if (heart_left < 3) begin
				game_life_print_true = 0;
			end
			else begin
				figure_color_index = (DrawX-HEART_3_X+HEART_WIDTH_HALF) + (DrawY-HEART_Y+HEART_HEIGHT_HALF)*HEART_WIDTH;
				game_life_print_true = heart_figure_edge[figure_color_index];
				game_life_color = heart_figure[figure_color_index];
			end
		end
		// HEART 4:
		else if (check_in_box_4) begin
			if (heart_left < 2) begin
				game_life_print_true = 0;
			end
			else begin
				figure_color_index = (DrawX-HEART_4_X+HEART_WIDTH_HALF) + (DrawY-HEART_Y+HEART_HEIGHT_HALF)*HEART_WIDTH;
				game_life_print_true = heart_figure_edge[figure_color_index];
				game_life_color = heart_figure[figure_color_index];
			end
		end
		// HEART 5:
		else if (check_in_box_5) begin
			if (heart_left == 0) begin
				game_life_print_true = 0;
			end
			else begin
				figure_color_index = (DrawX-HEART_5_X+HEART_WIDTH_HALF) + (DrawY-HEART_Y+HEART_HEIGHT_HALF)*HEART_WIDTH;
				game_life_print_true = heart_figure_edge[figure_color_index];
				game_life_color = heart_figure[figure_color_index];
			end
		end		
	end
	
	
endmodule






