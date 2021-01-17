module half1_edge #(FRUIT_DEPTH, FRUIT_SIZE, type_index, type_number)(
        input logic Clk,
        input logic Reset,
        input logic check_inside,
        input logic [FRUIT_DEPTH-1:0] figure_index,
        input logic [type_index-1:0] types,
        output logic to_print
    );

    logic to_print_part [type_number];
    logic edge_memory0 [FRUIT_SIZE];
    logic edge_memory1 [FRUIT_SIZE];
    logic edge_memory2 [FRUIT_SIZE];
    logic edge_memory3 [FRUIT_SIZE];
    localparam EDGE_NAME0 = "half1_edge_0.txt";
    localparam EDGE_NAME1 = "half1_edge_1.txt";
    localparam EDGE_NAME2 = "half1_edge_2.txt";
    localparam EDGE_NAME3 = "half1_edge_3.txt";
    initial
        begin
            $display("Loading half1 edge into On-Chip Memory");
            $readmemh(EDGE_NAME0, edge_memory0);
            $readmemh(EDGE_NAME1, edge_memory1);
            $readmemh(EDGE_NAME2, edge_memory2);
            $readmemh(EDGE_NAME3, edge_memory3);
        end

    always_comb
    begin
        to_print = 0;
        to_print_part[0] = edge_memory0[figure_index];
        to_print_part[1] = edge_memory1[figure_index];
        to_print_part[2] = edge_memory2[figure_index];
        to_print_part[3] = edge_memory3[figure_index];
        if (check_inside)            
        begin
            to_print = to_print_part[types];
        end
    end

endmodule
