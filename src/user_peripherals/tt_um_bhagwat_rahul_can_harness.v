`default_nettype none

module tt_um_bhagwat_rahul_can_harness #(
    parameter int unsigned BAUD_RATE = 500000,
    parameter int unsigned CLK_FREQ = 64000000,  // 64 MHz
    parameter logic [4:0] OVS_FACTOR = 16  // Oversampling Factor
) (
    input        clk,         // Clock normally set to 64MHz.
    input        rst_n,       // Reset_n - low to reset.
    input  [7:0] ui_in,       // In PMOD, always available.
    output [7:0] uo_out,      // Out PMOD. Each wire only connected if peripheral selected.
    input  [3:0] address,     // Address within this peripheral's address space
    input        data_write,  // Data write request from the TinyQV core.
    input  [7:0] data_in,     // Data in, valid when data_write is high.
    output [7:0] data_out     // Data out, set in accordance w supplied address

    // Note that uo_out[0] is normally used for UART TX.
    // Note that ui_in[7] is normally used for UART RX.
    // ins are sync'd to clock, will introduce 2 cycle delay on ins.
);

  logic baud_tick, tick_16x;

  always @(posedge clk) begin
    if (rst_n == 0) begin
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
