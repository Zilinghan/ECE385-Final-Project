module next_finder #(fruit_number, fruit_index) (
        input logic [fruit_number-1:0] [1:0] states, // states of fruits, 00 not exists, 01 fruit, 10 two halves, 11 one halves
        output logic next_available, // whether it's able to generate a new fruit
        output logic [fruit_index-1:0] next_which // the index of next new fruit
    );

    always_comb
    begin
        if (2'b00 == states[0])
        begin
            next_available = 1'b1;
            next_which = 2'b00;
        end
        else if (2'b00 == states[1])
        begin
            next_available = 1'b1;
            next_which = 2'b01;
        end
        else if (2'b00 == states[2])
        begin
            next_available = 1'b1;
            next_which = 2'b10;
        end
        else if (2'b00 == states[3])
        begin
            next_available = 1'b1;
            next_which = 2'b11;
        end
        else
        begin
            next_available = 1'b0;
            next_which = 2'b00;            
        end
    end

endmodule