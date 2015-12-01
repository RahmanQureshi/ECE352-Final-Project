module RFController
(
reset, IR1Out, IR2Out, IR3Out, IR4Out, clock,
IRLoad, R1R2Load, R1Sel, FlagWrite,
R1MuxSel, R2MuxSel
);

	input	reset, clock;
	input [7:0] IR1Out, IR2Out, IR3Out, IR4Out;
	output	R1R2Load, IRLoad, R1Sel;
	output FlagWrite;
	output [2:0] R1MuxSel, R2MuxSel;
	//output	[3:0] state;
	
	reg [2:0] R1MuxSel, R2MuxSel;
	reg FlagWrite;
	reg R1Sel;
	reg [3:0]	state;
	reg [3:0] instr;
	
	reg [3:0] state2; // IR4 - WriteBack
	reg [3:0] instr2;

/*****************************************************************************
 *                         Parameter Declarations                            *
 *****************************************************************************/

	parameter [3:0] reset_s = 0, c1 = 1, c2 = 2, c3_asn = 3,
					c4_asnsh = 4, c3_shift = 5, c3_ori = 6,
					c4_ori = 7, c5_ori = 8, c3_load = 9, c4_load = 10,
					c3_store = 11, c3_bpz = 12, c3_bz = 13, c3_bnz = 14,
					stop = 15;

/*****************************************************************************
 *                         Combination Logic 1 (Data Hazards)                *
 *****************************************************************************/
	always@(*)
	begin
		instr2 = IR4Out[3:0];
	end
 
	always@(*)
	begin	
		if(instr2 == 4'b0100 | instr2 == 4'b0110 | instr2 == 4'b1000) state2 = c3_asn;
		else if( instr2[2:0] == 3'b011 ) state2 = c3_shift;
		else if( instr2[2:0] == 3'b111 ) state2 = c3_ori;
		else if( instr2 == 4'b0000 ) state2 = c3_load;
		else if( instr2 == 4'b0010 ) state2 = c3_store;
		else if( instr2 == 4'b1101 ) state2 = c3_bpz;
		else if( instr2 == 4'b0101 ) state2 = c3_bz;
		else if( instr2 == 4'b1001 ) state2 = c3_bnz;
		else if( instr2 == 4'b1010 ) state2 = c1; // nop
		else if( instr2 == 4'b0001 ) state2 = stop;
		else state2 = 0;
	end
	
	always @(*)
	begin
		case(state2)
			c3_asn:
				begin
				if(IR2Out[7:6] == IR4Out[7:6]) R1MuxSel = 0;
				else R1MuxSel = 2;
				if(IR2Out[5:4] == IR4Out[7:6]) R2MuxSel = 0;
				else R2MuxSel = 2;
				end
			c3_shift: // R2 unused
				begin
				R2MuxSel = 2; // don't care
				if(IR2Out[7:6] == IR4Out[7:6]) R1MuxSel = 0;
				else R1MuxSel = 2;
				end
			c3_ori:
				begin
				if(IR2Out[7:6] == 1) R1MuxSel = 0;
				else R1MuxSel = 2;
				if(IR2Out[5:4] == 1) R2MuxSel = 0;
				else R2MuxSel = 2; // don't care
				end
			c3_load:
				begin
				R1MuxSel = 2; // don't care
				if(IR2Out[5:4] == IR4Out[7:6]) R2MuxSel = 1; // MDR Output
				else R2MuxSel = 2;
				end
			default:
				begin
				R1MuxSel = 2;
				R2MuxSel = 2;
				end
		endcase
	end
	
/*****************************************************************************
 *                         Combination Logic 2                              *
 *****************************************************************************/
					
	assign IRLoad = 1'b1;
	assign R1R2Load = 1'b1;
	
	always@(*)
	begin
		instr = IR2Out[3:0];
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
	
	always@(*)
	begin
		case(state)
			c3_ori: 
				begin
					R1Sel = 1'b1;
					FlagWrite = 1'b1;
				end
			c3_asn:
				begin
					R1Sel = 1'b0;
					FlagWrite = 1'b1;
				end
			c3_shift:
				begin
					R1Sel = 1'b0;
					FlagWrite = 1'b1;
				end
			c3_ori:
				begin
					R1Sel = 1'b0;
					FlagWrite = 1'b1;
				end
			default:
				begin
					R1Sel = 1'b0;
					FlagWrite = 1'b0;
				end
		endcase
	end

		
endmodule