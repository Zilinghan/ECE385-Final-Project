module count_list #(fruit_number) (
    input logic [fruit_number-1:0] list,
    output int sum
    );

    assign sum = list[0] + list[1] + list[2] + list[3];

endmodule