module rom(
    input [3:0] addr,
    output reg [7:0] data
);

    always @(*) begin
        case (addr)
            4'h0: data = 8'h1A; // LOAD A, A (0xA)
            4'h1: data = 8'h24; // ADD 4
            4'h2: data = 8'h3F; // SUB F
            4'h3: data = 8'h5C; // OR C
            4'h4: data = 8'hF0; // HALT
            default: data = 8'h00;
        endcase
    end

endmodule
