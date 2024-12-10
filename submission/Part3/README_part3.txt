In our project, the test bench works as the control unit and seamlessly drives the inputs to the DUT to utilize the parallelism that is baked into the RTL. This is common across the parts since we had completed all design and verification code by the first submission itself.

For Part3, we have a test bench that runs the design in the weight stationary mode and does not use the IFIFO. The design files are common across all subsequent parts including the alphas and reconfigurable array for WS and OS. The following is the addition in the sim/ directory that has the test bench itself and the required txt files.

Below is the description for the added files in the sim/ directory:

core_tb.v is the test bench file that runs the design in weight stationary mode and drives the desired inputs and instruction sequences in a back-to-back fashion with no idle cycles to continuously generate psums and eventually outputs. The test bench has display prints to show the progress of the simulation, including the data matched message. For thorough verification, we have also compared each psum along with comparing the final outputs. This is for the 8x8 layer of the network.

WS_activation.txt has the activation input in the form of:
#time0row7[msb-lsb],time0row6[msb-lst],....,time0row0[msb-lst]#
#time1row7[msb-lsb],time1row6[msb-lst],....,time1row0[msb-lst]#
#................#

WS_weight_kij{0-8}.txt has the weight input for each kij in the form of:
#col0row7[msb-lsb],col0row6[msb-lst],....,col0row0[msb-lst]#
#col1row7[msb-lsb],col1row6[msb-lst],....,col1row0[msb-lst]#
#................#

WS_psum.txt has the psum output in the form of:
#time0col7[msb-lsb],time0col6[msb-lst],....,time0col0[msb-lst]#
#time1col7[msb-lsb],time1col6[msb-lst],....,time1col0[msb-lst]#
#................#

WS_out.txt has the final output in the form of:
#time0col7[msb-lsb],time0col6[msb-lst],....,time0col0[msb-lst]#
#time1col7[msb-lsb],time1col6[msb-lst],....,time1col0[msb-lst]#
#................#
