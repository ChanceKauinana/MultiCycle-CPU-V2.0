`timescale 1ns / 1ps

module debounce(
    input clk,
    input noisy_btn,
    output reg clean_btn
);

    localparam [20:0] DEBOUNCE_LIMIT = 21'd1000000;

    reg [20:0] count = 21'd0;
    reg btn_sync_0 = 1'b0;
    reg btn_sync_1 = 1'b0;
    reg btn_state  = 1'b0;

    always @(posedge clk) begin
        btn_sync_0 <= noisy_btn;
        btn_sync_1 <= btn_sync_0;
    end

    always @(posedge clk) begin
        if (btn_state == btn_sync_1) begin
            count <= 21'd0;
        end
        else begin
            count <= count + 21'd1;

            if (count >= DEBOUNCE_LIMIT) begin
                btn_state <= btn_sync_1;
                count <= 21'd0;
            end
        end

        clean_btn <= btn_state;
    end

endmodule