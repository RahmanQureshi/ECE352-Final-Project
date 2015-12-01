## Register File Controller

The register file controller bypasses by looking at the specific instruction in IR4 and multiplexing between the ALUOut register (if IR4 was an add, sub, nand, etc) and the MDR register(for loads)

## Execute Controller

After the RFC was written, the data output from memory was connected to a multiplexer that put either the ALU's or the memories' output to the ALUOut register. Thus, only one register is being used for write back.

## Instruction 8b00000000
The 0 instruction gets loaded at the beginning (first 5 cycles) and end of program. This is load r0,(r0), which gets executed and is the reason why r0 changes.
r0 moves around because each time it loads from itself, into itself, a new value.

## Known Issues
In modelsim, branches work, but on the DE1 board, branches branch the instruction after the instruction it is supposed to branch to.