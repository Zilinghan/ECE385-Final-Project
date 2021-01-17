// Inputs: All of the following information is for a certain point (DrawX, DrawY)
// (1) is_mouse: whether the point is inside the mouse
// (2) check_inside: whether the point is a fruit
// (3) figure_index: the index of fruit figure
// (4) types: the type of the current fruit
// Outputs: 
// (1) to_print: whether to print color or not
// (2) is_collision: whether this figure collide with the mouse 
//     Whenever the collision is assserted for this fruit, it will keeps it
module fruit_edge #(FRUIT_DEPTH, FRUIT_SIZE, type_index, type_number)(
        input logic Clk,
        input logic Reset,
        input logic Initialize,
        input logic frame_clk_rising_edge,
        input logic is_mouse,
        input logic is_mouse_second,
        input logic check_inside,
        input logic [FRUIT_DEPTH-1:0] figure_index,
        input logic [type_index-1:0] types,
        output logic to_print,
        output logic is_collision,
        output logic which_mouse
    );

    logic is_collision_in, which_mouse_in;
    logic to_print_part [type_number];
    logic edge_memory0 [FRUIT_SIZE];
    logic edge_memory1 [FRUIT_SIZE];
    logic edge_memory2 [FRUIT_SIZE];
    logic edge_memory3 [FRUIT_SIZE];
    localparam EDGE_NAME0 = "fruit_edge_0.txt";
    localparam EDGE_NAME1 = "fruit_edge_1.txt";
    localparam EDGE_NAME2 = "fruit_edge_2.txt";
    localparam EDGE_NAME3 = "fruit_edge_3.txt";
    initial
        begin
            $display("Loading fruit edge into On-Chip Memory");
            $readmemh(EDGE_NAME0, edge_memory0);
            $readmemh(EDGE_NAME1, edge_memory1);
            $readmemh(EDGE_NAME2, edge_memory2);
            $readmemh(EDGE_NAME3, edge_memory3);
        end

    always_ff @(posedge Clk)
    begin
        if (Reset)
        begin
            is_collision <= 1'b0;
            which_mouse <= 1'b0;
        end
        else if (Initialize && frame_clk_rising_edge)
        begin
            is_collision <= 1'b0;
            which_mouse <= 1'b0;
        end
        else
        begin
            is_collision <= is_collision_in;
            which_mouse <= which_mouse_in;
        end
    end

    always_comb
    begin
        is_collision_in = is_collision;
        which_mouse_in = which_mouse;
        to_print = 0;
        to_print_part[0] = edge_memory0[figure_index];
        to_print_part[1] = edge_memory1[figure_index];
        to_print_part[2] = edge_memory2[figure_index];
        to_print_part[3] = edge_memory3[figure_index];
        if (check_inside)            
        begin
            to_print = to_print_part[types];
            if ((1 == is_mouse_second) && (0 == is_collision)) // usb mouse first
            begin
                is_collision_in = to_print;
                which_mouse_in = 1'b1;
            end
            else if ((1 == is_mouse) && (0 == is_collision))
            begin
                is_collision_in = to_print;
                which_mouse_in = 1'b0;
            end
        end
    end

endmodule
