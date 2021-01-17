// This is the Color Look-Up Table (CLUT)
module CLUT #(N = 5) ( 
	input logic  [N-1:0] color_idx,
	input logic  [9:0]   DrawX,
	input logic  [9:0]   DrawY,
	output logic [7:0]   VGA_R,
	output logic [7:0]   VGA_G,
	output logic [7:0]   VGA_B
	);
	
	// Using On-Chip Memory to Store the CLUT:
	localparam num_color = 2**N;
	localparam FB_PALETTE = "palette.txt";
	logic [23:0] clut [num_color]; 
	initial begin
		$display("Loading palette '%s' into CLUT",FB_PALETTE);
		$readmemh(FB_PALETTE, clut); // load palette into OCM
	end
	// Map color index to palette using CLUT
	logic fb_active;
	localparam FB_WIDTH = 640;
	localparam FB_HEIGHT = 480;
	assign fb_active = (DrawX < FB_WIDTH && DrawY < FB_HEIGHT);
	logic [7:0] red, green, blue;
	always_comb begin
		{red, green, blue} = clut[color_idx];
		if (fb_active) begin
			VGA_R = red;
			VGA_G = green;
			VGA_B = blue;
		end
		else begin
			VGA_R = 8'h0;
			VGA_G = 8'h0;
			VGA_B = 8'h0;
		end
	end
endmodule
