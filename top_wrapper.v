module top_wrapper(
  input          i_rx,           // Input for UART RX
  output         o_tx,           // Output for UART TX
  input          i_clk_in1_p,    // Input clock to clocking wizard
  input          i_clk_in1_n,    // Input clock to clocking wizard
  input [3:0]    i_dip_switches, // Input dip switch to master block
  output [3:0]   o_led,          // Output of LED controller
  output         lck_out,        // Clocking wizard lock output
  output         clk_out         // Clocking wizard clock output
);
  // Wire declarations
  wire          aclk;
  wire          interrupt;
  wire [3:0]    awaddr;
  wire          awvalid;
  wire          awready;
  wire [31:0]   wdata;
  wire [3:0]    wstrb;
  wire          wvalid;
  wire          wready;
  wire [1:0]    bresp;
  wire          bvalid;
  wire          bready;
  wire [3:0]    araddr;
  wire          arvalid;
  wire          arready;
  wire [31:0]   rdata;
  wire [1:0]    rresp;
  wire          rvalid;
  wire          rready;
  wire [2:0]    mode;
  wire [3:0]    data_out;
  wire          dvalid;
  wire          lock_out;

  // Output of clocking wizard which is given as reset to other blocks
  assign clk_out = aclk;
  assign lck_out = lock_out;

  // Clocking wizard instantiation
  clk_wiz_0 clk_wiz_u0(
    .clk_in1_p      (i_clk_in1_p),
    .clk_in1_n      (i_clk_in1_n),
    .locked         (lock_out),
    .clk_out1       (aclk)
  );

  // Instantiate AXI UART Lite Slave
  axi_uartlite_0 axi_uartlite_u0(
    .rx                 (i_rx),
    .tx                 (o_tx),
    .s_axi_aclk         (aclk),
    .s_axi_aresetn      (lock_out),
    .interrupt          (interrupt),
    .s_axi_awaddr       (awaddr),
    .s_axi_awvalid      (awvalid),
    .s_axi_awready      (awready),
    .s_axi_wdata        (wdata),
    .s_axi_wstrb        (wstrb),
    .s_axi_wvalid       (wvalid),
    .s_axi_wready       (wready),
    .s_axi_bresp        (bresp),
    .s_axi_bvalid       (bvalid),
    .s_axi_bready       (bready),
    .s_axi_araddr       (araddr),
    .s_axi_arvalid      (arvalid),
    .s_axi_arready      (arready),
    .s_axi_rdata        (rdata),
    .s_axi_rresp        (rresp),
    .s_axi_rvalid       (rvalid),
    .s_axi_rready       (rready)
  );

  // Instantiate AXI Lite Master
  axi_lite_master axi_lite_master_u0(
    .i_axi_aclk_100MHZ  (aclk),
    .i_axi_rst_n        (lock_out),
    .i_axi_interrupt    (interrupt),
    .i_dip_status       (i_dip_switches),
    .i_axi_arready      (arready),
    .o_axi_araddr       (araddr),
    .o_axi_arvalid      (arvalid),
    .i_axi_rdata        (rdata),
    .i_axi_rvalid       (rvalid),
    .i_axi_rresp        (rresp),
    .o_axi_rready       (rready),
    .i_axi_awready      (awready),
    .o_axi_awaddr       (awaddr),
    .o_axi_awvalid      (awvalid),
    .o_axi_wdata        (wdata),
    .o_axi_wstrb        (wstrb),
    .o_axi_wvalid       (wvalid),
    .i_axi_wready       (wready),
    .i_axi_bvalid       (bvalid),
    .i_axi_bresp        (bresp),
    .o_axi_bready       (bready),
    .o_mode             (mode),
    .o_data_out         (data_out),
    .o_data_valid       (dvalid)
  );

  // LED controller
  assign o_led = led_out;
  led_controller led_controller_u0(
    .i_axi_aclk_100MHZ  (aclk),
    .i_rstn             (lock_out),
    .i_dvalid           (dvalid),
    .i_mode             (mode),
    .i_data             (data_out),
    .o_led_out          (led_out)
  );

endmodule
