// It's a linear feedback shift register (LFSR) acting as a random number generator.
module LFSR(
        input logic Clk,
        input logic load,
        input logic [15:0] seed,
        output logic [15:0] random_number
    );

    always_ff @(posedge Clk)
    begin
        if (load)
        begin
            random_number <= seed;
        end
        else if (16'b0 == random_number)
        begin
            random_number <= 16'd42;
        end
        else
        begin
            random_number[0] <= random_number[15] ^ random_number[13] ^ random_number[12] ^ random_number[10];
            random_number[1] <= random_number[0];
            random_number[2] <= random_number[1];
            random_number[3] <= random_number[2];
            random_number[4] <= random_number[3];
            random_number[5] <= random_number[4];
            random_number[6] <= random_number[5];
            random_number[7] <= random_number[6];
            random_number[8] <= random_number[7];
            random_number[9] <= random_number[8];
            random_number[10] <= random_number[9];
            random_number[11] <= random_number[10];
            random_number[12] <= random_number[11];
            random_number[13] <= random_number[12];
            random_number[14] <= random_number[13];
            random_number[15] <= random_number[14];
        end
    end

endmodule