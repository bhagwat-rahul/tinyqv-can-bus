`default_nettype none

module tt_um_bhagwat_rahul_can_harness #(
    parameter int unsigned CLK_FREQ = 64000000  // 64 MHz
) (
    input  logic       clk,      // Clock normally set to 64MHz
    input  logic       rst_n,    // Reset_n - low to reset
    input  logic       ena,      // design active, always 1 ignore
    input  logic [7:0] ui_in,    // In PMOD, always available.
    input  logic [7:0] uio_in,   // IOs: Input path
    output logic [7:0] uo_out,   // Out PMOD. Each wire only conn'd if periph selected
    output logic [7:0] uio_out,  // IOs: Output path
    output logic [7:0] uio_oe    // IOs: Enable path (active high: 0=input, 1=output)
    // Note that uo_out[0] is normally used for UART TX.
    // Note that ui_in[7] is normally used for UART RX.
    // ins are sync'd to clock, will introduce 2 cycle delay on ins.
);

  always_ff @(posedge clk) begin
    if (!rst_n) begin
      uo_out[7:1]  <= 7'd0;
      uio_out[7:0] <= 8'd0;
      uio_oe[7:0]  <= 8'd0;
    end else begin

    end
  end

endmodule
