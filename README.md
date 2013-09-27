PixelPerfect
============

This was an incredible project.

My team of four Computer Engineering students built this for the Fall 2012 Computer Design Lab at the University of Utah.

## Hardware
We developed custom hardware, including an original CPU architecture loosely based on CR16A instruction set, implemented from scratch in a hardware description language, and synthesized onto a Nexys 3 Spartan-6 FGPA. There are also drivers for VGA, UART, RAM, and push buttons. See `System` for the Xilinx project and the Verilog source code. 

## Assembly Application
We developed an application that allows the user to take a photo and then apply one of many image effects to the captured image, which is displayed on a VGA monitor. If you would like to subject yourself to reading assembly code, largely authored between the hours of 10pm and 6am, see `Application\main_app.cr16`.

## Tools
We developed several high level application tools to aid in building and debugging the hardware and software in the system. These include an Assembler, a UART reader, an image converter (for creating 8-bit bitmaps that could be written into device memory), and an application controller for interacting with the device.

## Documentation
See `Specification/ProjectReport.pdf` for a detailed, though hastily written, project report that describes many of the interesting challenges and solutions that went into this project.
See `Specification/CR16ISACustom.pdf` for a brief overview of hardware supported assembly instructions. Note that it does not include the pseudo instructions, which are most precisely defined in `Assembler/Assembler/Pseudo.cs`.
See `Specification/UserGuide.pdf` for instructions for getting the system up and running.


