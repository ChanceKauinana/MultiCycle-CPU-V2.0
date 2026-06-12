`timescale 1ns / 1ps

module debounce(
    input clk,            // 100 MHz FPGA clock
    input noisy_btn,      // raw, noisy pushbutton
    output reg clean_btn  // debounced output
);

    reg [19:0] count = 0;          // counts up to ~10 ms
    reg btn_sync_0 = 0;
    reg btn_sync_1 = 0;
    reg btn_state = 0;

    // First: synchronize the asynchronous button to the clock domain
    always @(posedge clk) begin
        btn_sync_0 <= noisy_btn;
        btn_sync_1 <= btn_sync_0;
    end

    // Then: debounce logic
    always @(posedge clk) begin
        if (btn_state == btn_sync_1) begin
            count <= 0; // button stable, reset counter
        end else begin
            count <= count + 1;
            if (count == 20'd1_000_000) begin // ~10 ms @100 MHz
                btn_state <= btn_sync_1;
                count <= 0;
            end
        end
        clean_btn <= btn_state;
    end

endmodule
