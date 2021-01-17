module fruit_core #(FB_DATAW, fruit_number, fruit_index, FB_WIDTH, FB_HEIGHT)(
        input logic Clk,
        input logic Reset_h,
        input logic frame_clk_rising_edge,
        input logic [9:0] DrawX, DrawY,
        input logic mode_counter,
        input logic next_init, // whether generate a new fruit
        input logic [1:0] graph_index, // which background
        input logic is_mouse, is_mouse_second, // whether current (DrawX, DrawY) is ps2 or usb mouse
        input logic [2:0] mouse_usb_click,
        input logic [15:0] random_number,
        output int total_cut, total_cut_second, total_miss, // number of fruits cut or missed
        output logic [fruit_number-1:0] [1:0] states, // states of fruits, 00 not exists, 01 fruit, 10 two halves, 11 one halves
		// whether current (DrawX, DrawY) is fruit, left half or right half and its color
        output logic fruit_print_true, half1_print_true, half2_print_true,
        output logic [FB_DATAW-1:0] fruit_color, half1_color, half2_color,
        output logic next_available, // whether it's able to generate a new fruit
	    output logic [fruit_index-1:0] next_which // the index of next new fruit
    );

    localparam type_number = 4; // need to change the loading of on chip memory (edge, draw) and related mux depending on the type manually
    localparam type_index = $clog2(type_number);
    localparam FRUIT_WIDTH = 63;
	localparam FRUIT_HEIGHT = 63;
    localparam FRUIT_WIDTH_HALF = 31;
	localparam FRUIT_HEIGHT_HALF = 31;
	localparam FRUIT_SIZE = FRUIT_WIDTH * FRUIT_HEIGHT;
    localparam FRUIT_DEPTH = $clog2(FRUIT_SIZE);
    
    logic [fruit_number-1:0] [1:0] states_in;
    logic [type_index-1:0] types [fruit_number];
    logic [type_index-1:0] types_in [fruit_number];
    
    logic fruit_init [fruit_number];
    logic half1_init [fruit_number];
    logic half2_init [fruit_number];
    logic fruit_init_in [fruit_number];
    logic half1_init_in [fruit_number];
    logic half2_init_in [fruit_number];
    logic [FRUIT_DEPTH-1:0] fruit_figure_index [fruit_number];
    logic [FRUIT_DEPTH-1:0] half1_figure_index [fruit_number];
    logic [FRUIT_DEPTH-1:0] half2_figure_index [fruit_number];
    logic fruit_check_inside [fruit_number];
    logic half1_check_inside [fruit_number];
    logic half2_check_inside [fruit_number];
    logic [fruit_number-1:0] fruit_to_print; // whether to print 
    logic [fruit_number-1:0] half1_to_print;
    logic [fruit_number-1:0] half2_to_print;
    logic fruit_collision [fruit_number];
	logic which_mouse [fruit_number]; // 0 ps2, 1 usb, usb mouse first
    
	int fruit_X_Pos_Init [fruit_number];
	int fruit_Y_Pos_Init [fruit_number];
	int fruit_X_V_Init [fruit_number];
	int fruit_Y_V_Init [fruit_number];
    int half1_X_Pos_Init [fruit_number];
	int half1_Y_Pos_Init [fruit_number];
	int half1_X_V_Init [fruit_number];
	int half1_Y_V_Init [fruit_number];
    int half2_X_Pos_Init [fruit_number];
	int half2_Y_Pos_Init [fruit_number];
	int half2_X_V_Init [fruit_number];
	int half2_Y_V_Init [fruit_number];
	int fruit_X_Pos_Init_in [fruit_number];
	int fruit_Y_Pos_Init_in [fruit_number];
	int fruit_X_V_Init_in [fruit_number];
	int fruit_Y_V_Init_in [fruit_number];
    int half1_X_Pos_Init_in [fruit_number];
	int half1_Y_Pos_Init_in [fruit_number];
	int half1_X_V_Init_in [fruit_number];
	int half1_Y_V_Init_in [fruit_number];
    int half2_X_Pos_Init_in [fruit_number];
	int half2_Y_Pos_Init_in [fruit_number];
	int half2_X_V_Init_in [fruit_number];
	int half2_Y_V_Init_in [fruit_number];
	int fruit_X_Pos [fruit_number];
	int fruit_Y_Pos [fruit_number];
	int fruit_X_V [fruit_number];
	int fruit_Y_V [fruit_number];
    int half1_X_Pos [fruit_number];
	int half1_Y_Pos [fruit_number];
	int half1_X_V [fruit_number];
	int half1_Y_V [fruit_number];
    int half2_X_Pos [fruit_number];
	int half2_Y_Pos [fruit_number];
	int half2_X_V [fruit_number];
	int half2_Y_V [fruit_number];
    logic fruit_out_of_screen [fruit_number];
    logic half1_out_of_screen [fruit_number];
    logic half2_out_of_screen [fruit_number];

    logic [fruit_index-1:0] fruit_print_which;
    logic [fruit_index-1:0] half1_print_which;
    logic [fruit_index-1:0] half2_print_which;

	int num_cut, num_cut_second, num_miss;
	logic [fruit_number-1:0] miss_list, miss_list_in;
	logic [fruit_number-1:0] cut_list[2];
	logic [fruit_number-1:0] cut_list_in[2];

    int total_cut_in, total_cut_second_in, total_miss_in;

    fruit_motion #(.FRUIT_DEPTH(FRUIT_DEPTH),
						.FRUIT_WIDTH(FRUIT_WIDTH),
						.FRUIT_HEIGHT(FRUIT_HEIGHT),
						.FRUIT_WIDTH_HALF(FRUIT_WIDTH_HALF),
						.FRUIT_HEIGHT_HALF(FRUIT_HEIGHT_HALF)) 
						
						fruit_motion_inst[fruit_number-1:0](
						.Clk(Clk),
						.Reset(Reset_h),
						.Initialize(fruit_init),
						.frame_clk_rising_edge(frame_clk_rising_edge),
						.DrawX(DrawX),
						.DrawY(DrawY),
						.X_Pos_Init(fruit_X_Pos_Init),
						.Y_Pos_Init(fruit_Y_Pos_Init),
						.X_V_Init(fruit_X_V_Init),
						.Y_V_Init(fruit_Y_V_Init),
						.X_Pos(fruit_X_Pos),
						.Y_Pos(fruit_Y_Pos),
						.X_V(fruit_X_V),
						.Y_V(fruit_Y_V),
						.check_inside(fruit_check_inside),
						.figure_index(fruit_figure_index),
						.out_of_screen(fruit_out_of_screen));

    fruit_edge #(	.FRUIT_DEPTH(FRUIT_DEPTH),
						.FRUIT_SIZE(FRUIT_SIZE),
						.type_index(type_index),
						.type_number(type_number)) 
						
						fruit_edge_inst[fruit_number-1:0] (
						.Clk(Clk),
						.Reset(Reset_h),
						.Initialize(fruit_init),
						.frame_clk_rising_edge(frame_clk_rising_edge),
						.is_mouse(is_mouse),
						.is_mouse_second(is_mouse_second),
						.check_inside(fruit_check_inside),
						.figure_index(fruit_figure_index),
						.types(types),
						.to_print(fruit_to_print),
						.is_collision(fruit_collision),
						.which_mouse(which_mouse)
						);

    half1_motion #(.FRUIT_DEPTH(FRUIT_DEPTH),
						.FRUIT_WIDTH(FRUIT_WIDTH),
						.FRUIT_HEIGHT(FRUIT_HEIGHT),
						.FRUIT_WIDTH_HALF(FRUIT_WIDTH_HALF),
						.FRUIT_HEIGHT_HALF(FRUIT_HEIGHT_HALF)) half1_motion_inst[fruit_number-1:0](
						.Clk(Clk),
						.Reset(Reset_h),
						.Initialize(half1_init),
						.frame_clk_rising_edge(frame_clk_rising_edge),
						.DrawX(DrawX),
						.DrawY(DrawY),
						.X_Pos_Init(half1_X_Pos_Init),
						.Y_Pos_Init(half1_Y_Pos_Init),
						.X_V_Init(half1_X_V_Init),
						.Y_V_Init(half1_Y_V_Init),
						.X_Pos(half1_X_Pos),
						.Y_Pos(half1_Y_Pos),
						.X_V(half1_X_V),
						.Y_V(half1_Y_V),
						.check_inside(half1_check_inside),
						.figure_index(half1_figure_index),
						.out_of_screen(half1_out_of_screen));

    half1_edge #(	.FRUIT_DEPTH(FRUIT_DEPTH),
						.FRUIT_SIZE(FRUIT_SIZE),
						.type_index(type_index),
						.type_number(type_number)) 
						
						half1_edge_inst[fruit_number-1:0](
						.Clk(Clk),
						.Reset(Reset_h),
						.check_inside(half1_check_inside),
						.figure_index(half1_figure_index),
						.types(types),
						.to_print(half1_to_print));

    half2_motion #(.FRUIT_DEPTH(FRUIT_DEPTH),
						.FRUIT_WIDTH(FRUIT_WIDTH),
						.FRUIT_HEIGHT(FRUIT_HEIGHT),
						.FRUIT_WIDTH_HALF(FRUIT_WIDTH_HALF),
						.FRUIT_HEIGHT_HALF(FRUIT_HEIGHT_HALF)) half2_motion_inst[fruit_number-1:0](
						.Clk(Clk),
						.Reset(Reset_h),
						.Initialize(half2_init),
						.frame_clk_rising_edge(frame_clk_rising_edge),
						.DrawX(DrawX),
						.DrawY(DrawY),
						.X_Pos_Init(half2_X_Pos_Init),
						.Y_Pos_Init(half2_Y_Pos_Init),
						.X_V_Init(half2_X_V_Init),
						.Y_V_Init(half2_Y_V_Init),
						.X_Pos(half2_X_Pos),
						.Y_Pos(half2_Y_Pos),
						.X_V(half2_X_V),
						.Y_V(half2_Y_V),
						.check_inside(half2_check_inside),
						.figure_index(half2_figure_index),
						.out_of_screen(half2_out_of_screen));

    half2_edge #(	.FRUIT_DEPTH(FRUIT_DEPTH),
						.FRUIT_SIZE(FRUIT_SIZE),
						.type_index(type_index),
						.type_number(type_number)) half2_edge_inst[fruit_number-1:0](
						.Clk(Clk),
						.Reset(Reset_h),
						.check_inside(half2_check_inside),
						.figure_index(half2_figure_index),
						.types(types),
						.to_print(half2_to_print));

    print_checker #(	.fruit_number(fruit_number), 
							.fruit_index(fruit_index)) fruit_print_checker(
							.to_print(fruit_to_print),
							.print_true(fruit_print_true),
							.print_which(fruit_print_which));
    print_checker #(	.fruit_number(fruit_number), 
							.fruit_index(fruit_index)) half1_print_checker(
							.to_print(half1_to_print),
							.print_true(half1_print_true),
							.print_which(half1_print_which));
    print_checker #(	.fruit_number(fruit_number), 
							.fruit_index(fruit_index)) half2_print_checker(
							.to_print(half2_to_print),
							.print_true(half2_print_true),
							.print_which(half2_print_which));

    fruit_draw #(	.fruit_index(fruit_index), 
						.FB_DATAW(FB_DATAW), 
						.FRUIT_DEPTH(FRUIT_DEPTH), 
						.FRUIT_SIZE(FRUIT_SIZE), 
						.type_index(type_index), 
						.type_number(type_number)) fruit_draw_inst(
						.Clk(Clk),
						.Reset(Reset_h),
						.print_true(fruit_print_true),
						.current_type(types[fruit_print_which]),
						.current_figure_index(fruit_figure_index[fruit_print_which]),
						.color(fruit_color));
    half1_draw #(	.fruit_index(fruit_index), 
						.FB_DATAW(FB_DATAW), 
						.FRUIT_DEPTH(FRUIT_DEPTH), 
						.FRUIT_SIZE(FRUIT_SIZE), 
						.type_index(type_index), 
						.type_number(type_number)) half1_draw_inst(
						.Clk(Clk),
						.Reset(Reset_h),
						.print_true(half1_print_true),
						.current_type(types[half1_print_which]),
						.current_figure_index(half1_figure_index[half1_print_which]),
						.color(half1_color));
    half2_draw #(	.fruit_index(fruit_index), 
						.FB_DATAW(FB_DATAW), 
						.FRUIT_DEPTH(FRUIT_DEPTH), 
						.FRUIT_SIZE(FRUIT_SIZE), 
						.type_index(type_index), 
						.type_number(type_number)) half2_draw_inst(
						.Clk(Clk),
						.Reset(Reset_h),
						.print_true(half2_print_true),
						.current_type(types[half2_print_which]),
						.current_figure_index(half2_figure_index[half2_print_which]),
						.color(half2_color));

	count_list #(.fruit_number(fruit_number)) count_list_num_cut(.list(cut_list[0]),.sum(num_cut));
	count_list #(.fruit_number(fruit_number)) count_list_num_cut_second(.list(cut_list[1]),.sum(num_cut_second));
	count_list #(.fruit_number(fruit_number)) count_list_num_miss(.list(miss_list),.sum(num_miss));
	next_finder #(.fruit_number(fruit_number),.fruit_index(fruit_index)) next_finder_inst(.states(states),.next_available(next_available),.next_which(next_which));

    always_ff @(posedge Clk)
    begin
        for (int i = 0; i < fruit_number; i++)
        begin
            if (Reset_h)
            begin
				cut_list[0] <= 0;
				cut_list[1] <= 0;
				miss_list <= 0;
                states[i] <= 0;
                types[i] <= 0;
                fruit_init[i] <= 0;
                fruit_X_Pos_Init[i] <= 0;
                fruit_Y_Pos_Init[i] <= 0;
                fruit_X_V_Init[i] <= 0;
                fruit_Y_V_Init[i] <= 0;
                half1_init[i] <= 0;
                half1_X_Pos_Init[i] <= 0;
                half1_Y_Pos_Init[i] <= 0;
                half1_X_V_Init[i] <= 0;
                half1_Y_V_Init[i] <= 0;
                half2_init[i] <= 0;
                half2_X_Pos_Init[i] <= 0;
                half2_Y_Pos_Init[i] <= 0;
                half2_X_V_Init[i] <= 0;
                half2_Y_V_Init[i] <= 0;
            end
            else
            begin
				cut_list[0] <= cut_list_in[0];
				cut_list[1] <= cut_list_in[1];
				miss_list <= miss_list_in;
                states[i] <= states_in[i];
                types[i] <= types_in[i];
                fruit_init[i] <= fruit_init_in[i];
                fruit_X_Pos_Init[i] <= fruit_X_Pos_Init_in[i];
                fruit_Y_Pos_Init[i] <= fruit_Y_Pos_Init_in[i];
                fruit_X_V_Init[i] <= fruit_X_V_Init_in[i];
                fruit_Y_V_Init[i] <= fruit_Y_V_Init_in[i];
                half1_init[i] <= half1_init_in[i];
                half1_X_Pos_Init[i] <= half1_X_Pos_Init_in[i];
                half1_Y_Pos_Init[i] <= half1_Y_Pos_Init_in[i];
                half1_X_V_Init[i] <= half1_X_V_Init_in[i];
                half1_Y_V_Init[i] <= half1_Y_V_Init_in[i];
                half2_init[i] <= half2_init_in[i];
                half2_X_Pos_Init[i] <= half2_X_Pos_Init_in[i];
                half2_Y_Pos_Init[i] <= half2_Y_Pos_Init_in[i];
                half2_X_V_Init[i] <= half2_X_V_Init_in[i];
                half2_Y_V_Init[i] <= half2_Y_V_Init_in[i];
            end
        end
    end

    always_comb
    begin
		cut_list_in[0] = cut_list[0];
		miss_list_in = miss_list;
        for (int i = 0; i < fruit_number; i++)
        begin
            states_in[i] = states[i];
            types_in[i] = types[i];
            fruit_init_in[i] = fruit_init[i];
            fruit_X_Pos_Init_in[i] = fruit_X_Pos_Init[i];
            fruit_Y_Pos_Init_in[i] = fruit_Y_Pos_Init[i];
            fruit_X_V_Init_in[i] = fruit_X_V_Init[i];
            fruit_Y_V_Init_in[i] = fruit_Y_V_Init[i];
            half1_init_in[i] = half1_init[i];
            half1_X_Pos_Init_in[i] = half1_X_Pos_Init[i];
            half1_Y_Pos_Init_in[i] = half1_Y_Pos_Init[i];
            half1_X_V_Init_in[i] = half1_X_V_Init[i];
            half1_Y_V_Init_in[i] = half1_Y_V_Init[i];
            half2_init_in[i] = half2_init[i];
            half2_X_Pos_Init_in[i] = half2_X_Pos_Init[i];
            half2_Y_Pos_Init_in[i] = half2_Y_Pos_Init[i];
            half2_X_V_Init_in[i] = half2_X_V_Init[i];
            half2_Y_V_Init_in[i] = half2_Y_V_Init[i];
        end
        if (mouse_usb_click[2]) // middle button
        begin
			states_in[0] = 2'b01;
			states_in[1] = 2'b01;
			states_in[2] = 2'b01;
			states_in[3] = 2'b01;
			types_in[0] = 2'b00;
			types_in[1] = 2'b01;
			types_in[2] = 2'b10;
			types_in[3] = 2'b11;
            fruit_init_in[0] = 1;
            fruit_X_Pos_Init_in[0] = 100;
            fruit_Y_Pos_Init_in[0] = 400;
            fruit_X_V_Init_in[0] = 3;
            fruit_Y_V_Init_in[0] = -9;
            fruit_init_in[1] = 1;
            fruit_X_Pos_Init_in[1] = 600;
            fruit_Y_Pos_Init_in[1] = 400;
            fruit_X_V_Init_in[1] = -3;
            fruit_Y_V_Init_in[1] = -9;
            fruit_init_in[2] = 1;
            fruit_X_Pos_Init_in[2] = 200;
            fruit_Y_Pos_Init_in[2] = 400;
            fruit_X_V_Init_in[2] = 2;
            fruit_Y_V_Init_in[2] = -9;
            fruit_init_in[3] = 1;
            fruit_X_Pos_Init_in[3] = 500;
            fruit_Y_Pos_Init_in[3] = 400;
            fruit_X_V_Init_in[3] = -2;
            fruit_Y_V_Init_in[3] = -9;
        end
		if (mouse_usb_click[0]) // left button
		begin
			states_in[0] = 2'b01;
			types_in[0] = random_number[2:1];
            fruit_init_in[0] = 1;
			if (1'b1 == random_number[3]) // to left
			begin
            	fruit_X_Pos_Init_in[0] = 100 + random_number[10:4];
            	fruit_Y_Pos_Init_in[0] = FB_HEIGHT + FRUIT_HEIGHT_HALF - 1;
            	fruit_X_V_Init_in[0] = 1 + random_number[12:11];
            	fruit_Y_V_Init_in[0] = -11 + random_number[14:13];
			end
			else
			begin
            	fruit_X_Pos_Init_in[0] = FB_WIDTH - 100 - random_number[10:4];
            	fruit_Y_Pos_Init_in[0] = FB_HEIGHT + FRUIT_HEIGHT_HALF - 1;
            	fruit_X_V_Init_in[0] = -1 - random_number[12:11];
            	fruit_Y_V_Init_in[0] = -11 + random_number[14:13];				
			end
		end
		if (mouse_usb_click[1] && next_available && (FB_WIDTH-2 == DrawX) && (FB_HEIGHT-1 == DrawY) && mode_counter) // right button
		begin
			states_in[next_which] = 2'b01;
			types_in[next_which] = random_number[2:1];
            fruit_init_in[next_which] = 1;
			if (1'b1 == random_number[3]) // to left
			begin
            	fruit_X_Pos_Init_in[next_which] = 100 + random_number[10:4];
            	fruit_Y_Pos_Init_in[next_which] = FB_HEIGHT + FRUIT_HEIGHT_HALF - 1;
            	fruit_X_V_Init_in[next_which] = 1 + random_number[12:11];
            	fruit_Y_V_Init_in[next_which] = -11 + random_number[14:13];
			end
			else
			begin
            	fruit_X_Pos_Init_in[next_which] = FB_WIDTH - 100 - random_number[10:4];
            	fruit_Y_Pos_Init_in[next_which] = FB_HEIGHT + FRUIT_HEIGHT_HALF - 1;
            	fruit_X_V_Init_in[next_which] = -1 - random_number[12:11];
            	fruit_Y_V_Init_in[next_which] = -11 + random_number[14:13];				
			end
		end
		if (next_init && next_available && (FB_WIDTH-2 == DrawX) && (FB_HEIGHT-1 == DrawY) && mode_counter)
		begin
			states_in[next_which] = 2'b01;
			types_in[next_which] = random_number[2:1];
            fruit_init_in[next_which] = 1;
			if (1'b1 == random_number[3]) // to left
			begin
            	fruit_X_Pos_Init_in[next_which] = 100 + random_number[10:4];
            	fruit_Y_Pos_Init_in[next_which] = FB_HEIGHT + FRUIT_HEIGHT_HALF - 1;
            	fruit_X_V_Init_in[next_which] = 1 + random_number[12:11];
            	fruit_Y_V_Init_in[next_which] = -11 + random_number[14:13];
			end
			else
			begin
            	fruit_X_Pos_Init_in[next_which] = FB_WIDTH - 100 - random_number[10:4];
            	fruit_Y_Pos_Init_in[next_which] = FB_HEIGHT + FRUIT_HEIGHT_HALF - 1;
            	fruit_X_V_Init_in[next_which] = -1 - random_number[12:11];
            	fruit_Y_V_Init_in[next_which] = -11 + random_number[14:13];				
			end
		end
        for (int i = 0; i < fruit_number; i++)
        begin
			if (fruit_collision[i])
        	begin
				if (frame_clk_rising_edge)
				begin
					states_in[i] = 2'b10;
					cut_list_in[which_mouse[i]][i] = 1'b1;
				end
        	    fruit_init_in[i] = 1;
        	    fruit_X_Pos_Init_in[i] = 1000;
        	    fruit_Y_Pos_Init_in[i] = 1000;
        	    fruit_X_V_Init_in[i] = 0;
        	    fruit_Y_V_Init_in[i] = 0;
        	    half1_init_in[i] = 1;
        	    half1_X_Pos_Init_in[i] = fruit_X_Pos[i];
        	    half1_Y_Pos_Init_in[i] = fruit_Y_Pos[i];
        	    half1_X_V_Init_in[i] = fruit_X_V[i] - 2;
        	    half1_Y_V_Init_in[i] = fruit_Y_V[i];
        	    half2_init_in[i] = 1;
        	    half2_X_Pos_Init_in[i] = fruit_X_Pos[i];
        	    half2_Y_Pos_Init_in[i] = fruit_Y_Pos[i];
        	    half2_X_V_Init_in[i] = fruit_X_V[i] + 2;
        	    half2_Y_V_Init_in[i] = fruit_Y_V[i];
        	end
			if ((1'b1 == frame_clk_rising_edge) && (2'b01 == states[i]) && (1'b1 == fruit_out_of_screen[i]) && (1'b0 == fruit_init[i]))
			begin
				states_in[i] = 2'b00;
				miss_list_in[i] = 1'b1;
			end
			if ((1'b1 == frame_clk_rising_edge) && ((2'b10 == states[i])||(2'b11 == states[i])))
			begin
				unique case ({half1_out_of_screen[i],half2_out_of_screen[i]})
					2'b11: states_in[i] = 2'b00;
					2'b10: states_in[i] = 2'b10;
					2'b01: states_in[i] = 2'b10;
					2'b00: states_in[i] = 2'b11;
				endcase
			end
		end
		if ((0==DrawX)&&(0==DrawY))
		begin
			cut_list_in[0] = 0;
			cut_list_in[1] = 0;
			miss_list_in = 0;
        	for (int i = 0; i < fruit_number; i++)
        	begin
        	    fruit_init_in[i] = 0;
        	    half1_init_in[i] = 0;
        	    half2_init_in[i] = 0;
        	end
		end
    end

	always_ff @(posedge Clk)
	begin
		if (Reset_h)
		begin
			total_cut <= 0;
			total_cut_second <= 0;
			total_miss <= 0;
		end
		else
		begin
			total_cut <= total_cut_in;
			total_cut_second <= total_cut_second_in;
			total_miss <= total_miss_in;
		end
	end

	always_comb
	begin
		if ((2'd01==graph_index)&&(0==DrawX)&&(0==DrawY))
		begin
			total_cut_in = total_cut + num_cut;
			total_cut_second_in = total_cut_second + num_cut_second;
			total_miss_in = total_miss + num_miss;
		end
		else if(2'd00==graph_index)
		begin
			total_cut_in = 0;
			total_cut_second_in = 0;
			total_miss_in = 0;
		end
		else
		begin
			total_cut_in = total_cut;
			total_cut_second_in = total_cut_second;
			total_miss_in = total_miss;
		end
	end

endmodule