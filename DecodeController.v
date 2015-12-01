module DecodeController
(
	reset, clock, IR1Out, IR2Out, IR3Out, IR4Out,
	IR2Enable
);
	input reset, clock;
	input [7:0] IR1Out, IR2Out, IR3Out, IR4Out;
	output IR2Enable;
	
	assign IR2Enable = 1'b1;

endmodule