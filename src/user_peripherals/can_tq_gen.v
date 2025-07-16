`default_nettype none

module can_tq_gen #(
    parameter int unsigned CLK_FREQ = 64000000  // 64 MHz
) (
    input logic clk,
    input logic rst_n,

    // Configuration registers (CPU-writable)
    input  logic [5:0] brp,           // Baud Rate Prescaler (1-64)
    input  logic [3:0] tseg1,         // Time Segment 1: Prop_Seg + Phase_Seg1 (1-16)
    input  logic [2:0] tseg2,         // Time Segment 2: Phase_Seg2 (1-8)
    input  logic [1:0] sjw,           // Synchronization Jump Width (1-4)
    output logic       tq_tick,       // Time quantum pulse
    output logic       bit_tick,      // Bit time pulse
    output logic       sample_point,  // Sample point pulse
    output logic       sync_seg,
    output logic       prop_seg,
    output logic       phase_seg1,
    output logic       phase_seg2,
    output logic [4:0] tq_position    // Which TQ within current bit (1 to total_tq)
);

  typedef enum logic [1:0] {
    IDLE        = 1'd0,
    TQ_COUNTING = 1'd1
  } fsm_e;

  fsm_e tq_state, tq_state_next;

  always @(posedge clk) begin
    if (!rst_n) begin
      tq_state     <= IDLE;
      tq_tick      <= 1'b0;
      bit_tick     <= 1'b0;
      sample_point <= 1'b0;
      sync_seg     <= 1'b0;
      prop_seg     <= 1'b0;
      phase_seg1   <= 1'b0;
      phase_seg2   <= 1'b0;
      tq_position  <= 5'd1;
    end else begin
      tq_state <= tq_state_next;
    end
  end
endmodule
