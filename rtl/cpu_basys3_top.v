`timescale 1ns / 1ps

module cpu_basys3_top(
    input clk,
    input btnC,
    input [1:0] sw,

    output [3:0] led,
    output [6:0] seg,
    output [3:0] an
);

    wire cpu_step;
    wire reset_clean;

    wire [2:0] state_dbg;
    wire [7:0] pc_dbg;
    wire [15:0] ir_dbg;

    wire [3:0] opcode_dbg;
    wire [3:0] rs_dbg;
    wire [3:0] rt_dbg;
    wire [15:0] rs_val_dbg;
    wire [15:0] rt_val_dbg;
    wire [15:0] alu_out_dbg;

    wire [3:0] rd_dbg;
    wire rf_we_dbg;
    wire halted_dbg;

    reg [15:0] display_value;

    clock_enable #(
        .COUNT_MAX(50000000)
    ) step_generator (
        .clk(clk),
        .reset(1'b0),
        .tick(cpu_step)
    );

    debounce reset_debounce (
        .clk(clk),
        .noisy_btn(btnC),
        .clean_btn(reset_clean)
    );

    cpu_top cpu (
        .clk(clk),
        .reset(reset_clean),
        .step_en(cpu_step),

        .state_dbg(state_dbg),
        .pc_dbg(pc_dbg),
        .ir_dbg(ir_dbg),

        .opcode_dbg(opcode_dbg),
        .rs_dbg(rs_dbg),
        .rt_dbg(rt_dbg),
        .rs_val_dbg(rs_val_dbg),
        .rt_val_dbg(rt_val_dbg),
        .alu_out_dbg(alu_out_dbg),

        .rd_dbg(rd_dbg),
        .rf_we_dbg(rf_we_dbg),
        .halted_dbg(halted_dbg)
    );

    always @(*) begin
        case (sw[1:0])
            2'b00: display_value = {8'd0, pc_dbg};
            2'b01: display_value = ir_dbg;
            2'b10: display_value = alu_out_dbg;
            2'b11: display_value = {8'd0, state_dbg, halted_dbg, opcode_dbg};
            default: display_value = 16'h0000;
        endcase
    end

    assign led[0] = state_dbg[0];
    assign led[1] = state_dbg[1];
    assign led[2] = state_dbg[2];
    assign led[3] = halted_dbg;

    seven_seg_display display (
        .clk(clk),
        .value(display_value),
        .seg(seg),
        .an(an)
    );

endmodule