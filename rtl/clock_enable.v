`timescale 1ns / 1ps

module clock_enable #(
    parameter integer COUNT_MAX = 50000000
)(
    input clk,
    input reset,
    output reg tick
);

    reg [31:0] count;

    always @(posedge clk) begin
        if (reset) begin
            count <= 32'd0;
            tick  <= 1'b0;
        end
        else begin
            if (count == COUNT_MAX - 1) begin
                count <= 32'd0;
                tick  <= 1'b1;
            end
            else begin
                count <= count + 32'd1;
                tick  <= 1'b0;
            end
        end
    end

endmodule