The following is our updated instruction mapping with incorporated alphas:

// ---------------------------------
//       Instruction Mapping
// ---------------------------------
// Value	|	Description
// 3'b000	|	IDLE
// 3'b001	|	W_LOAD
// 3'b010	|	W_EXEC
// 3'b011	|	NOT_USED
// 3'b100	|	RESET
// 3'b101	|	O_SHIFT
// 3'b110	|	O_EXEC
// 3'b111	|	IDLE
// ----------------------------------


Synchronous soft reset: 
A soft reset is performed between each set of weight loads to ensure the processing element (PE) remains active in every cycle, enabling fully pipelined operation. The reset logic and modified instruction mapping can be found in reconf_mac_tile.v 
This alpha is baked into the RTL and present in the Alpha1 directory, which has the entire design and also has the working test bench to verify this in the sim/ sub-directory.


Piplined output shifting:
Implemented a fully pipelined output shifting methodology, which allows the calculated output pixel values to begin shifting, as soon as the computation is completed in the PE. This is independent of the state of the neighboring PEs because it is flopped before heading south. 
The design is present in reconf_mac_tile.v and this is being tested in core_o_tb.
This alpha is baked into the RTL and present in the Alpha2 directory, which has the entire design and also has the working test bench to verify this in the sim/ sub-directory.



Sparsity aware clock gating:
Dynamically disable the computation if the incoming weight or activation is zero, which reduces unnecessary toggling and dynamic power consumption. The design is present in reconf_mac_tile.v and is tested and verified using core_o_tb.v
This alpha is baked into the RTL and present in the Alpha3 directory, which has the entire design and also has the working test bench to verify this in the sim/ sub-directory.



Maxpool: 
The SFU is capable of implementing a MaxPool2d layer. When enabled, the SFU computes the result of the MaxPool operation along with ReLU, with any kernel size and stride. This is verified for the MaxPool2d(2,2) present in VGG16. The design is present in sfu_max_pool.v and is compile clean.
