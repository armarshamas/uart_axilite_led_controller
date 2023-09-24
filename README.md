# FPGA LED Control Project Readme

## Overview

This repository contains the source code and documentation for an FPGA project aimed at precise control and data communication with LEDs and a DIP switch integrated into the AC701 Artix-7 FPGA board. The project utilizes Xilinx UART Lite IP for UART communication and control. This `readme.md` file provides an overview of the project, its components, objectives, and usage instructions.

## Project Description

The project involves the following major components:

1. **UART Lite IP AXI Slave:** This block receives data from the UART interface, enabling communication with external devices, such as a host PC. It interprets incoming data for processing within the FPGA.

2. **AXI Master:** Acting as a controller, this block generates commands and instructions for other FPGA components. It communicates with the UART Lite IP AXI Slave to relay commands from the host PC and interacts with the Dip Switch block to gather user input. It orchestrates data flow within the FPGA.

3. **LED Controller:** Responsible for managing the LEDs, this block processes instructions from the AXI Master. It controls LED behavior, including turning them on/off, blinking, or creating patterns, based on received commands.

4. **Clocking Wizard:** This block provides precise clock signals, ensuring proper synchronization and timing for FPGA components. It plays a critical role in maintaining accurate data processing and LED control.

5. **Dip Switch:** Functioning as an input source, this block represents physical switches that users can toggle. It sends signals to the AXI Master, conveying user preferences and allowing for FPGA customization based on Dip Switch configurations.

6. **LEDs:** These visible outputs respond to commands from the LED Controller. Depending on instructions from the AXI Master, LEDs exhibit various behaviors, providing a visual representation of FPGA processes and interactions.

## Objectives

The project aims to achieve the following objectives:

- Implement UART communication for data reception and interpretation.
- Interface with GPIO pins to control LEDs and monitor DIP switch status.
- Configure UART module settings such as baud rate.
- Successfully synthesize the Verilog/VHDL code using Xilinx Vivado.
- Program the FPGA board with the generated bitstream.
- Optimize the design for logic utilization and power efficiency.
- Verify functionality through functional testing.
- Create comprehensive documentation for the project.

## Getting Started

To get started with the project, follow these steps:

1. Clone this repository to your local machine.
2. Open the project in Xilinx Vivado or your preferred FPGA development environment.
3. Review the documentation for detailed information on usage and configuration.
4. Synthesize the design and generate a bitstream file.
5. Program your AC701 FPGA board with the generated bitstream.
6. Test the functionality by sending commands from a host PC and observing LED responses.

## Documentation

Detailed documentation, including code explanations, usage instructions, and design process, can be found in the documentation folder.

## Contributing

If you'd like to contribute to this project, please fork the repository, make your changes, and submit a pull request. We welcome contributions, bug reports, and feature requests.

## License

This project is licensed under the [MIT License].

## Acknowledgments

We would like to acknowledge the support and resources provided by [Xilinx](https://www.xilinx.com/) for FPGA development.
