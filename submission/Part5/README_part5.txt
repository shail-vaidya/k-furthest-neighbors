In our project, the test bench works as the control unit and seamlessly drives the inputs to the DUT to utilize the parallelism that is baked into the RTL. This is common across the parts since we had completed all design and verification code by the first submission itself.

For Part5, we have a test bench that runs the design in the output stationary mode and also uses the IFIFO. The design files are common across all subsequent parts including the alphas and reconfigurable array for WS and OS. The following is the addition in the sim/ directory that has the test bench itself and the required txt files.

Below is the description for the added files in the sim/ directory:

core_o_tb.v is the test bench file that runs the design in output stationary mode and drives the desired inputs and instruction sequences in a back-to-back fashion with no idle cycles. This continuously generates the output pixels and also flushes them out using the special pipelined shifting instruction that we implemented. The test bench has display prints to show the progress of the simulation, including the data matched message.

OS_activation.txt has the activation input from the first convolution layer of the network after subjecting to ReLU to get rid of any negative activation. It is in the form of:
//1st  file_write of act should be ic=0(row) for all op pixels [time3+hrow0,  time2+hrow0,  time1+hrow0,  time0+hrow0,  time3row0,    time2row0,    time1row0,    time0row0]
//2nd  file_write of act should be ic=0(row) for all op pixels [time4+hrow0,  time3+hrow0,  time2+hrow0,  time1+hrow0,  time4row0,    time3row0,    time2row0,    time1row0]
//3rd  file_write of act should be ic=0(row) for all op pixels [time5+hrow0,  time4+hrow0,  time3+hrow0,  time2+hrow0,  time5row0,    time4row0,    time3row0,    time2row0]
//4th  file_write of act should be ic=0(row) for all op pixels [time3+2hrow0, time2+2hrow0, time1+2hrow0, time0+2hrow0, time3+hrow0,  time2+hrow0,  time1+hrow0,  time0+hrow0]
//5nd  file_write of act should be ic=0(row) for all op pixels [time4+2hrow0, time3+2hrow0, time2+2hrow0, time1+2hrow0, time4+hrow0,  time3+hrow0,  time2+hrow0,  time1+hrow0]
//6th  file_write of act should be ic=0(row) for all op pixels [time5+2hrow0, time4+2hrow0, time3+2hrow0, time2+2hrow0, time5+hrow0,  time4+hrow0,  time3+hrow0,  time2+hrow0]
//7th  file_write of act should be ic=0(row) for all op pixels [time3+3hrow0, time2+3hrow0, time1+3hrow0, time0+3hrow0, time3+2hrow0, time2+2hrow0, time1+2hrow0, time0+2hrow0]
//8nd  file_write of act should be ic=0(row) for all op pixels [time4+3hrow0, time3+3hrow0, time2+3hrow0, time1+3hrow0, time4+2hrow0, time3+2hrow0, time2+2hrow0, time1+2hrow0]
//9th  file_write of act should be ic=0(row) for all op pixels [time5+3hrow0, time4+3hrow0, time3+3hrow0, time2+3hrow0, time5+2hrow0, time4+2hrow0, time3+2hrow0, time2+2hrow0]
//Same follows for ic=1 and ic=2


OS_weight.txt has the weight input in the form of:
//1st  file_write of weights should be kij=0, ic=0(row) for all oc(col) values 	[col7row0, col6row0, col5row0, col4row0, col3row0, col2row0, col1row0, col0row0]
//2nd  file_write of weights should be kij=1, ic=0(row) for all oc(col) values	[col7row0, col6row0, col5row0, col4row0, col3row0, col2row0, col1row0, col0row0]
//...
//9th  file_write of weights should be kij=8, ic=0(row) for all oc(col) values	[col7row0, col6row0, col5row0, col4row0, col3row0, col2row0, col1row0, col0row0]
//10th file_write of weights should be kij=0, ic=1(row) for all oc(col) values	[col7row1, col6row1, col5row1, col4row1, col3row1, col2row1, col1row1, col0row1]
//11th file_write of weights should be kij=1, ic=1(row) for all oc(col) values	[col7row1, col6row1, col5row1, col4row1, col3row1, col2row1, col1row1, col0row1]
//...
//18th file_write of weights should be kij=8, ic=1(row) for all oc(col) values	[col7row1, col6row1, col5row1, col4row1, col3row1, col2row1, col1row1, col0row1]
//19th file_write of weights should be kij=0, ic=2(row) for all oc(col) values	[col7row2, col6row2, col5row2, col4row2, col3row2, col2row2, col1row2, col0row2]
//20th file_write of weights should be kij=1, ic=2(row) for all oc(col) values	[col7row2, col6row2, col5row2, col4row2, col3row2, col2row2, col1row2, col0row2]
//...
//27nd file_write of weights should be kij=8, ic=2(row) for all oc(col) values	[col7row2, col6row2, col5row2, col4row2, col3row2, col2row2, col1row2, col0row2]


OS_out.txt has the final output in the form of:
#output_pixel7_output_channel7,output_pixel7_output_channel6.....output_pixel7_output_channel0#
#output_pixel6_output_channel7,output_pixel6_output_channel6.....output_pixel6_output_channel0#
#output_pixel5_output_channel7,output_pixel5_output_channel6.....output_pixel5_output_channel0#
#output_pixel4_output_channel7,output_pixel4_output_channel6.....output_pixel4_output_channel0#
#output_pixel3_output_channel7,output_pixel3_output_channel6.....output_pixel3_output_channel0#
#output_pixel2_output_channel7,output_pixel2_output_channel6.....output_pixel2_output_channel0#
#output_pixel1_output_channel7,output_pixel1_output_channel6.....output_pixel1_output_channel0#
#output_pixel0_output_channel7,output_pixel0_output_channel6.....output_pixel0_output_channel0#
#................#
