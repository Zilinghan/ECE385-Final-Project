module fruit_draw #(fruit_index, FB_DATAW, FRUIT_DEPTH, FRUIT_SIZE, type_index, type_number) (
        input logic Clk,
        input logic Reset,
        input logic print_true,
        input logic [type_index-1:0] current_type,
        input logic [FRUIT_DEPTH-1:0] current_figure_index,
        output logic [FB_DATAW-1:0] color
    );

    logic [FB_DATAW-1:0] draw_memory0 [FRUIT_SIZE];
    logic [FB_DATAW-1:0] draw_memory1 [FRUIT_SIZE];
    logic [FB_DATAW-1:0] draw_memory2 [FRUIT_SIZE];
    logic [FB_DATAW-1:0] draw_memory3 [FRUIT_SIZE];
    localparam DRAW_NAME0 = "fruit_draw_0.txt";
    localparam DRAW_NAME1 = "fruit_draw_1.txt";
    localparam DRAW_NAME2 = "fruit_draw_2.txt";
    localparam DRAW_NAME3 = "fruit_draw_3.txt";
    initial
        begin
            $display("Loading fruit draw into On-Chip Memory");
            $readmemh(DRAW_NAME0, draw_memory0);
            $readmemh(DRAW_NAME1, draw_memory1);
            $readmemh(DRAW_NAME2, draw_memory2);
            $readmemh(DRAW_NAME3, draw_memory3);
        end

    always_comb
    begin
        if (print_true)            
        begin
            unique case (current_type)
                2'b00: color = draw_memory0[current_figure_index];
                2'b01: color = draw_memory1[current_figure_index];
                2'b10: color = draw_memory2[current_figure_index];
                2'b11: color = draw_memory3[current_figure_index];
            endcase
        end
        else
        begin
            color = 0;
        end
    end

endmodule