`default_nettype none

module baud_gen #(
    parameter int unsigned BAUD_RATE = 500000,
    parameter int unsigned CLK_FREQ = 64000000,  // 64 MHz
    parameter logic [4:0] OVS_FACTOR = 16  // Oversampling Factor
) (
    input  logic clk,
    input  logic rst_n,
    output logic baud_tick,
    output logic tick_16x
);
  localparam logic [47:0] DIVISORFP_16 = (CLK_FREQ << 16) / (BAUD_RATE * OVS_FACTOR);
  localparam int unsigned OVSWIDTH = $clog2(OVS_FACTOR);

  logic [48:0] acc;
  logic [OVSWIDTH-1:0] oversample_counter;
  logic prev_tick_16x, raw_tick, tick_pulse;

  assign raw_tick   = acc[16];
  assign tick_pulse = (raw_tick ^ prev_tick_16x);

  initial begin
    if ((OVS_FACTOR & (OVS_FACTOR - 1)) != 0)
      $fatal(1, "OVS_FACTOR must be power of 2, got %0d", OVS_FACTOR);
  end

  always_ff @(posedge clk or posedge rst_n) begin
    if (rst_n == 0) begin
      acc <= 49'd0;
      oversample_counter <= {OVSWIDTH{1'b0}};
      baud_tick <= 1'b0;
      prev_tick_16x <= 1'b0;
      tick_16x <= 1'b0;
    end else begin
      acc <= acc + {1'b0, DIVISORFP_16};
      prev_tick_16x <= raw_tick;
      tick_16x <= tick_pulse;
      if (tick_pulse) begin
        if (oversample_counter == OVSWIDTH'(int'(OVS_FACTOR) - 1)) begin
          oversample_counter <= {OVSWIDTH{1'b0}};
          baud_tick <= 1'b1;
        end else begin
          oversample_counter <= oversample_counter + 1'b1;
          baud_tick <= 1'b0;
        end
      end else begin
        baud_tick <= 1'b0;
      end
    end
  end
endmodule
