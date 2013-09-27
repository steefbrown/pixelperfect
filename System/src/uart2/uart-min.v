`timescale 1ns / 1ps
//
// 115200 baud 8-N-1 serial port, using only Tx and Rx.
// (8 data bits, no parity, 1 stop bit, no flow control.)
// Configurable baud rate determined by clocking module, 16x oversampling
// for Rx data, Rx filtering, and configurable FIFO buffers for receiving
// and transmitting.
//
// Originally built by Grant Ayers.
//
// Extended to cope with variable processor speeds by latching data in
// and data out. (The problem is that the processor may hold read/write
// high for many clock ticks, when only a single operation is desired).
//
module uart_min(
    input clock,
    input reset,
    input pulse_en,
    input write,
    input read,
    input [7:0] data_in,   // tx going into uart, out of serial port
    output reg [7:0] data_out, // rx coming in from serial port, out of uart
    output [10:0] rx_count, tx_count,
    /*------------------------*/
    input RxD,
    output TxD
    );

    reg write_reg;
    reg [7:0] data_in_reg;
    wire [7:0] data_out_wire;


    // latch write signals for one pulse
    always @(posedge clock) begin
        if (reset || !pulse_en) begin
            write_reg <= 0;
            data_in_reg <= 0;
        end
        else if (pulse_en) begin
            write_reg <= write;
            data_in_reg <= data_in;
        end
    end

    reg [1:0] cur_state, next_state;

    always @(posedge clock)
        if (reset)
            cur_state <= 0;
        else
            cur_state <= next_state;

    // latch data_out according to state machine
    always @(posedge clock)
        if (reset)
            data_out <= 0;
        else if (next_state == 2)
            data_out <= data_out_wire;

    assign read_wire = (cur_state == 1);
    // force exactly one read to occur from the fifo at a time
    always @(*) begin
        next_state = cur_state;

        case(cur_state)
            0:  begin
                    if (read)
                        next_state = cur_state + 1'b1;
                end
            1:  begin
                    next_state = cur_state + 1'b1;
                end
            2:  begin
                    next_state = cur_state + 1'b1;
                end
            3:  begin
                    if (!read)
                        next_state = 0;
                end
			endcase
    end



    localparam DATA_WIDTH = 8; // Bit-width of FIFO data (should be 8)
    localparam ADDR_WIDTH = 10; // 2^ADDR_WIDTH words of FIFO space

    /* Clocking Signals */
    wire uart_tick, uart_tick_16x;

    /* Receive Signals */
    wire [7:0] rx_data;     // Raw bytes coming in from uart
    wire rx_data_ready;     // Synchronous pulse indicating this (^)
    wire rx_fifo_empty;

    /* Send Signals */
    reg tx_fifo_deQ = 0;
    reg tx_start = 0;
    wire tx_free;
    wire tx_fifo_empty;
    wire [7:0] tx_fifo_data_out;

    always @(posedge clock) begin
        if (reset) begin
            tx_fifo_deQ <= 0;
            tx_start <= 0;
        end
        else begin
            if (~tx_fifo_empty & tx_free & uart_tick) begin
                tx_fifo_deQ <= 1;
                tx_start <= 1;
            end
            else begin
                tx_fifo_deQ <= 0;
                tx_start <= 0;
            end
        end
    end

    uart_clock clocks (
        .clock          (clock),
        .uart_tick      (uart_tick),
        .uart_tick_16x  (uart_tick_16x)
    );

    uart_tx tx (
        .clock          (clock),
        .reset          (reset),
        .uart_tick      (uart_tick),
        .TxD_data       (tx_fifo_data_out),
        .TxD_start      (tx_start),
        .ready          (tx_free),
        .TxD            (TxD)
    );

    uart_rx rx (
        .clock          (clock),
        .reset          (reset),
        .RxD            (RxD),
        .uart_tick_16x  (uart_tick_16x),
        .RxD_data       (rx_data),
        .data_ready     (rx_data_ready)
    );

    FIFO_NoFull_Count #(
        .DATA_WIDTH     (DATA_WIDTH),
        .ADDR_WIDTH     (ADDR_WIDTH))
    tx_buffer (
        .clock          (clock),
        .reset          (reset),
        .enQ            (write_reg),
        .deQ            (tx_fifo_deQ),
        .data_in        (data_in_reg),
        .data_out       (tx_fifo_data_out),
        .empty          (tx_fifo_empty),
        .count          (tx_count)
    );

    FIFO_NoFull_Count #(
        .DATA_WIDTH     (DATA_WIDTH),
        .ADDR_WIDTH     (ADDR_WIDTH))
    rx_buffer (
        .clock          (clock),
        .reset          (reset),
        .enQ            (rx_data_ready),
        .deQ            (read_wire),
        .data_in        (rx_data),
        .data_out       (data_out_wire),
        .empty          (rx_fifo_empty),
        .count          (rx_count)
    );

endmodule
