// -----------------------mode_control------------------------
// This module determines which backgrounds (of three) in the Flash 
// should be displayed and the mode of the game (one player or two players)
module mode_control #(fruit_index)(
		input logic Clk,
		input logic frame_clk_rising_edge,
		input logic Reset,
		input int total_cut,				// total cut number of the main mouse
		input int total_cut_second,	// total cut number of the second mouse
		input int total_miss,			// total miss number of the main mouse
		input logic mode1,				// Start background: mode1 asserted
		input logic mode2,				// Start background: mode2 asserted
		input logic back_to_start,		// End background: back to start background
		output logic next_init,			// Whether to give out fruits in the next frame clock
		output logic two_mouse,			// Whether display one or two mouse
		output logic [1:0] graph_index, // the backgrounf graph index
		input logic next_available,
		input logic [fruit_index-1:0] next_which
		);
		
	logic [1:0] graph_index_in;
	logic       two_mouse_in;
	logic 		next_init_in;
	int         wait_counter;
	int 			wait_counter_in;
	int 			Reset_counter;
	int 			Reset_counter_in;
	int total_two_mouse;

	assign total_two_mouse = total_cut + total_cut_second;
	
	always_ff @ (posedge Clk) begin
		graph_index   <= graph_index_in;
		two_mouse     <= two_mouse_in;
		next_init     <= next_init_in;
		wait_counter  <= wait_counter_in;
		Reset_counter <= Reset_counter_in;
		if (Reset) begin
		graph_index   <= 2'b00;
		two_mouse     <= 0;
		next_init     <= 0;
		wait_counter  <= 0;
		Reset_counter <= 0;		
		end
	end
	
	always_comb
	begin
		// DEFAULT
		graph_index_in   = graph_index;
		two_mouse_in     = two_mouse;
		next_init_in     = next_init;
		wait_counter_in  = wait_counter;
		Reset_counter_in = Reset_counter;
		
		// We only update the output at frame clock frequence (60Hz Clock)
		if (frame_clk_rising_edge)
		begin		
			// STARTING BACKGROUND
			if (graph_index == 2'b00) begin
				if (mode1 == 1) begin
					graph_index_in = 2'b01;
					two_mouse_in   = 0;
					next_init_in   = 0;      // Reserve a preperation time for player
					wait_counter_in= 0;
				end
				else if (mode2 == 1) begin
					graph_index_in = 2'b01;
					two_mouse_in   = 1;
					next_init_in   = 0;		 // Reserve a preperation time for player
					wait_counter_in= 0;
				end
			end
			
			// GAME BACKGROUND
			else if (graph_index == 2'b01) begin
				// Mode1: one mouse
				if (two_mouse == 0) begin
					// Game over
					if (total_miss >= 5) begin
						graph_index_in = 2'b10;
						two_mouse_in   = 0;
						next_init_in   = 0;
						wait_counter_in= 0;
					end
					// first 5 cuts are single cuts
					else if (total_cut<5)
					begin
						if (next_which > 2'd0)
						begin
							next_init_in = 0;
						end
						else
						begin
							next_init_in = 1;
						end
					end
					// 5-15 cuts are double cuts
					else if ((total_cut>=5)&& (total_cut<15))
					begin
						if (next_which > 2'd1)
						begin
							next_init_in = 0;
						end
						else
						begin
							next_init_in = 1;
						end
					end
					// 15-30 cuts are 3 cuts
					else if ((total_cut>=15)&& (total_cut<30))
					begin
						if (next_which > 2'd2)
						begin
							next_init_in = 0;
						end
						else
						begin
							next_init_in = 1;
						end
					end
					// Take a rest every 20 points after 40 cuts
					else if ((total_cut > 40) && (total_cut % 20 < 4)) begin
						wait_counter_in= wait_counter + 1;
						if (wait_counter <= 150) begin
							next_init_in = 0;
						end
						else begin
							next_init_in = 1;
						end
					end
					// ELSE
					else begin
						graph_index_in = 2'b01;
						two_mouse_in   = 0;
						next_init_in   = 1;
						wait_counter_in= 0;
					end
				end
				
				// Mode2: Two mouse
				else if (two_mouse == 1) begin
					// Game Over
					if (total_cut >= 100 || total_cut_second >= 35) begin
						graph_index_in = 2'b10;
						two_mouse_in   = 1;
						next_init_in   = 0;
						wait_counter_in= 0;
					end
					// first 5 cuts are single cuts
					else if (total_two_mouse<5)
					begin
						if (next_which > 2'd0)
						begin
							next_init_in = 0;
						end
						else
						begin
							next_init_in = 1;
						end
					end
					// 5-15 cuts are double cuts
					else if ((total_two_mouse>=5)&& (total_two_mouse<15))
					begin
						if (next_which > 2'd1)
						begin
							next_init_in = 0;
						end
						else
						begin
							next_init_in = 1;
						end
					end
					// 15-30 cuts are 3 cuts
					else if ((total_two_mouse>=15)&& (total_two_mouse<30))
					begin
						if (next_which > 2'd2)
						begin
							next_init_in = 0;
						end
						else
						begin
							next_init_in = 1;
						end
					end
					// Take a rest every 20 points after 40 cuts
					else if ((total_two_mouse > 40) && (total_two_mouse % 20 < 4)) begin
						wait_counter_in= wait_counter + 1;
						if (wait_counter <= 150) begin
							next_init_in = 0;
						end
						else begin
							next_init_in = 1;
						end
					end
					// ELSE
					else begin
						graph_index_in = 2'b01;
						two_mouse_in   = 1;
						next_init_in   = 1;
						wait_counter_in= 0;
					end
				end
			end
			
			// GAME_OVER BACKGROUND
			else if (graph_index == 2'b10) begin
				// Go back to start 
				if (back_to_start == 1) begin
					graph_index_in = 2'b00;
					two_mouse_in   = 0;
					wait_counter_in= 0;
					next_init_in   = 0;
				end
				else begin
					graph_index_in = 2'b10;
					two_mouse_in   = two_mouse;
					wait_counter_in= 0;
					next_init_in   = 0;
				end
			end
		end
	end
	
endmodule
