`default_nettype none

module can_tx_path (
    input  logic        clk,
    input  logic        rst_n,
    input  logic        bit_tick,          // Advance TX on each bit_tick
    input  logic        enable,
    input  logic        tx_start,          // Pulse to start TX
    input  logic [10:0] tx_id,             // 11-bit CAN identifier
    input  logic [ 3:0] tx_dlc,            // Data length code (0–8)
    input  logic [63:0] tx_data,           // Data payload
    input  logic        can_rx,            // Monitor bus for arbitration
    output logic        can_tx,            // Drive this onto transceiver's TXD
    output logic        tx_done,           // 1-cycle pulse when TX finishes
    output logic        tx_busy,           // High during transmission
    output logic        arbitration_lost,  // High if lost arbitration
    output logic        tx_error           // CRC or ACK error
);

  typedef enum logic [4:0] {
    IDLE          = 4'd0,
    LOAD_FRAME    = 4'd1,
    SOF           = 4'd2,
    SEND_ID       = 4'd3,
    ARB_CHECK     = 4'd4,
    ABORT         = 4'd5,
    SEND_CTRL     = 4'd6,
    SEND_DATA     = 4'd7,
    SEND_CRC      = 4'd8,
    SEND_ACK_SLOT = 4'd9,
    INTERFRAME    = 4'd10
  } fsm_e;

  fsm_e can_tx_path_state, can_tx_path_state_next;

  always @(posedge clk) begin
    if (!rst_n) begin
      can_tx_path_state <= IDLE;
      can_tx            <= 1'd0;
      tx_done           <= 1'd0;
      tx_busy           <= 1'd0;
      arbitration_lost  <= 1'd0;
      tx_error          <= 1'd0;
    end else begin
      can_tx_path_state <= can_tx_path_state_next;
    end
  end

endmodule
