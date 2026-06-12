module clock_divider(
    input clk_in,
    output reg slow_clk
);

    reg [25:0] count = 0;

    always @(posedge clk_in) begin
        count <= count + 1;
        slow_clk <= count[25]; // ~1.5 Hz at 100 MHz
    end

endmodule
