module WriteBackController
(
reset, IR1Out, IR2Out, IR3Out, IR4Out, clock,
N, Z,
PCwrite, AddrSel, MemRead, PCSel,
MemWrite, IRload, R1Sel, MDRload,
R1R2Load, ALU1, ALU2, ALUop,
ALUOutWrite, RFWrite, RegIn, FlagWrite, CounterEnable
);


	input	N, Z;
	input	reset, clock;
	input [7:0] IR1Out, IR2Out, IR3Out, IR4Out;
	output	PCSel, PCwrite, AddrSel, MemRead, MemWrite, IRload, R1Sel, MDRload;
	output	R1R2Load, ALU1, ALUOutWrite, RFWrite, RegIn, FlagWrite;
	output  CounterEnable;
	output	[2:0] ALU2, ALUop;
	//output	[3:0] state;
	
	reg PCSel;
	reg [3:0]	state;
	reg	PCwrite, AddrSel, MemRead, MemWrite, IRload, R1Sel, MDRload, CounterEnable;
	reg	R1R2Load, ALU1, ALUOutWrite, RFWrite, RegIn, FlagWrite;
	reg	[2:0] ALU2, ALUop;
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

always@(*)
	begin
		case(state)
			c3_ori: 	//control = 19'b0000010000000000100;
				begin
					PCSel = 1;
					PCwrite = 0;
					AddrSel = 0;
					MemRead = 0;
					MemWrite = 0;
					IRload = 1;
					R1Sel = 1;
					MDRload = 0;
					R1R2Load = 0;
					ALU1 = 0;
					ALU2 = 3'b000;
					ALUop = 3'b000;
					ALUOutWrite = 0;
					RFWrite = 1;
					RegIn = 0;
					FlagWrite = 0;
					CounterEnable = 1;
				end
			c3_asn: 	//control = 19'b0000000000000000100;
				begin
					PCSel = 1;
					PCwrite = 0;
					AddrSel = 0;
					MemRead = 0;
					MemWrite = 0;
					IRload = 1;
					R1Sel = 0;
					MDRload = 0;
					R1R2Load = 0;
					ALU1 = 0;
					ALU2 = 3'b000;
					ALUop = 3'b000;
					ALUOutWrite = 0;
					RFWrite = 1;
					RegIn = 0;
					FlagWrite = 0;
					CounterEnable = 1;
				end
			c3_load: 	//control = 19'b0000000000000001110;
				begin
					PCSel = 1;
					PCwrite = 0;
					AddrSel = 0;
					MemRead = 0;
					MemWrite = 0;
					IRload = 1;
					R1Sel = 0;
					MDRload = 0;
					R1R2Load = 0;
					ALU1 = 0;
					ALU2 = 3'b000;
					ALUop = 3'b000;
					ALUOutWrite = 1;
					RFWrite = 1;
					RegIn = 1;
					FlagWrite = 0;
					CounterEnable = 1;
				end
			c3_shift: 	//control = 19'b0000000000000000100;
				begin
					PCSel = 1;
					PCwrite = 0;
					AddrSel = 0;
					MemRead = 0;
					MemWrite = 0;
					IRload = 0;
					R1Sel = 0;
					MDRload = 0;
					R1R2Load = 0;
					ALU1 = 0;
					ALU2 = 3'b000;
					ALUop = 3'b000;
					ALUOutWrite = 0;
					RFWrite = 1;
					RegIn = 0;
					FlagWrite = 0;
					CounterEnable = 1;
				end
			c3_bpz: 	//control = {~N,18'b000000000100000000};
				begin
					PCSel = N;
					PCwrite = ~N;
					AddrSel = 0;
					MemRead = 0;
					MemWrite = 0;
					IRload = 1;
					R1Sel = 0;
					MDRload = 0;
					R1R2Load = 0;
					ALU1 = 0;
					ALU2 = 3'b010;
					ALUop = 3'b000;
					ALUOutWrite = 0;
					RFWrite = 0;
					RegIn = 0;
					FlagWrite = 0;
					CounterEnable = 1;
				end
			c3_bz: 		//control = {Z,18'b000000000100000000};
				begin
					PCSel = ~Z; 
					PCwrite = Z;
					AddrSel = 0;
					MemRead = 0;
					MemWrite = 0;
					IRload = 1;
					R1Sel = 0;
					MDRload = 0;
					R1R2Load = 0;
					ALU1 = 0;
					ALU2 = 3'b010;
					ALUop = 3'b000;
					ALUOutWrite = 0;
					RFWrite = 0;
					RegIn = 0;
					FlagWrite = 0;
					CounterEnable = 1;
				end
			c3_bnz: 	//control = {~Z,18'b000000000100000000};
				begin
					PCSel = Z;
					PCwrite = ~Z;
					AddrSel = 0;
					MemRead = 0;
					MemWrite = 0;
					IRload = 1;
					R1Sel = 0;
					MDRload = 0;
					R1R2Load = 0;
					ALU1 = 0;
					ALU2 = 3'b010;
					ALUop = 3'b000;
					ALUOutWrite = 0;
					RFWrite = 0;
					RegIn = 0;
					FlagWrite = 0;
					CounterEnable = 1;
				end
			default:	//control = 19'b0000000000000000000;
				begin
					PCSel = 1;
					PCwrite = 0;
					AddrSel = 0;
					MemRead = 0;
					MemWrite = 0;
					IRload = 1;
					R1Sel = 0;
					MDRload = 0;
					R1R2Load = 0;
					ALU1 = 0;
					ALU2 = 3'b000;
					ALUop = 3'b000;
					ALUOutWrite = 0;
					RFWrite = 0;
					RegIn = 0;
					FlagWrite = 0;
					CounterEnable = 1;
				end
		endcase
	end
	
endmodule