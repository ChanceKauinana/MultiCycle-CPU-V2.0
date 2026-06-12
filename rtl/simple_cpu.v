module simple_cpu(
    input clk,
    input reset,
    output [3:0] led
);
    reg [3:0] A = 0;
    reg [3:0] pc = 0;
    reg halted = 0;

    wire [7:0] rom_data;
    rom program(.addr(pc), .data(rom_data));

    wire [3:0] alu_result;
    alu core(
        .a(A),
        .b(rom_data[3:0]),
        .opcode(rom_data[7:4]),
        .result(alu_result)
    );

    always @(posedge clk) begin
        if (reset) begin
            A <= 0;
            pc <= 0;
            halted <= 0;
        end
        else if (!halted) begin
            case (rom_data[7:4])
                4'b0000: begin
                    pc <= pc + 1;
                end

                4'b0001: begin
                    A <= rom_data[3:0];
                    pc <= pc + 1;
                end

                4'b0010,
                4'b0011,
                4'b0100,
                4'b0101: begin
                    A <= alu_result;
                    pc <= pc + 1;
                end

                4'b1111: begin
                    halted <= 1;
                end

                default: begin
                    pc <= pc + 1;
                end
            endcase
        end
    end

    assign led = A;
endmodule