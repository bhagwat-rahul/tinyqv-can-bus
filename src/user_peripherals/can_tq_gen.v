`default_nettype none

module can_tq_gen #(
    parameter int unsigned CLK_FREQ = 64000000  // 64 MHz
) (
    input  logic       clk,
    input  logic       rst_n,
    input  logic [5:0] brp,           // Baud Rate Prescaler (0-63) (0=1, 63=64 index based count)
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

  logic [5:0] brp_cnt;
  logic [4:0] total_tqs_per_bit;
  logic [4:0] tq_position_reg;

  typedef enum {
    SYNC,
    PROP,
    PHASE1,
    PHASE2
  } fsm_e;
  fsm_e segment_position, next_segment_position;

  always @(posedge clk) begin
    if (!rst_n) begin
      tq_tick               <= 1'b0;
      bit_tick              <= 1'b0;
      sample_point          <= 1'b0;
      sync_seg              <= 1'b0;
      prop_seg              <= 1'b0;
      phase_seg1            <= 1'b0;
      phase_seg2            <= 1'b0;
      brp_cnt               <= 6'b0;
      tq_position           <= 5'd1;
      segment_position      <= SYNC;
      next_segment_position <= SYNC;
    end else if (brp_cnt == brp) begin
      brp_cnt          <= 0;
      tq_tick          <= 1;
      segment_position <= next_segment_position;
      if (tq_position == total_tqs_per_bit) begin
        tq_position <= 5'd1;  // Reset to 1 at start of new bit
      end else begin
        tq_position <= tq_position + 1;  // Increment within bit
      end
    end else begin
      brp_cnt <= brp_cnt + 1;
      tq_tick <= 0;
    end
  end

  // Segment Counter
  always_comb begin
    if (tq_tick) begin
      unique case (segment_position)
        SYNC:   ;
        PROP:   ;
        PHASE1: ;
        PHASE2: ;
      endcase
    end
  end

  assign total_tqs_per_bit = 5'd1 + {1'b0, tseg1} + {2'b0, tseg2};
  assign tq_position       = tq_position_reg;
  assign sync_seg          = (segment_position == SYNC);
  assign prop_seg          = (segment_position == PROP);
  assign phase_seg1        = (segment_position == PHASE1);
  assign phase_seg2        = (segment_position == PHASE2);

endmodule
