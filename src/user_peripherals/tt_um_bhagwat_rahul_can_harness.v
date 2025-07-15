`default_nettype none

module tt_um_bhagwat_rahul_can_harness #(
    parameter int unsigned BAUD_RATE = 500000,
    parameter int unsigned CLK_FREQ = 64000000,  // 64 MHz
    parameter logic [4:0] OVS_FACTOR = 16  // Oversampling Factor
) (
    input  logic       clk,         // Clock normally set to 64MHz
    input  logic       rst_n,       // Reset_n - low to reset
    input  logic       ena,         // design active, always 1 ignore
    input  logic       data_write,  // Data write request from the TinyQV core
    input  logic [7:0] ui_in,       // In PMOD, always available.
    input  logic [7:0] uio_in,      // IOs: Input path
    input  logic [3:0] address,     // Address within this peripheral's address space
    input  logic [7:0] data_in,     // Data in, valid when data_write is high
    output logic [7:0] uo_out,      // Out PMOD. Each wire only conn'd if periph selected
    output logic [7:0] data_out,    // Data out, set in accordance w supplied address
    output logic [7:0] uio_out,     // IOs: Output path
    output logic [7:0] uio_oe       // IOs: Enable path (active high: 0=input, 1=output)
    // Note that uo_out[0] is normally used for UART TX.
    // Note that ui_in[7] is normally used for UART RX.
    // ins are sync'd to clock, will introduce 2 cycle delay on ins.
);

  logic baud_tick, tick_16x;

  always_ff @(posedge clk) begin
    if (!rst_n) begin
      // Do reset stuff
    end else begin

    end
  end

  baud_gen #(
      .BAUD_RATE (BAUD_RATE),
      .CLK_FREQ  (CLK_FREQ),
      .OVS_FACTOR(OVS_FACTOR)
  ) baud_gen_a (
      .clk(clk),
      .rst_n(rst_n),
      .baud_tick(baud_tick),
      .tick_16x(tick_16x)
  );

endmodule
