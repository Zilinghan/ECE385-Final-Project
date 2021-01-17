module half2_motion #(FRUIT_DEPTH, FRUIT_WIDTH, FRUIT_HEIGHT, FRUIT_WIDTH_HALF, FRUIT_HEIGHT_HALF)(
        input logic Clk,
        input logic Reset,
        input logic Initialize,
        input logic frame_clk_rising_edge,
        input logic [9:0] DrawX, DrawY,
        input int X_Pos_Init, Y_Pos_Init,
        input int X_V_Init, Y_V_Init,
        output int X_Pos, Y_Pos,
        output int X_V, Y_V,
        output logic check_inside,
        output logic [FRUIT_DEPTH-1:0] figure_index,
        output logic out_of_screen
    );
	// Define local parameters
	localparam FRUIT_Y_MAX       = 479;
	localparam FRUIT_X_MIN       = 0;
	localparam FRUIT_X_MAX       = 639;
	// Define the internal Variables: (Integer Form)
	int Fruit_X_Pos;
	int Fruit_Y_Pos;
	int Fruit_X_V;
	int Fruit_Y_V;
	logic [4:0] Fruit_Rot_Counter;
	int angle_change_flag;  // Change the angle every 8 1/60s
	int v_change_flag;      // Change the velocity every 2 1/60s
	int Fruit_X_Pos_in;
	int Fruit_Y_Pos_in;
	int Fruit_X_V_in;
	int Fruit_Y_V_in;
	logic [4:0] Fruit_Rot_Counter_in;
	int angle_change_flag_in;
	int v_change_flag_in;
	
	
	// Update registers
	always_ff @ (posedge Clk) begin
		if (Reset) begin
			Fruit_X_Pos       <= 1000;
			Fruit_Y_Pos			<= 1000;
			Fruit_X_V   		<= 0;
			Fruit_Y_V   		<= 0;
			Fruit_Rot_Counter <= 0;
			v_change_flag	 	<= 0;
			angle_change_flag <= 1;
		end
		else if (Initialize && frame_clk_rising_edge)
		begin
			Fruit_X_Pos       <= X_Pos_Init;
			Fruit_Y_Pos			<= Y_Pos_Init;
			Fruit_X_V   		<= X_V_Init;
			Fruit_Y_V   		<= Y_V_Init;
			Fruit_Rot_Counter <= 0;
			v_change_flag	 	<= 0;
			angle_change_flag <= 1;
		end
		else begin
			Fruit_X_Pos 		<= Fruit_X_Pos_in;
			Fruit_Y_Pos 		<= Fruit_Y_Pos_in;
			Fruit_X_V   		<= Fruit_X_V_in;
			Fruit_Y_V   		<= Fruit_Y_V_in;
			Fruit_Rot_Counter <= Fruit_Rot_Counter_in;
			v_change_flag 		<= v_change_flag_in;
			angle_change_flag <= angle_change_flag_in;
		end
	end
	
	assign X_Pos = Fruit_X_Pos;
	assign Y_Pos = Fruit_Y_Pos;
	assign X_V   = Fruit_X_V;
	assign Y_V   = Fruit_Y_V;
	assign out_of_screen = ((Fruit_Y_Pos > FRUIT_Y_MAX + FRUIT_HEIGHT_HALF) || (Fruit_X_Pos>FRUIT_X_MAX+FRUIT_WIDTH_HALF) || (Fruit_X_Pos + FRUIT_WIDTH_HALF <= 0));
	
	always_comb begin
		// DEFAULT
		Fruit_X_Pos_in       = Fruit_X_Pos;
		Fruit_Y_Pos_in       = Fruit_Y_Pos;
		Fruit_X_V_in         = Fruit_X_V;
		Fruit_Y_V_in         = Fruit_Y_V;
		Fruit_Rot_Counter_in = Fruit_Rot_Counter;
		v_change_flag_in     = v_change_flag;
		angle_change_flag_in = angle_change_flag;
		// Update position and motion only at the rising edge of frame clk
		if (frame_clk_rising_edge) begin
			// When the fruit is out of the screen, then does not change
			if (out_of_screen)begin
				Fruit_X_Pos_in 		= Fruit_X_Pos;
				Fruit_Y_Pos_in 		= Fruit_Y_Pos;
				Fruit_X_V_in        	= Fruit_X_V;
				Fruit_Y_V_in   		= Fruit_Y_V;
				Fruit_Rot_Counter_in = Fruit_Rot_Counter;
				v_change_flag_in 		= v_change_flag;
				angle_change_flag_in = angle_change_flag;
			end
			// When the fruit is still inside the screen, then update
			else begin
				if (v_change_flag == 1)
					Fruit_Y_V_in = Fruit_Y_V + 1;
				else
					Fruit_Y_V_in = Fruit_Y_V;
				if (angle_change_flag == 0) begin
					if (Fruit_X_V >= 0)
						Fruit_Rot_Counter_in = Fruit_Rot_Counter+1;
					else 
						Fruit_Rot_Counter_in = Fruit_Rot_Counter-1;
				end
				else
					Fruit_Rot_Counter_in = Fruit_Rot_Counter;
				Fruit_X_V_in 			= Fruit_X_V;
				v_change_flag_in 		= (v_change_flag+1)%8;
				angle_change_flag_in = (angle_change_flag+1)%4;
				Fruit_X_Pos_in 		= Fruit_X_Pos + Fruit_X_V;
				Fruit_Y_Pos_in 		= Fruit_Y_Pos + Fruit_Y_V;
			end
		end
	end
	
	// Basic Assumption: All "Meaningful" Data should also in the 
	// Box (Figure Square) as well after the rotation
	// Steps of displaying color:
	// (1) Check whether (DrawX, DrawY) is inside the box or not
	// (2) Let (X_r, Y_r) = (DrawX-CX, DrawY-CY), then rotate (X_r, Y_r)
	//     according to the value in the Fruit_Rot_Counter to get
	//     the relative coordinate of data point (X_r_rot, Y_r_rot)
	// (3) Check whether (X_r, Y_r) is inside the box.
	// (4) Output color index and priority
	
	int DrawX_int;
	int DrawY_int;
	assign DrawX_int = DrawX;
	assign DrawY_int = DrawY;
	int X_r, Y_r, X_r_rot, Y_r_rot;
	assign X_r = DrawX_int - Fruit_X_Pos;
	assign Y_r = DrawY_int - Fruit_Y_Pos;
	int a11, a12, a21, a22;
	
	
	
	always_comb begin
		if ((X_r*X_r+Y_r*Y_r) <= FRUIT_WIDTH_HALF*FRUIT_WIDTH_HALF)
			check_inside = 1;
		else
			check_inside = 0;
		a11 = 0;
		a12 = 0;
		a21 = 0;
		a22 = 0;
		unique case (Fruit_Rot_Counter)
			5'd0:
			begin
				a11 = 1024;
				a12 = 0;
				a21 = 0;
				a22 = 1024;
			end
			5'd1:
			begin
				a11 = 1004;
				a12 = -200;
				a21 = 200;
				a22 = 1004;
			end
			5'd2:
			begin
				a11 = 946;
				a12 = -392;
				a21 = 392;
				a22 = 946;
			end
			5'd3:
			begin
				a11 = 851;
				a12 = -569;
				a21 = 569;
				a22 = 851;
			end
			5'd4:
			begin
				a11 = 724;
				a12 = -724;
				a21 = 724;
				a22 = 724;
			end
			5'd5:
			begin
				a11 = 569;
				a12 = -851;
				a21 = 851;
				a22 = 569;
			end
			5'd6:
			begin
				a11 = 392;
				a12 = -946;
				a21 = 946;
				a22 = 392;
			end
			5'd7:
			begin
				a11 = 200;
				a12 = -1004;
				a21 = 1004;
				a22 = 200;
			end
			5'd8:
			begin
				a11 = 0;
				a12 = -1024;
				a21 = 1024;
				a22 = 0;
			end
			5'd9:
			begin
				a11 = -200;
				a12 = -1004;
				a21 = 1004;
				a22 = -200;
			end
			5'd10:
			begin
				a11 = -392;
				a12 = -946;
				a21 = 946;
				a22 = -392;
			end
			5'd11:
			begin
				a11 = -569;
				a12 = -851;
				a21 = 851;
				a22 = -569;
			end
			5'd12:
			begin
				a11 = -724;
				a12 = -724;
				a21 = 724;
				a22 = -724;
			end
			5'd13:
			begin
				a11 = -851;
				a12 = -569;
				a21 = 569;
				a22 = -851;
			end
			5'd14:
			begin
				a11 = -946;
				a12 = -392;
				a21 = 392;
				a22 = -946;
			end
			5'd15:
			begin
				a11 = -1004;
				a12 = -200;
				a21 = 200;
				a22 = -1004;
			end
			5'd16:
			begin
				a11 = -1024;
				a12 = 0;
				a21 = 0;
				a22 = -1024;
			end
			5'd17:
			begin
				a11 = -1004;
				a12 = 200;
				a21 = -200;
				a22 = -1004;
			end
			5'd18:
			begin
				a11 = -946;
				a12 = 392;
				a21 = -392;
				a22 = -946;
			end
			5'd19:
			begin
				a11 = -851;
				a12 = 569;
				a21 = -569;
				a22 = -851;
			end
			5'd20:
			begin
				a11 = -724;
				a12 = 724;
				a21 = -724;
				a22 = -724;
			end
			5'd21:
			begin
				a11 = -569;
				a12 = 851;
				a21 = -851;
				a22 = -569;
			end
			5'd22:
			begin
				a11 = -392;
				a12 = 946;
				a21 = -946;
				a22 = -392;
			end
			5'd23:
			begin
				a11 = -200;
				a12 = 1004;
				a21 = -1004;
				a22 = -200;
			end
			5'd24:
			begin
				a11 = 0;
				a12 = 1024;
				a21 = -1024;
				a22 = 0;
			end
			5'd25:
			begin
				a11 = 200;
				a12 = 1004;
				a21 = -1004;
				a22 = 200;
			end
			5'd26:
			begin
				a11 = 392;
				a12 = 946;
				a21 = -946;
				a22 = 392;
			end
			5'd27:
			begin
				a11 = 569;
				a12 = 851;
				a21 = -851;
				a22 = 569;
			end
			5'd28:
			begin
				a11 = 724;
				a12 = 724;
				a21 = -724;
				a22 = 724;
			end			
			5'd29:
			begin
				a11 = 851;
				a12 = 569;
				a21 = -569;
				a22 = 851;
			end
			5'd30:
			begin
				a11 = 946;
				a12 = 392;
				a21 = -392;
				a22 = 946;
			end
			5'd31:
			begin
				a11 = 1004;
				a12 = 200;
				a21 = -200;
				a22 = 1004;
			end
		endcase
		X_r_rot = (a11*X_r+a12*Y_r) >> 10;
		Y_r_rot = (a21*X_r+a22*Y_r) >> 10;
		
		if (check_inside) begin
			figure_index = (X_r_rot+FRUIT_WIDTH_HALF)+(Y_r_rot+FRUIT_HEIGHT_HALF)*FRUIT_WIDTH;
		end	
		else begin
			figure_index = 0;
		end
	end
endmodule