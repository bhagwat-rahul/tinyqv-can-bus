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

  // State registers
  logic [5:0] brp_cnt_reg;
  logic [4:0] tq_position_reg;
  logic tq_tick_reg, bit_tick_reg, sample_point_reg;
  logic sync_seg_reg, prop_seg_reg, phase_seg1_reg, phase_seg2_reg;

  typedef enum {
    SYNC,
    PROP,
    PHASE1,
    PHASE2
  } fsm_e;
  fsm_e segment_position_reg;

  // Next state signals
  logic [5:0] brp_cnt_next;
  logic [4:0] tq_position_next;
  logic tq_tick_next, bit_tick_next, sample_point_next;
  logic sync_seg_next, prop_seg_next, phase_seg1_next, phase_seg2_next;
  fsm_e segment_position_next;

  // Combinational calculations
  logic [4:0] total_tqs_per_bit;
  assign total_tqs_per_bit = 5'd1 + {1'b0, tseg1} + {2'b0, tseg2};

  // Output assignments
  assign tq_tick = tq_tick_reg;
  assign bit_tick = bit_tick_reg;
  assign sample_point = sample_point_reg;
  assign sync_seg = sync_seg_reg;
  assign prop_seg = prop_seg_reg;
  assign phase_seg1 = phase_seg1_reg;
  assign phase_seg2 = phase_seg2_reg;
  assign tq_position = tq_position_reg;

  // Next state combinational logic
  always_comb begin
    // Default: hold current values
    brp_cnt_next = brp_cnt_reg;
    tq_position_next = tq_position_reg;
    segment_position_next = segment_position_reg;

    // Default outputs
    tq_tick_next = 1'b0;
    bit_tick_next = 1'b0;
    sample_point_next = 1'b0;
    sync_seg_next = 1'b0;
    prop_seg_next = 1'b0;
    phase_seg1_next = 1'b0;
    phase_seg2_next = 1'b0;

    // BRP counter logic
    if (brp_cnt_reg == brp) begin
      brp_cnt_next = 6'd0;
      tq_tick_next = 1'b1;

      // TQ position counter
      if (tq_position_reg == total_tqs_per_bit) begin
        tq_position_next = 5'd1;
        bit_tick_next = 1'b1;
      end else begin
        tq_position_next = tq_position_reg + 1;
      end

      // Segment transitions
      unique case (segment_position_reg)
        SYNC: begin
          if (tq_position_reg == 1) segment_position_next = PROP;
        end
        PROP: begin
          if (tq_position_reg == 2) segment_position_next = PHASE1;  // 1 TQ for PROP
        end
        PHASE1: begin
          if (tq_position_next == (2 + tseg1)) begin
            segment_position_next = PHASE2;
            sample_point_next = 1'b1;
          end
        end
        PHASE2: begin
          if (tq_position_next == total_tqs_per_bit) begin
            segment_position_next = SYNC;
          end
        end
      endcase

    end else begin
      brp_cnt_next = brp_cnt_reg + 1;
    end

    // Segment output flags
    unique case (segment_position_reg)
      SYNC:   sync_seg_next = 1'b1;
      PROP:   prop_seg_next = 1'b1;
      PHASE1: phase_seg1_next = 1'b1;
      PHASE2: phase_seg2_next = 1'b1;
    endcase
  end

  // Sequential logic - simple register updates
  always_ff @(posedge clk) begin
    if (!rst_n) begin
      brp_cnt_reg <= 6'd0;
      tq_position_reg <= 5'd1;
      segment_position_reg <= SYNC;
      tq_tick_reg <= 1'b0;
      bit_tick_reg <= 1'b0;
      sample_point_reg <= 1'b0;
      sync_seg_reg <= 1'b1;  // Start in SYNC
      prop_seg_reg <= 1'b0;
      phase_seg1_reg <= 1'b0;
      phase_seg2_reg <= 1'b0;
    end else begin
      brp_cnt_reg <= brp_cnt_next;
      tq_position_reg <= tq_position_next;
      segment_position_reg <= segment_position_next;
      tq_tick_reg <= tq_tick_next;
      bit_tick_reg <= bit_tick_next;
      sample_point_reg <= sample_point_next;
      sync_seg_reg <= sync_seg_next;
      prop_seg_reg <= prop_seg_next;
      phase_seg1_reg <= phase_seg1_next;
      phase_seg2_reg <= phase_seg2_next;
    end
  end

endmodule
