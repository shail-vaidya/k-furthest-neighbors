In our project, the test bench works as the control unit and seamlessly drives the inputs to the DUT to utilize the parallelism that is baked into the RTL. This is common across the parts since we had completed all design and verification code by the first submission itself.

For Part2, we do not require a test bench, therefore this directory just contains all the design files in the verilog/ subdirectory.

core.v has the corelet.v and SRAMs.
corelet.v has the FPGA synthesized design.
l0.v has our implementation of the L0 FIFO.
ofifo.v has our implementation of the OFIFO.
sfu.v has our implementation of the SFU that does accumulation and ReLU.
pmem_512x128.v has our PSUM memory behavioral model sized to our needs.
xmem_256x32.v has our weight/activation memory behavioral model sized to our needs.
The others are common design files such as MAC, FIFO etc.