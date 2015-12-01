module FetchController
(
	reset, clock, IR1Out, IR2Out, IR3Out, IR4Out,
	PCSel, PCwrite, IR1Enable, AddrSel
);

	input reset;
	input clock;
	input [7:0] IR1Out, IR2Out, IR3Out, IR4Out;
	output PCSel, PCwrite, IR1Enable, AddrSel;
	reg [3:0] state;
	reg [3:0] instr;

/*****************************************************************************
 *                         Parameter Declarations                            *
 *****************************************************************************/

	parameter [3:0] reset_s = 0, c1 = 1, c2 = 2, c3_asn = 3,
					c4_asnsh = 4, c3_shift = 5, c3_ori = 6,
					c4_ori = 7, c5_ori = 8, c3_load = 9, c4_load = 10,
					c3_store = 11, c3_bpz = 12, c3_bz = 13, c3_bnz = 14,
					stop = 15;

/*****************************************************************************
 *                         Combination Logic                                 *
 *****************************************************************************/
 
	assign AddrSel = 0;
	assign PCSel = 1; /* To Change For Branches */
	assign PCwrite = 1;
	assign IR1Enable = 1;
 
	always@(*)
	begin
		instr = IR4Out[3:0];
	end
 
	always@(*)
	begin	
		if(instr == 4'b0100 | instr == 4'b0110 | instr == 4'b1000) state = c3_asn;
		else if( instr[2:0] == 3'b011 ) state = c3_shift;
		else if( instr[2:0] == 3'b111 ) state = c3_ori;
		else if( instr == 4'b0000 ) state = c3_load;
		else if( instr == 4'b0010 ) state = c3_store;
		else if( instr == 4'b1101 ) state = c3_bpz;
		else if( instr == 4'b0101 ) state = c3_bz;
		else if( instr == 4'b1001 ) state = c3_bnz;
		else if( instr == 4'b1010 ) state = c1; // nop
		else if( instr == 4'b0001 ) state = stop;
		else state = 0;
	end

endmodule