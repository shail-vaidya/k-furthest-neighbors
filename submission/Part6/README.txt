Synchronous soft reset: 
A soft reset instruction is given between every set of weight loads. This ensures that the PE is active in each cycle, allowing  for completely pipelined operation.
Piplined output shifting:
Implements a fully pipelined output shifting methodology, which allows the calculated output pixel values to begin shifting, as soon as the computation is completed in the PE. This is independent of the state of the neighboring PEs because it is flopped before heading south.
Maxpool: 
The SFU is capable of implementing a MaxPool2d layer. When enabled, the SFU computes the result of the MaxPool operation along with ReLU, with any kernel size and stride. This is verified for the MaxPool2d(2,2) present in VGG16.
Sparsity aware clock gating:
Dynamically disable the computation if the incoming weight or activation is zero, which reduces unnecessary toggling and dynamic power consumption.