`timescale 1ns / 1ps

module top(
    input clk,
    input btnC,
    output [3:0] led,
    output [6:0] seg,
    output [3:0] an
);

    wire slow_clk;
    wire clean_reset;

    // Clock divider for CPU
    clock_divider div(
        .clk_in(clk),
        .slow_clk(slow_clk)
    );

    // Debounce reset button
    debounce db(
        .clk(clk),
        .noisy_btn(btnC),
        .clean_btn(clean_reset)
    );

    // CPU
    wire [3:0] acc;
    simple_cpu cpu(
        .clk(slow_clk),
        .reset(clean_reset),
        .led(acc)
    );

    assign led = acc; // LEDs show accumulator value

    // Seven segment display
    wire [15:0] display_value = {12'b0, acc}; // show acc as one hex digit
    seven_seg_display disp(
        .clk(clk),
        .value(display_value),
        .seg(seg),
        .an(an)
    );

endmodule
