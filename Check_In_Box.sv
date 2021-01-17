// --------------------------Check_In_Box--------------------------
// For this module, given inputs drawX and drawY, and the information
// of a box (i.e., a square figure): the center and the half-width 
// and the half-height. We need to determine whether (drawX and drawY)
// is inside the figure or not.
module Check_In_Box(
	input [9:0] 	DrawX,
	input [9:0] 	DrawY,
	input [9:0] 	CX,
	input [9:0] 	CY,
	input [9:0] 	X_width,
	input [9:0] 	Y_height,
	output logic 	check_inside
	);
	logic check_X, check_Y;
	assign check_X = ((DrawX+X_width) >= CX) && (DrawX <= (CX+X_width));
	assign check_Y = ((DrawY+Y_height) >= CY) && (DrawY <= (CY+Y_height));
	assign check_inside = check_X && check_Y;
endmodule
