`default_nettype none

module can_rx_path (
    input  logic        clk,
    input  logic        rst_n,
    input  logic        can_rx,
    input  logic        sample_point,    // High during sampling
    input  logic        bit_tick,        // High at end of bit time
    input  logic        enable,
    input  logic        loopback_mode,
    input  logic        tx_echo_bit,     // If in loopback mode
    output logic        rx_frame_valid,  // High for 1 cycle when frame ready
    output logic [10:0] rx_id,           // 11-bit CAN identifier
    output logic [ 3:0] rx_dlc,          // Data length code (0–8)
    output logic [63:0] rx_data,         // Up to 8 bytes of data
    output logic        rx_error,        // Frame had CRC/stuff/format error
    output logic        rx_busy          // High while receiving a frame
);

  typedef enum logic [3:0] {
    IDLE           = 4'd0,
    WAIT_FOR_SOF   = 4'd1,
    RECV_ID        = 4'd2,
    RECV_CTRL      = 4'd3,
    RECV_DATA      = 4'd4,
    RECV_CRC       = 4'd5,
    RECV_ACK       = 4'd6,
    VALIDATE_FRAME = 4'd7,
    INTERFRAME     = 4'd8
  } fsm_e;

  fsm_e can_rx_path_state, can_rx_path_state_next;

  always @(posedge clk) begin
    if (!rst_n) begin
      can_rx_path_state <= IDLE;
      rx_frame_valid    <= 1'd0;
      rx_error          <= 1'd0;
      rx_busy           <= 1'd0;
      rx_dlc            <= 4'd0;
      rx_id             <= 11'd0;
      rx_data           <= 64'd0;
    end else begin
      can_rx_path_state <= can_rx_path_state_next;
    end
  end

endmodule
