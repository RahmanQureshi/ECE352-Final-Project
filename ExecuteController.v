module ExecuteController
(
reset, IR1Out, IR2Out, IR3Out, IR4Out, clock,
N, Z, RFWrite, branching,
PCwrite, AddrSel, MemRead, PCSel,
MemWrite, IRload, R1Sel, MDRload,
R1R2Load, ALU1, ALU2, ALUop,
ALUOutWrite, RegIn, FlagWrite, CounterEnable, OutputSel, 
MemAdrMuxSel, MemDataInMuxSel
);

	input	N, Z;
	input	reset, clock;
	input RFWrite, branching;
	input [7:0] IR1Out, IR2Out, IR3Out, IR4Out;
	output	PCSel, PCwrite, AddrSel, MemRead, MemWrite, IRload, R1Sel, MDRload;
	output	R1R2Load, ALUOutWrite, RegIn, FlagWrite;
	output  CounterEnable;
	output	[2:0] ALU1, ALU2, ALUop;
	output reg OutputSel, MemAdrMuxSel, MemDataInMuxSel;
	//output	[3:0] state;
	
	reg 	PCSel;
	reg	PCwrite, AddrSel, MemRead, MemWrite, IRload, R1Sel, MDRload, CounterEnable;
	reg	R1R2Load, ALUOutWrite, RegIn, FlagWrite;
	reg	[2:0] ALU1, ALU2, ALUop;
	reg [3:0] state;
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
 *                         Combination Logic  - Data Hazard                  *
 *****************************************************************************/	
		
	always @(*)
	begin
		case(state)
			c3_asn:
				begin
				MemAdrMuxSel = 0;
				MemDataInMuxSel = 0;
				if(state2==c3_ori) // For ori, upper two bits are not the register being written
					begin
					if(IR3Out[7:6]==1 && RFWrite==1 && branching==0) ALU1 = 0;
					else ALU1 = 2;
					if(IR3Out[5:4]==1 && RFWrite==1 && branching==0) ALU2 = 1;
					else ALU2 = 0;
					end
				else
					begin
					if(IR4Out[7:6]==IR3Out[7:6] && RFWrite==1 && branching==0) ALU1 = 0;
					else ALU1 = 2;
					if(IR4Out[7:6]==IR3Out[5:4] && RFWrite==1 && branching==0) ALU2 = 3'b001;
					else ALU2 = 3'b000;
					end
				end
			c3_shift:
				begin
				MemAdrMuxSel = 0;
				MemDataInMuxSel = 0;
				ALU2 = 4; // IMM3
				if(state2==c3_ori)
					begin
					if(IR3Out[7:6]==1 && RFWrite==1 && branching==0) ALU1 = 0;
					else ALU1 = 2;
					end
				else
					if(IR4Out[7:6]==IR3Out[7:6] && RFWrite==1 && branching==0) ALU1 = 0;
					else ALU1 = 2;
				end
			c3_ori:
				begin
				MemAdrMuxSel = 0;
				MemDataInMuxSel = 0;
				ALU2 = 3; // imm5
				if(IR4Out[7:6]==1 && RFWrite==1 && branching==0) ALU1 = 0;
				else ALU1 = 2;
				end
			c3_load:
				begin
				MemDataInMuxSel = 0;
				ALU1 = 2; // don't care
				ALU2 = 3'b000; // don't care
				if(state2==c3_ori) // For ori, upper two bits are not the register being written
					begin
					if(IR3Out[5:4]==1 && RFWrite==1 && branching==0) MemAdrMuxSel = 1;
					else MemAdrMuxSel = 0;
					end
				else
					if(IR4Out[7:6]==IR3Out[5:4] && RFWrite==1 && branching==0) MemAdrMuxSel = 1;
					else MemAdrMuxSel = 0;
				end
			c3_bpz:
				begin
				MemDataInMuxSel = 0;
				MemAdrMuxSel = 0;
				ALU1 = 1; // PC4 wire
				ALU2 = 2; // IMM4
				end
			c3_bz:
				begin
				MemDataInMuxSel = 0;
				MemAdrMuxSel = 0;
				ALU1 = 1; // PC4 wire
				ALU2 = 2; // IMM4
				end
			c3_bnz:
				begin
				MemDataInMuxSel = 0;
				MemAdrMuxSel = 0;
				ALU1 = 1; // PC4 wire
				ALU2 = 2; // IMM4
				end
			c3_store:
				begin
				ALU1 = 2; // don't care
				ALU2 = 0; // don't care
				
				if(state2==c3_ori) // For ori, upper two bits are not the register being written
					begin
					if(IR3Out[7:6]==1 && RFWrite==1 && branching==0) MemDataInMuxSel = 1;
					else MemDataInMuxSel = 0;
					if(IR3Out[5:4]==1 && RFWrite==1 && branching==0) MemAdrMuxSel = 1;
					else MemAdrMuxSel = 0;
					end
				else
					begin
					if(IR4Out[7:6] == IR3Out[7:6] && RFWrite==1 && branching==0) MemDataInMuxSel = 1;
					else MemDataInMuxSel = 0;
					if(IR4Out[7:6] == IR3Out[5:4] && RFWrite==1 && branching==0) MemAdrMuxSel = 1;
					else MemAdrMuxSel = 0;
					end
				end
			default:
				begin
				MemDataInMuxSel = 0;
				MemAdrMuxSel = 0;
				ALU1 = 2;
				ALU2 = 3'b000;
				end
		endcase
	end

/*****************************************************************************
 *                         Combination Logic                                 *
 *****************************************************************************/				

	always@(*)
	begin
		instr = IR3Out[3:0];
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
	
	always@(*)
	begin	
		case(state)
			c3_asn:		begin
							if ( instr == 4'b0100 ) 		// add
								//control = 19'b0000000010000001001;
							begin
								OutputSel = 0;
								PCSel = 1;
								PCwrite = 0;
								AddrSel = 0;
								MemRead = 0;
								MemWrite = 0;
								IRload = 1;
								R1Sel = 0;
								MDRload = 0;
								R1R2Load = 0;
								ALUop = 3'b000;
								ALUOutWrite = 1;
								RegIn = 0;
								FlagWrite = 1;
								CounterEnable = 1;
							end	
							else if ( instr == 4'b0110 ) 	// sub
								//control = 19'b0000000010000011001;
							begin
								OutputSel = 0;
								PCSel = 1;
								PCwrite = 0;
								AddrSel = 0;
								MemRead = 0;
								MemWrite = 0;
								IRload = 1;
								R1Sel = 0;
								MDRload = 0;
								R1R2Load = 0;
								ALUop = 3'b001;
								ALUOutWrite = 1;
								RegIn = 0;
								FlagWrite = 1;
								CounterEnable = 1;
							end
							else 							// nand
								//control = 19'b0000000010000111001;
							begin
								OutputSel = 0;
								PCSel = 1;
								PCwrite = 0;
								AddrSel = 0;
								MemRead = 0;
								MemWrite = 0;
								IRload = 1;
								R1Sel = 0;
								MDRload = 0;
								R1R2Load = 0;
								ALUop = 3'b011;
								ALUOutWrite = 1;
								RegIn = 0;
								FlagWrite = 1;
								CounterEnable = 1;
							end
				   		end
			c3_shift: 	//control = 19'b0000000011001001001;
				begin
					OutputSel = 0;
					PCSel = 1;
					PCwrite = 0;
					AddrSel = 0;
					MemRead = 0;
					MemWrite = 0;
					IRload = 1;
					R1Sel = 0;
					MDRload = 0;
					R1R2Load = 0;
					ALUop = 3'b100;
					ALUOutWrite = 1;
					RegIn = 0;
					FlagWrite = 1;
					CounterEnable = 1;
				end
			c3_ori: 	//control = 19'b0000010100000000000;
				begin
					OutputSel = 0;
					PCSel = 1;
					PCwrite = 0;
					AddrSel = 0;
					MemRead = 0;
					MemWrite = 0;
					IRload = 1;
					R1Sel = 0;
					MDRload = 0;
					R1R2Load = 0;
					ALUop = 3'b010;
					ALUOutWrite = 1;
					RegIn = 0;
					FlagWrite = 1;
					CounterEnable = 1;
				end
			c3_load: 	//control = 19'b0010001000000000000;
				begin
					OutputSel = 1;
					PCSel = 1;
					PCwrite = 0;
					AddrSel = 0;
					MemRead = 1;
					MemWrite = 0;
					IRload = 1;
					R1Sel = 0;
					MDRload = 1;
					R1R2Load = 0;
					ALUop = 3'b000;
					ALUOutWrite = 0;
					RegIn = 0;
					FlagWrite = 0;
					CounterEnable = 1;
				end
			c3_store: 	//control = 19'b0001000000000000000;
				begin
					OutputSel = 0; // don't care?
					PCSel = 1;
					PCwrite = 0;
					AddrSel = 0;
					MemRead = 0;
					MemWrite = 1;
					IRload = 1;
					R1Sel = 0;
					MDRload = 0;
					R1R2Load = 0;
					ALUop = 3'b000;
					ALUOutWrite = 0;
					RegIn = 0;
					FlagWrite = 0;
					CounterEnable = 1;
				end
			c3_bpz: 	//control = {~N,18'b000000000100000000};
				begin	
					OutputSel = 0; // don't care?
					PCSel = N;
					PCwrite = ~N;
					AddrSel = 0;
					MemRead = 0;
					MemWrite = 0;
					IRload = 1;
					R1Sel = 0;
					MDRload = 0;
					R1R2Load = 0;
					ALUop = 3'b000;
					ALUOutWrite = 0;
					RegIn = 0;
					FlagWrite = 0;
					CounterEnable = 1;
				end
			c3_bz: 		//control = {Z,18'b000000000100000000};
				begin
					OutputSel = 0; // don't care?
					PCSel = ~Z;
					PCwrite = Z;
					AddrSel = 0;
					MemRead = 0;
					MemWrite = 0;
					IRload = 1;
					R1Sel = 0;
					MDRload = 0;
					R1R2Load = 0;
					ALUop = 3'b000;
					ALUOutWrite = 0;
					RegIn = 0;
					FlagWrite = 0;
					CounterEnable = 1;
				end
			c3_bnz: 	//control = {~Z,18'b000000000100000000};
				begin
					OutputSel = 0; // don't care?
					PCSel = Z;
					PCwrite = ~Z;
					AddrSel = 0;
					MemRead = 0;
					MemWrite = 0;
					IRload = 1;
					R1Sel = 0;
					MDRload = 0;
					R1R2Load = 0;
					ALUop = 3'b000;
					ALUOutWrite = 0;
					RegIn = 0;
					FlagWrite = 0;
					CounterEnable = 1;
				end
			stop:
				begin
					OutputSel = 0; // don't care?
					PCSel = 1;
					PCwrite = 0;
					AddrSel = 0;
					MemRead = 0;
					MemWrite = 0;
					IRload = 1;
					R1Sel = 0;
					MDRload = 0;
					R1R2Load = 0;
					ALUop = 3'b000;
					ALUOutWrite = 0;
					RegIn = 0;
					FlagWrite = 0;
					CounterEnable = 0;
				end
			default:	//control = 19'b0000000000000000000;
				begin
					OutputSel = 0; // don't care?
					PCSel = 1;
					PCwrite = 0;
					AddrSel = 0;
					MemRead = 0;
					MemWrite = 0;
					IRload = 1;
					R1Sel = 0;
					MDRload = 0;
					R1R2Load = 0;
					ALUop = 3'b000;
					ALUOutWrite = 0;
					RegIn = 0;
					FlagWrite = 0;
					CounterEnable = 1;
				end
		endcase
	end


endmodule