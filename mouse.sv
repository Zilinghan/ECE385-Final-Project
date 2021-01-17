module mouse(
    input logic Clk,
    input logic Reset_h,
    input logic VGA_VS,
    input logic [3:0] KEY,
    input logic [9:0] DrawX, DrawY,
    input logic two_mouse, // whether use the USB mouse
	// USB mouse 
    input logic [7:0] mouse_usb_click, //middle, right, left
    input logic [15:0] mouse_usb_x, mouse_usb_y, // mouse position
    output logic is_mouse_second, // current (DrawX, DrawY) is the USB mouse
	// PS2 interface
	inout wire PS2_CLK,
	inout wire PS2_DAT,
	inout wire PS2_CLK2,
	inout wire PS2_DAT2,
	// PS2 mouse
    output logic [2:0] mouse_ps2_click, //left, right, mid
    output int mouse_ps2_x, mouse_ps2_y, // mouse position
    output logic is_mouse // current (DrawX, DrawY) is the PS2 mouse
    );

    localparam Size = 5;

    logic [15:0] mouse_usb_x_sync, mouse_usb_y_sync;

    always_ff @ (posedge VGA_VS)
    begin
        mouse_usb_x_sync <= mouse_usb_x;
        mouse_usb_y_sync <= mouse_usb_y;
    end

    int DistX_usb, DistY_usb;
    assign DistX_usb = DrawX - mouse_usb_x_sync;
    assign DistY_usb = DrawY - mouse_usb_y_sync;
    assign is_mouse_second = (1'd1 == two_mouse) && ((DistX_usb*DistX_usb + DistY_usb*DistY_usb) <= (Size*Size));

    logic [7:0] ps2_dx, ps2_dy;

    ps2 ps2_inst(
		.iSTART(KEY[3]),  //press the button for transmitting instrucions to device, active low;
        .iRST_n(KEY[0]),  //global reset signal, active low;
        .iCLK_50(Clk),  //clock source;
        .PS2_CLK(PS2_CLK), //ps2_clock signal inout;
        .PS2_DAT(PS2_DAT), //ps2_data  signal inout;
        .BUTTON(mouse_ps2_click),   //left, right, mid;
        .MOVX(ps2_dx),     //displacement of X axis;
        .MOVY(ps2_dy)      //displacement of Y axis;
	);
	
	logic [7:0] ps2_dx_sync, ps2_dy_sync, ps2_dx_prev, ps2_dy_prev;
	logic [7:0] ps2_dx_diff, ps2_dy_diff;
	int mouse_ps2_x_in, mouse_ps2_y_in;
	int ps2_dx_change, ps2_dy_change;

	assign ps2_dx_diff = ps2_dx_sync+(~ps2_dx_prev+1);
	assign ps2_dy_diff = ps2_dy_prev+(~ps2_dy_sync+1);

	assign ps2_dx_change = {{24{ps2_dx_diff[7]}},ps2_dx_diff};
	assign ps2_dy_change = {{24{ps2_dy_diff[7]}},ps2_dy_diff};
	
	always_ff @ (posedge VGA_VS)
    begin
		ps2_dx_sync <= ps2_dx;
		ps2_dx_prev <= ps2_dx_sync;
		ps2_dy_sync <= ps2_dy;
		ps2_dy_prev <= ps2_dy_sync;
		if (Reset_h)
		begin
			mouse_ps2_x <= 320;
			mouse_ps2_y <= 240;
		end
		else
		begin
			mouse_ps2_x <= mouse_ps2_x_in;
			mouse_ps2_y <= mouse_ps2_y_in;			
		end
    end

	always_comb
	begin
		mouse_ps2_x_in = mouse_ps2_x + ps2_dx_change;
		mouse_ps2_y_in = mouse_ps2_y + ps2_dy_change;
		if (mouse_ps2_x_in > 640)
		begin
			mouse_ps2_x_in = 640;
		end
		if (mouse_ps2_x_in < 0)
		begin
			mouse_ps2_x_in = 0;
		end
		if (mouse_ps2_y_in > 480)
		begin
			mouse_ps2_y_in = 480;
		end
		if (mouse_ps2_y_in < 0)
		begin
			mouse_ps2_y_in = 0;
		end
	end

    int DistX_ps2, DistY_ps2;
    assign DistX_ps2 = DrawX - mouse_ps2_x;
    assign DistY_ps2 = DrawY - mouse_ps2_y;

    assign is_mouse = (DistX_ps2*DistX_ps2 + DistY_ps2*DistY_ps2) <= (Size*Size);

endmodule