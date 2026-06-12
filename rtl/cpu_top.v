`timescale 1ns / 1ps

module cpu_top (
    input clk,
    input reset,
    input step_en,

    output [2:0] state_dbg,
    output [7:0] pc_dbg,
    output [15:0] ir_dbg,

    output [3:0] opcode_dbg,
    output [3:0] rs_dbg,
    output [3:0] rt_dbg,
    output [15:0] rs_val_dbg,
    output [15:0] rt_val_dbg,
    output [15:0] alu_out_dbg,

    output [3:0] rd_dbg,
    output rf_we_dbg,
    output halted_dbg
);

    localparam [2:0]
        S_FETCH   = 3'd0,
        S_DECODE  = 3'd1,
        S_EXECUTE = 3'd2,
        S_WB      = 3'd3;

    localparam [3:0]
        OP_NOP  = 4'h0,
        OP_ADD  = 4'h1,
        OP_SUB  = 4'h2,
        OP_AND  = 4'h3,
        OP_OR   = 4'h4,
        OP_XOR  = 4'h5,
        OP_HALT = 4'hF;

    reg [2:0] state;
    reg [2:0] next_state;

    reg [7:0] pc;
    reg [7:0] pc_next;

    reg [15:0] ir;
    reg [15:0] ir_next;

    reg [15:0] alu_out;
    reg [15:0] alu_out_next;

    reg halted;
    reg halted_next;

    wire [3:0] opcode;
    wire [3:0] rd;
    wire [3:0] rs;
    wire [3:0] rt;

    assign opcode = ir[15:12];
    assign rd     = ir[11:8];
    assign rs     = ir[7:4];
    assign rt     = ir[3:0];

    reg [15:0] rf [0:7];

    wire [15:0] rf_rs_data;
    wire [15:0] rf_rt_data;

    reg rf_we;
    reg [2:0] rf_waddr;
    reg [15:0] rf_wdata;

    assign rf_rs_data = rf[rs[2:0]];
    assign rf_rt_data = rf[rt[2:0]];

    reg [15:0] imem [0:255];

    integer i;

    initial begin
        for (i = 0; i < 256; i = i + 1) begin
            imem[i] = 16'h0000;
        end

        // Demo program

        // ADD r5 = r1 + r2 => 20 + 30 = 50
        imem[8'd0] = 16'h1512;

        // SUB r6 = r4 - r3 => 50 - 40 = 10
        imem[8'd1] = 16'h2643;

        // AND r7 = r6 & r7 => 10 & 80 = 0
        imem[8'd2] = 16'h3767;

        // OR r5 = r5 | r3 => 50 | 40 = 58
        imem[8'd3] = 16'h4553;

        // XOR r4 = r1 ^ r2
        imem[8'd4] = 16'h5412;

        // HALT
        imem[8'd5] = 16'hF000;
    end

    wire [15:0] alu_a;
    wire [15:0] alu_b;
    reg [15:0] alu_result;

    assign alu_a = rf_rs_data;
    assign alu_b = rf_rt_data;

    always @(*) begin
        alu_result = 16'd0;

        case (opcode)
            OP_ADD:  alu_result = alu_a + alu_b;
            OP_SUB:  alu_result = alu_a - alu_b;
            OP_AND:  alu_result = alu_a & alu_b;
            OP_OR:   alu_result = alu_a | alu_b;
            OP_XOR:  alu_result = alu_a ^ alu_b;
            default: alu_result = 16'd0;
        endcase
    end

    always @(posedge clk) begin
        if (reset) begin
            state   <= S_FETCH;
            pc      <= 8'd0;
            ir      <= 16'd0;
            alu_out <= 16'd0;
            halted  <= 1'b0;

            rf[0] <= 16'd10;
            rf[1] <= 16'd20;
            rf[2] <= 16'd30;
            rf[3] <= 16'd40;
            rf[4] <= 16'd50;
            rf[5] <= 16'd60;
            rf[6] <= 16'd70;
            rf[7] <= 16'd80;
        end
        else if (step_en) begin
            state   <= next_state;
            pc      <= pc_next;
            ir      <= ir_next;
            alu_out <= alu_out_next;
            halted  <= halted_next;

            if (rf_we) begin
                rf[rf_waddr] <= rf_wdata;
            end
        end
    end

    always @(*) begin
        next_state = state;

        if (halted) begin
            next_state = state;
        end
        else begin
            case (state)
                S_FETCH: begin
                    next_state = S_DECODE;
                end

                S_DECODE: begin
                    next_state = S_EXECUTE;
                end

                S_EXECUTE: begin
                    if (opcode == OP_HALT) begin
                        next_state = S_EXECUTE;
                    end
                    else begin
                        next_state = S_WB;
                    end
                end

                S_WB: begin
                    next_state = S_FETCH;
                end

                default: begin
                    next_state = S_FETCH;
                end
            endcase
        end
    end

    always @(*) begin
        pc_next      = pc;
        ir_next      = ir;
        alu_out_next = alu_out;
        halted_next  = halted;

        rf_we    = 1'b0;
        rf_waddr = 3'd0;
        rf_wdata = 16'd0;

        if (!halted) begin
            case (state)

                S_FETCH: begin
                    ir_next = imem[pc];
                    pc_next = pc + 8'd1;
                end

                S_DECODE: begin
                    // Register values are read automatically through rf_rs_data and rf_rt_data.
                end

                S_EXECUTE: begin
                    if (opcode == OP_HALT) begin
                        halted_next = 1'b1;
                    end
                    else begin
                        alu_out_next = alu_result;
                    end
                end

                S_WB: begin
                    if (
                        opcode == OP_ADD ||
                        opcode == OP_SUB ||
                        opcode == OP_AND ||
                        opcode == OP_OR  ||
                        opcode == OP_XOR
                    ) begin
                        rf_we    = 1'b1;
                        rf_waddr = rd[2:0];
                        rf_wdata = alu_out;
                    end
                end

                default: begin
                    // Do nothing.
                end

            endcase
        end
    end

    assign state_dbg   = state;
    assign pc_dbg      = pc;
    assign ir_dbg      = ir;

    assign opcode_dbg  = opcode;
    assign rd_dbg      = rd;
    assign rs_dbg      = rs;
    assign rt_dbg      = rt;

    assign rs_val_dbg  = rf_rs_data;
    assign rt_val_dbg  = rf_rt_data;
    assign alu_out_dbg = alu_out;

    assign rf_we_dbg   = rf_we;
    assign halted_dbg  = halted;

endmodule