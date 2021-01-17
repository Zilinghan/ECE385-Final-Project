module print_checker #(fruit_number, fruit_index) (
        input logic [fruit_number-1:0] to_print, // fruit with index 0 will be the highest significant bit
        output logic print_true,
        output logic [fruit_index-1:0] print_which
    );

    always_comb
    begin
        unique case (to_print)
            4'b0000: 
                begin
                    print_true = 0;
                    print_which = 2'b00;
                end
            4'b0001: 
                begin
                    print_true = 1;
                    print_which = 2'b11;
                end
            4'b0010:
                begin
                    print_true = 1;
                    print_which = 2'b10;
                end
            4'b0011: 
                begin
                    print_true = 1;
                    print_which = 2'b10;
                end
            4'b0100: 
                begin
                    print_true = 1;
                    print_which = 2'b01;
                end
            4'b0101: 
                begin
                    print_true = 1;
                    print_which = 2'b01;
                end
            4'b0110:
                begin
                    print_true = 1;
                    print_which = 2'b01;
                end
            4'b0111: 
                begin
                    print_true = 1;
                    print_which = 2'b01;
                end
            4'b1000: 
                begin
                    print_true = 1;
                    print_which = 2'b00;
                end
            4'b1001: 
                begin
                    print_true = 1;
                    print_which = 2'b00;
                end
            4'b1010: 
                begin
                    print_true = 1;
                    print_which = 2'b00;
                end
            4'b1011: 
                begin
                    print_true = 1;
                    print_which = 2'b00;
                end
            4'b1100: 
                begin
                    print_true = 1;
                    print_which = 2'b00;
                end
            4'b1101: 
                begin
                    print_true = 1;
                    print_which = 2'b00;
                end
            4'b1110: 
                begin
                    print_true = 1;
                    print_which = 2'b00;
                end
            4'b1111: 
                begin
                    print_true = 1;
                    print_which = 2'b00;
                end
        endcase
    end

endmodule