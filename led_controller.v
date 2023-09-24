module led_controller(
  input         	i_axi_aclk_100MHZ,
  input         	i_rstn,
  input         	i_dvalid,
  input [2:0]   	i_mode,
  input [3:0]   	i_data,
  output reg [3:0] 	o_led_out,
  output reg  		o_slwclk
);

  // Slow clock counter
  reg [27:0] 		slwclk_cntr = 0;
  
  // Shift counters
  reg [2:0] 		cntr_shift = 0;
  reg [3:0] 		cntr_blink = 0;
  reg [3:0] 		cntr_mod_n = 4'b0001;

  // Registers for mode and data storage
  reg [2:0] 		d2_aclk_mode;
  reg [3:0] 		d2_aclk_data;
  reg [2:0] 		d1_aclk_mode;
  reg [3:0] 		d1_aclk_data;

  // Registers for mode and data with slow clock
  reg [2:0] 		d2_mode;
  reg [3:0] 		d2_data;
  reg [2:0] 		d1_mode;
  reg [3:0] 		d1_data;

  // Shift register and slow clock signal
  reg [3:0] reg_shift = 0;
  reg reg_slwclk = 0;
  
  // Blinking data and mode registers
  reg [3:0] 		reg_data_blink = 4'b1111;
  reg [2:0] 		reg_mode;
  reg [3:0] 		reg_data;

  always @(posedge i_axi_aclk_100MHZ) begin
    // Slow clock generation
    if (i_rstn == 0) begin
      // o_led_out <= 0; // Commented out as this is redundant
      o_slwclk 				<= 0;
    end
    else begin
      if (slwclk_cntr == 50000000) begin
        slwclk_cntr 		<= 0;
        reg_slwclk 			<= ~reg_slwclk;
        o_slwclk 			<= reg_slwclk;
      end
      else
        slwclk_cntr 		<= slwclk_cntr + 1;
    end
  end

  always @(posedge i_axi_aclk_100MHZ) begin
    // Storing the data in registers
    if (i_rstn == 0) begin
      d2_aclk_mode 			<= 0;
      d2_aclk_data 			<= 0;
    end
    else if (i_dvalid) begin
      reg_mode 				<= i_mode;
      reg_data 				<= i_data;
    end
  end

  always @(posedge i_axi_aclk_100MHZ) begin
    // Sampling the stored data with fast clock
    d1_aclk_mode 			<= reg_mode;
    d2_aclk_mode 			<= d1_aclk_mode;
    d1_aclk_data 			<= reg_data;
    d2_aclk_data 			<= d1_aclk_data;
  end

  always @(posedge o_slwclk) begin
    // Sampling the data with slow clock
    if (i_rstn == 0) begin
      d1_mode 				<= 0;
      d2_mode 				<= 0;
      d1_data 				<= 0;
      d2_data 				<= 0;
    end
    else begin
      d1_mode 				<= d2_aclk_mode;
      d2_mode 				<= d1_mode;
      d1_data 				<= d2_aclk_data;
      d2_data 				<= d1_data;
    end
  end

  always @(posedge o_slwclk) begin
    // Cases
    if (i_rstn == 0) begin
      cntr_shift 			<= 0;
      cntr_blink 			<= 0;
      cntr_mod_n 			<= 0;
      o_led_out 			<= 0;
    end
    else begin
      case (d2_mode)
        3'b001: begin // Displaying the input
          o_led_out 		<= d2_data;
          cntr_shift 		<= 0;
          cntr_blink 		<= 0;
          cntr_mod_n 		<= 0;
        end

        3'b010: begin // Shifting left
          cntr_blink 		<= 0;
          cntr_mod_n 		<= 0;
          if (cntr_shift == 0) begin
            reg_shift 		<= d2_data;
            cntr_shift		<= cntr_shift + 1;
          end
          else if (cntr_shift > 0 && cntr_shift < 5) begin
            cntr_shift 		<= cntr_shift + 1;
            reg_shift[0] 	<= reg_shift[3];
            reg_shift[3] 	<= reg_shift[2];
            reg_shift[2] 	<= reg_shift[1];
            reg_shift[1] 	<= reg_shift[0];
            o_led_out 		<= reg_shift;
          end
          else
            o_led_out 		<= d2_data;
        end

        3'b011: begin // Blinking n times
          cntr_shift 		<= 0;
          if (cntr_blink < 2 * d2_data) begin
            cntr_blink 		<= cntr_blink + 1;
            reg_data_blink 	<= ~reg_data_blink;
            o_led_out 		<= reg_data_blink;
          end
          else
            cntr_blink 		<= cntr_blink;
        end

        3'b100: begin // Mod n counter
          cntr_shift 		<= 0;
          cntr_blink 		<= 0;
          if (cntr_mod_n 	<= d2_data) begin
            cntr_mod_n 		<= cntr_mod_n + 1;
            o_led_out 		<= cntr_mod_n;
          end
          else
            cntr_mod_n 		<= 4'b0001;
        end
      endcase
    end
  end
endmodule
