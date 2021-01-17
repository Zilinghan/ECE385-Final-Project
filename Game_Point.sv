// --------------------------Game_Point-----------------------------
// This module is used to display the current points of the player
// Inputs:
// (1) (DrawX, DrawY): The coordinate of the current pixel
// (2) cut_num: The number of cutting fruits in the previous VGA cycle
//					 Used to upadte the game points in the current cycle
//					 It is only used at the frame rising edge
// Outputs:
// (1) game_point_print_true: whether this pixel should display point
// (2) game_point_color: if display what is the color index of the pixel
// ------------------------------------------------------------------
module Game_Point #(NUM_INDEX_2_X, N = 6) (
	input logic 				Clk,
	input logic 				Reset,
	input logic 				Initialize,
	input	logic					frame_clk_rising_edge,
	input logic [9:0] 		DrawX, DrawY,
	input int 					cut_num,
	output logic [N-1:0] 	game_point_color,
	output logic 				game_point_print_true
	);
	
	// --------Load the figure and edge of numbers into OCM-----------
	localparam		NUM0_FIG 		= "num0.txt";
	localparam		NUM1_FIG 		= "num1.txt";
	localparam		NUM2_FIG 		= "num2.txt";
	localparam		NUM3_FIG 		= "num3.txt";
	localparam		NUM4_FIG 		= "num4.txt";
	localparam		NUM5_FIG 		= "num5.txt";
	localparam		NUM6_FIG 		= "num6.txt";
	localparam		NUM7_FIG 		= "num7.txt";
	localparam		NUM8_FIG 		= "num8.txt";
	localparam		NUM9_FIG 		= "num9.txt";
	localparam		NUM0_EDGE      = "num0_edge.txt";
	localparam		NUM1_EDGE      = "num1_edge.txt";
	localparam		NUM2_EDGE      = "num2_edge.txt";
	localparam		NUM3_EDGE      = "num3_edge.txt";
	localparam		NUM4_EDGE      = "num4_edge.txt";
	localparam		NUM5_EDGE      = "num5_edge.txt";
	localparam		NUM6_EDGE      = "num6_edge.txt";
	localparam		NUM7_EDGE      = "num7_edge.txt";
	localparam		NUM8_EDGE      = "num8_edge.txt";
	localparam		NUM9_EDGE      = "num9_edge.txt";
	localparam		NUM_WIDTH		= 51;
	localparam 		NUM_HEIGHT     = 51;
	localparam		NUM_WIDTH_HALF = 25;
	localparam		NUM_HEIGHT_HALF= 25;
	localparam		NUM_SIZE       = NUM_WIDTH * NUM_HEIGHT;
	localparam		NUM_DEPTH		= $clog2(NUM_SIZE);
	logic [N-1:0]	num0_figure	[NUM_SIZE];
	logic [N-1:0]	num1_figure	[NUM_SIZE];
	logic [N-1:0]	num2_figure	[NUM_SIZE];
	logic [N-1:0]	num3_figure	[NUM_SIZE];
	logic [N-1:0]	num4_figure	[NUM_SIZE];
	logic [N-1:0]	num5_figure	[NUM_SIZE];
	logic [N-1:0]	num6_figure	[NUM_SIZE];
	logic [N-1:0]	num7_figure	[NUM_SIZE];
	logic [N-1:0]	num8_figure	[NUM_SIZE];
	logic [N-1:0]	num9_figure	[NUM_SIZE];
	logic				num0_edge_figure [NUM_SIZE];
	logic				num1_edge_figure [NUM_SIZE];
	logic				num2_edge_figure [NUM_SIZE];
	logic				num3_edge_figure [NUM_SIZE];
	logic				num4_edge_figure [NUM_SIZE];
	logic				num5_edge_figure [NUM_SIZE];
	logic				num6_edge_figure [NUM_SIZE];
	logic				num7_edge_figure [NUM_SIZE];
	logic				num8_edge_figure [NUM_SIZE];
	logic				num9_edge_figure [NUM_SIZE];
	initial begin
		$display("Loading the figure of the numbers into OCM");
		$readmemh(NUM0_FIG, num0_figure);
		$readmemh(NUM1_FIG, num1_figure);
		$readmemh(NUM2_FIG, num2_figure);
		$readmemh(NUM3_FIG, num3_figure);
		$readmemh(NUM4_FIG, num4_figure);
		$readmemh(NUM5_FIG, num5_figure);
		$readmemh(NUM6_FIG, num6_figure);
		$readmemh(NUM7_FIG, num7_figure);
		$readmemh(NUM8_FIG, num8_figure);
		$readmemh(NUM9_FIG, num9_figure);
		$display("Loading the edge of the numbers into OCM");
		$readmemh(NUM0_EDGE, num0_edge_figure);
		$readmemh(NUM1_EDGE, num1_edge_figure);
		$readmemh(NUM2_EDGE, num2_edge_figure);
		$readmemh(NUM3_EDGE, num3_edge_figure);
		$readmemh(NUM4_EDGE, num4_edge_figure);
		$readmemh(NUM5_EDGE, num5_edge_figure);
		$readmemh(NUM6_EDGE, num6_edge_figure);
		$readmemh(NUM7_EDGE, num7_edge_figure);
		$readmemh(NUM8_EDGE, num8_edge_figure);
		$readmemh(NUM9_EDGE, num9_edge_figure);
	end
	// -----------------------------------------------------------
	
	// -----------------Define Local Parameters-------------------
	// Center Position of the numbers
	//localparam NUM_INDEX_0_X = 600;
	//localparam NUM_INDEX_1_X = 545;
	//localparam NUM_INDEX_2_X = 490;
	localparam NUM_INDEX_0_X =  NUM_INDEX_2_X+55*2;
	localparam NUM_INDEX_1_X =  NUM_INDEX_2_X+55;
	localparam NUM_INDEX_Y   = 50;
	// -----------------------------------------------------------
	
	// -----------------Define Local Variables--------------------
	// These variables are used to record which number to display
	// in the format of (X_2,X_1,X_0)
	logic [3:0] num_counter_0;
	logic [3:0] num_counter_1;
	logic [3:0] num_counter_2;
	logic [3:0] num_counter_0_in;
	logic [3:0] num_counter_1_in;
	logic [3:0] num_counter_2_in;
	int cut_num_ff;
	int cut_num_in;
	// ------------------------------------------------------------
	
	// ---------------always_ff (Driven by 50MHz)------------------
	always_ff @ (posedge Clk) begin
		// When Reset of Initialize, then set points to 000
		if (Reset || Initialize) begin
			num_counter_0 <= 0;
			num_counter_1 <= 0;
			num_counter_2 <= 0;
			cut_num_ff	  <= 0;
		end
		else begin
			num_counter_0 <= num_counter_0_in;
			num_counter_1 <= num_counter_1_in;
			num_counter_2 <= num_counter_2_in;
			cut_num_ff	  <= cut_num_in;
		end
	end
	// ------------------------------------------------------------
	
	int cut_num_incre;
	assign cut_num_incre = cut_num - cut_num_ff;
	// -----------always_comb (slow-driven 60Hz frame Clk)---------
	always_comb begin
		// DEFAULT
		num_counter_0_in = num_counter_0;
		num_counter_1_in = num_counter_1;
		num_counter_2_in = num_counter_2;
		cut_num_in       = cut_num_ff;
		// Update the counter only at the rising edge of frame clock
		if (frame_clk_rising_edge) begin
			cut_num_in = cut_num;
			// Bit-0 Overflows
			if (num_counter_0 + cut_num_incre >= 10) begin
				num_counter_0_in = cut_num_incre + num_counter_0 - 10;
				// Bit-1 Overflows
				if (num_counter_1 == 9) begin
					num_counter_1_in = 0;
					num_counter_2_in = num_counter_2 + 1;
				end
				else begin
					num_counter_1_in = num_counter_1 + 1;
					num_counter_2_in = num_counter_2;
				end
			end
			// Bit-0 Does Not Overflow
			else if (cut_num_incre > 0) begin
				num_counter_0_in = num_counter_0 + cut_num_incre;
			end
		end
	end
	// ------------------------------------------------------------
	
	// -------------Determine the color of the pixel --------------
	logic check_in_box_2;
	logic check_in_box_1;
	logic check_in_box_0;
	
	Check_In_Box check_box_inst2(
		.DrawX(DrawX),
		.DrawY(DrawY),
		.CX(NUM_INDEX_2_X),
		.CY(NUM_INDEX_Y),
		.X_width(NUM_WIDTH_HALF),
		.Y_height(NUM_HEIGHT_HALF),
		.check_inside(check_in_box_2)
		);
		
	Check_In_Box check_box_inst1(
		.DrawX(DrawX),
		.DrawY(DrawY),
		.CX(NUM_INDEX_1_X),
		.CY(NUM_INDEX_Y),
		.X_width(NUM_WIDTH_HALF),
		.Y_height(NUM_HEIGHT_HALF),
		.check_inside(check_in_box_1)
		);

	Check_In_Box check_box_inst0(
		.DrawX(DrawX),
		.DrawY(DrawY),
		.CX(NUM_INDEX_0_X),
		.CY(NUM_INDEX_Y),
		.X_width(NUM_WIDTH_HALF),
		.Y_height(NUM_HEIGHT_HALF),
		.check_inside(check_in_box_0)
		);		
		
	
	logic [NUM_DEPTH-1:0] figure_color_index;
	
	always_comb begin
		// DEFAULT
		figure_color_index = 0;
		game_point_color = 0;
		game_point_print_true = 0;
		// NUMBER 2:
		if (check_in_box_2) begin
			figure_color_index = (DrawX - NUM_INDEX_2_X + NUM_WIDTH_HALF) + (DrawY - NUM_INDEX_Y + NUM_HEIGHT_HALF)*NUM_WIDTH;
			case (num_counter_2)
				4'd0:
					begin
						game_point_print_true = num0_edge_figure[figure_color_index];
						game_point_color      = num0_figure[figure_color_index];
					end
				4'd1:
					begin
						game_point_print_true = num1_edge_figure[figure_color_index];
						game_point_color      = num1_figure[figure_color_index];
					end
				4'd2:
					begin
						game_point_print_true = num2_edge_figure[figure_color_index];
						game_point_color      = num2_figure[figure_color_index];
					end
				4'd3:
					begin
						game_point_print_true = num3_edge_figure[figure_color_index];
						game_point_color      = num3_figure[figure_color_index];
					end
				4'd4:
					begin
						game_point_print_true = num4_edge_figure[figure_color_index];
						game_point_color      = num4_figure[figure_color_index];
					end
				4'd5:
					begin
						game_point_print_true = num5_edge_figure[figure_color_index];
						game_point_color      = num5_figure[figure_color_index];
					end
				4'd6:
					begin
						game_point_print_true = num6_edge_figure[figure_color_index];
						game_point_color      = num6_figure[figure_color_index];
					end
				4'd7:
					begin
						game_point_print_true = num7_edge_figure[figure_color_index];
						game_point_color      = num7_figure[figure_color_index];
					end
				4'd8:
					begin
						game_point_print_true = num8_edge_figure[figure_color_index];
						game_point_color      = num8_figure[figure_color_index];
					end
				4'd9:
					begin
						game_point_print_true = num9_edge_figure[figure_color_index];
						game_point_color      = num9_figure[figure_color_index];
					end
			endcase
		end
		// NUMBER 1:
		else if (check_in_box_1) begin
			figure_color_index = (DrawX-NUM_INDEX_1_X+NUM_WIDTH_HALF) + (DrawY-NUM_INDEX_Y+NUM_HEIGHT_HALF)*NUM_WIDTH;
			case (num_counter_1)
				4'd0:
					begin
						game_point_print_true = num0_edge_figure[figure_color_index];
						game_point_color      = num0_figure[figure_color_index];
					end
				4'd1:
					begin
						game_point_print_true = num1_edge_figure[figure_color_index];
						game_point_color      = num1_figure[figure_color_index];
					end
				4'd2:
					begin
						game_point_print_true = num2_edge_figure[figure_color_index];
						game_point_color      = num2_figure[figure_color_index];
					end
				4'd3:
					begin
						game_point_print_true = num3_edge_figure[figure_color_index];
						game_point_color      = num3_figure[figure_color_index];
					end
				4'd4:
					begin
						game_point_print_true = num4_edge_figure[figure_color_index];
						game_point_color      = num4_figure[figure_color_index];
					end
				4'd5:
					begin
						game_point_print_true = num5_edge_figure[figure_color_index];
						game_point_color      = num5_figure[figure_color_index];
					end
				4'd6:
					begin
						game_point_print_true = num6_edge_figure[figure_color_index];
						game_point_color      = num6_figure[figure_color_index];
					end
				4'd7:
					begin
						game_point_print_true = num7_edge_figure[figure_color_index];
						game_point_color      = num7_figure[figure_color_index];
					end
				4'd8:
					begin
						game_point_print_true = num8_edge_figure[figure_color_index];
						game_point_color      = num8_figure[figure_color_index];
					end
				4'd9:
					begin
						game_point_print_true = num9_edge_figure[figure_color_index];
						game_point_color      = num9_figure[figure_color_index];
					end
			endcase
		end
		// NUMBER 0:
		else if (check_in_box_0) begin
			figure_color_index = (DrawX-NUM_INDEX_0_X+NUM_WIDTH_HALF) + (DrawY-NUM_INDEX_Y+NUM_HEIGHT_HALF)*NUM_WIDTH;
			case (num_counter_0)
				4'd0:
					begin
						game_point_print_true = num0_edge_figure[figure_color_index];
						game_point_color      = num0_figure[figure_color_index];
					end
				4'd1:
					begin
						game_point_print_true = num1_edge_figure[figure_color_index];
						game_point_color      = num1_figure[figure_color_index];
					end
				4'd2:
					begin
						game_point_print_true = num2_edge_figure[figure_color_index];
						game_point_color      = num2_figure[figure_color_index];
					end
				4'd3:
					begin
						game_point_print_true = num3_edge_figure[figure_color_index];
						game_point_color      = num3_figure[figure_color_index];
					end
				4'd4:
					begin
						game_point_print_true = num4_edge_figure[figure_color_index];
						game_point_color      = num4_figure[figure_color_index];
					end
				4'd5:
					begin
						game_point_print_true = num5_edge_figure[figure_color_index];
						game_point_color      = num5_figure[figure_color_index];
					end
				4'd6:
					begin
						game_point_print_true = num6_edge_figure[figure_color_index];
						game_point_color      = num6_figure[figure_color_index];
					end
				4'd7:
					begin
						game_point_print_true = num7_edge_figure[figure_color_index];
						game_point_color      = num7_figure[figure_color_index];
					end
				4'd8:
					begin
						game_point_print_true = num8_edge_figure[figure_color_index];
						game_point_color      = num8_figure[figure_color_index];
					end
				4'd9:
					begin
						game_point_print_true = num9_edge_figure[figure_color_index];
						game_point_color      = num9_figure[figure_color_index];
					end
			endcase
		end		
	end
	
endmodule





















