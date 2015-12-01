// ---------------------------------------------------------------------
// Copyright (c) 2007 by University of Toronto ECE 243 development team 
// ---------------------------------------------------------------------
//
// Major Functions:	a simple processor which operates basic mathematical
//					operations as follow:
//					(1)loading, (2)storing, (3)adding, (4)subtracting,
//					(5)shifting, (6)oring, (7)branch if zero,
//					(8)branch if not zero, (9)branch if positive zero
//					 
// Input(s):		1. KEY0(reset): clear all values from registers,
//									reset flags condition, and reset
//									control FSM
//					2. KEY1(clock): manual clock controls FSM and all
//									synchronous components at every
//									positive clock edge
//
//
// Output(s):		1. HEX Display: display registers value K3 to K1
//									in hexadecimal format
//
//					** For more details, please refer to the document
//					   provided with this implementation
//
// ---------------------------------------------------------------------

module multicycle
(
SW, KEY, HEX0, HEX1, HEX2, HEX3,
HEX4, HEX5, LEDR
);

// ------------------------ PORT declaration ------------------------ //
input	[1:0] KEY;
input [4:0] SW;
output	[6:0] HEX0, HEX1, HEX2, HEX3;
output	[6:0] HEX4, HEX5;
output reg [17:0] LEDR;

// ------------------------- Registers/Wires ------------------------ //
wire	clock, reset;
wire	MDRLoad, MemRead, MemWrite, PCWrite, RegIn, AddrSel;
wire	ALUOutWrite, FlagWrite, R1R2Load, R1Sel, RFWrite;
wire 	CounterEnable;
wire  IRLoad, IR2Load, IR3Load, IR4Load;
wire  [7:0]  IR2Out, IR3Out, IR4Out;
wire 	[15:0] COUNTERwire;
wire	[7:0] R2wire, PCwire, R1wire, RFout1wire, RFout2wire;
wire	[7:0] ALU1wire, ALU2wire, ALUwire, ALUOut, MDRwire, MEMwire;
wire 	[7:0] PCALUwire, PCinWire;
wire	[7:0] IR, SE4wire, ZE5wire, ZE3wire, AddrWire, RegWire, INSTRWire;
wire	[7:0] reg0, reg1, reg2, reg3;
wire	[7:0] constant;
wire	[2:0] ALUOp, ALU2;
wire	[1:0] R1_in;
wire	Nwire, Zwire;
wire 	PCSel;
wire regwSel;
wire [2:0] ALU1;
wire[1:0] regwIn;
reg		N, Z;
wire [7:0] PC2wire;
wire [7:0] PC3wire;
wire [7:0] PC4wire;
wire [7:0] R1MuxOut;
wire [7:0] R2MuxOut;
wire [2:0] R1MuxSel;
wire [2:0] R2MuxSel;
wire [7:0] mdr_alu_mux_out;
wire [7:0] MemAdrMuxOut;
wire MemAdrMuxSel;
wire [7:0] MemDataInMuxOut;
wire MemDataInMuxSel;
wire branching;

wire OutputSel;

// ------------------------ Input Assignment ------------------------ //
assign	clock = KEY[1];
assign	reset =  ~KEY[0]; // KEY is active high

// ------------------- DE2 compatible HEX display ------------------- //
HEXs	HEX_display(
	.in0(reg0),.in1(reg1),.in2(reg2),.in3(reg3),.inCounter(COUNTERwire),.selH(SW[0]),.selC(SW[2]),
	.out0(HEX0),.out1(HEX1),.out2(HEX2),.out3(HEX3),
	.out4(HEX4),.out5(HEX5)
);
// ----------------- END DE2 compatible HEX display ----------------- //

/*
// ------------------- DE1 compatible HEX display ------------------- //
chooseHEXs	HEX_display(
	.in0(reg0),.in1(reg1),.in2(reg2),.in3(reg3),
	.out0(HEX0),.out1(HEX1),.select(SW[1:0])
);
// turn other HEX display off
assign HEX2 = 7'b1111111;
assign HEX3 = 7'b1111111;
assign HEX4 = 7'b1111111;
assign HEX5 = 7'b1111111;
assign HEX6 = 7'b1111111;
assign HEX7 = 7'b1111111;
// ----------------- END DE1 compatible HEX display ----------------- //
*/

/*
FSM		Control(
	.reset(reset),.clock(clock),.N(N),.Z(Z),.instr(IR[3:0]),
	.PCwrite(PCWrite),.AddrSel(AddrSel),.MemRead(MemRead),.MemWrite(MemWrite),
	.IRload(IRLoad),.R1Sel(R1Sel),.MDRload(MDRLoad),.R1R2Load(R1R2Load),
	.ALU1(ALU1),.ALUOutWrite(ALUOutWrite),.RFWrite(RFWrite),.RegIn(RegIn),
	.FlagWrite(FlagWrite),.ALU2(ALU2),.ALUop(ALUOp),.CounterEnable(CounterEnable)
);
*/

FetchController FC
(
	.reset(reset),.clock(clock),.IR1Out(IR),.IR2Out(IR2Out),.IR3Out(IR3Out),.IR4Out(IR4Out),
	.PCSel(), .PCwrite(PCwrite), .IR1Enable(IRLoad), .AddrSel(AddrSel) 
);

DecodeController DC
(
	.reset(reset),.clock(clock),.IR1Out(IR),.IR2Out(IR2Out),.IR3Out(IR3Out),.IR4Out(IR4Out),
	.IR2Enable(IR2Load)
);

RFController RFC
(
	.reset(reset),.clock(clock),.IR1Out(IR),.IR2Out(IR2Out),.IR3Out(IR3Out),.IR4Out(IR4Out),.RFWrite(RFWrite),
	.IRLoad(IR3Load),.R1Sel(R1Sel),.R1R2Load(R1R2Load),.FlagWrite(),.R1MuxSel(R1MuxSel),.R2MuxSel(R2MuxSel)
);

ExecuteController	EC(
	.reset(reset),.clock(clock),.N(N),.Z(Z),.IR1Out(IR),.IR2Out(IR2Out),.IR3Out(IR3Out),.IR4Out(IR4Out),
	.PCwrite(),.AddrSel(),.MemRead(MemRead),.PCSel(PCSel),.MemWrite(MemWrite),
	.IRload(IR4Load),.R1Sel(),.MDRload(MDRLoad),.R1R2Load(),
	.ALU1(ALU1),.ALUOutWrite(ALUOutWrite),.RFWrite(RFWrite),.RegIn(),
	.FlagWrite(FlagWrite),.ALU2(ALU2),.ALUop(ALUOp),.CounterEnable(CounterEnable),.OutputSel(OutputSel),
	.MemAdrMuxSel(MemAdrMuxSel),.MemDataInMuxSel(MemDataInMuxSel)
);

WriteBackController WBC(
	.reset(reset),.clock(clock),.N(),.Z(),.IR1Out(IR),.IR2Out(IR2Out),.IR3Out(IR3Out),.IR4Out(IR4Out),
	.PCwrite(),.AddrSel(),.MemRead(),.PCSel(),.MemWrite(),
	.IRload(),.R1Sel(regwSel),.MDRload(),.R1R2Load(), //R1Sel = regwSel
	.ALU1(),.ALUOutWrite(),.RFWrite(RFWrite),.RegIn(RegIn),
	.FlagWrite(),.ALU2(),.ALUop(),.CounterEnable()
);

BranchingFSM BFSM (
	.clock(clock),.reset(reset),.PCSel(PCSel),.branching(branching)
);

counter ClockCounter (
	.enable(CounterEnable),.reset(reset),.clock(clock),.q(COUNTERwire)
);

memory	DataMem(
	.MemRead(MemRead),.wren(MemWrite),.clock(clock),
	.address(MemAdrMuxOut),.address_pc(PCwire),.data(MemDataInMuxOut),.q(MEMwire),.q_pc(INSTRWire)
);

ALU		ALU(
	.in1(ALU1wire),.in2(ALU2wire),.out(ALUwire),
	.ALUOp(ALUOp),.N(Nwire),.Z(Zwire)
);

ALU 	PCALU(
	.in1(8'b00000001),.in2(PCwire),.out(PCALUwire),
	.ALUOp(3'b000),.N(),.Z()
);

wire [7:0] BRANCHALUOut;

ALU		BRANCHALU(
	.in1(8'b00000001),.in2(ALUwire),.out(BRANCHALUOut),
	.ALUOp(3'b000),.N(),.Z()
);


RF		RF_block(
	.clock(clock),.reset(reset),.RFWrite(RFWrite),
	.dataw(RegWire),.reg1(R1_in),.reg2(IR2Out[5:4]),
	.regw(regwIn),.data1(RFout1wire),.data2(RFout2wire),
	.r0(reg0),.r1(reg1),.r2(reg2),.r3(reg3)
);

register_8bit	IR_reg( /* Fetch IR */
	.clock(clock),.aclr(reset),.enable(IRLoad),
	.data(INSTRWire), .q(IR)
);

register_8bit	IR2( /* DECODE IR */
	.clock(clock),.aclr(reset),.enable(IR2Load),
	.data(IR),.q(IR2Out)
);

register_8bit	IR3( /* RF IR */
	.clock(clock),.aclr(reset),.enable(IR3Load),
	.data(IR2Out),.q(IR3Out)
);

register_8bit	IR4( /* Execute IR */
	.clock(clock),.aclr(reset),.enable(IR4Load),
	.data(IR3Out),.q(IR4Out)
);

register_8bit	MDR_reg(
	.clock(clock),.aclr(reset),.enable(MDRLoad),
	.data(MEMwire),.q(MDRwire)
);

register_8bit	PC(
	.clock(clock),.aclr(reset),.enable(PCwrite),
	.data(PCinWire),.q(PCwire)
);

register_8bit	PC2(
	.clock(clock),.aclr(reset),.enable(PCwrite),
	.data(PCwire),.q(PC2wire)
);

register_8bit	PC3(
	.clock(clock),.aclr(reset),.enable(PCwrite),
	.data(PC2wire),.q(PC3wire)
);

register_8bit	PC4(
	.clock(clock),.aclr(reset),.enable(PCwrite),
	.data(PC3wire),.q(PC4wire)
);

mux5to1_8bit 		R1Mux(
	.data0x(ALUOut),.data1x(MDRwire),.data2x(RFout1wire),
	.data3x(),.data4x(),.sel(R1MuxSel),.result(R1MuxOut)
);

mux5to1_8bit 		R2Mux(
	.data0x(ALUOut),.data1x(MDRwire),.data2x(RFout2wire),
	.data3x(),.data4x(),.sel(R2MuxSel),.result(R2MuxOut)
);

register_8bit	R1(
	.clock(clock),.aclr(reset),.enable(R1R2Load),
	.data(R1MuxOut),.q(R1wire)
);

register_8bit	R2(
	.clock(clock),.aclr(reset),.enable(R1R2Load),
	.data(R2MuxOut),.q(R2wire)
);

register_8bit	ALUOut_reg(
	.clock(clock),.aclr(reset),.enable(ALUOutWrite),
	.data(ALUwire),.q(ALUOut)
);

mux2to1_8bit		mdr_alu_mux(
	.data0x(ALUwire),.data1x(MEMwire),
	.sel(OutputSel),.result(mdr_alu_mux_out)
);

mux2to1_2bit		R1Sel_mux(
	.data0x(IR2Out[7:6]),.data1x(constant[1:0]),
	.sel(R1Sel),.result(R1_in)
);

mux2to1_2bit		regwSel_mux(
	.data0x(IR4Out[7:6]),.data1x(constant[1:0]),
	.sel(regwSel),.result(regwIn)
);

mux2to1_8bit 		AddrSel_mux(
	.data0x(R2wire),.data1x(PCwire),
	.sel(AddrSel),.result(AddrWire)
);

mux2to1_8bit 		RegMux(
	.data0x(ALUOut),.data1x(MDRwire),
	.sel(RegIn),.result(RegWire)
);

mux2to1_8bit 		MemDataInMux(
	.data0x(R1wire),.data1x(ALUOut),
	.sel(MemDataInMuxSel),.result(MemDataInMuxOut)
);

mux2to1_8bit 		MemAdrMux(
	.data0x(R2wire),.data1x(ALUOut),
	.sel(MemAdrMuxSel),.result(MemAdrMuxOut)
);

mux2to1_8bit 		PC_mux(
	.data0x(BRANCHALUOut),.data1x(PCALUwire),
	.sel(PCSel),.result(PCinWire)
);

mux5to1_8bit 		ALU1_mux(
	.data0x(ALUOut),.data1x(PC4wire),.data2x(R1wire),
	.data3x(),.data4x(MDRwire),.sel(ALU1),.result(ALU1wire)
);

mux5to1_8bit ALU2_mux(
	.data0x(R2wire),.data1x(ALUOut),.data2x(SE4wire),
	.data3x(ZE5wire),.data4x(ZE3wire),.sel(ALU2),.result(ALU2wire)
);


sExtend		SE4(.in(IR3Out[7:4]),.out(SE4wire));
zExtend		ZE3(.in(IR3Out[5:3]),.out(ZE3wire));
zExtend		ZE5(.in(IR3Out[7:3]),.out(ZE5wire));
// define parameter for the data size to be extended
defparam	SE4.n = 4;
defparam	ZE3.n = 3;
defparam	ZE5.n = 5;

always@(posedge clock or posedge reset)
begin
if (reset)
	begin
	N <= 0;
	Z <= 0;
	end
else
if (FlagWrite)
	begin
	N <= Nwire;
	Z <= Zwire;
	end
end

// ------------------------ Assign Constant 1 ----------------------- //
assign	constant = 1;

// ------------------------- LEDs Indicator ------------------------- //
always @ (*)
begin

    case({SW[4],SW[3]})
    2'b00:
    begin
      LEDR[9] = 0;
      LEDR[8] = 0;
      LEDR[7] = PCWrite;
      LEDR[6] = AddrSel;
      LEDR[5] = MemRead;
      LEDR[4] = MemWrite;
      LEDR[3] = IRLoad;
      LEDR[2] = R1Sel;
      LEDR[1] = MDRLoad;
      LEDR[0] = R1R2Load;
    end

    2'b01:
    begin
      LEDR[9] = ALU1;
      LEDR[8:6] = ALU2[2:0];
      LEDR[5:3] = ALUOp[2:0];
      LEDR[2] = ALUOutWrite;
      LEDR[1] = RFWrite;
      LEDR[0] = RegIn;
    end

    2'b10:
    begin
      LEDR[9] = 0;
      LEDR[8] = 0;
      LEDR[7] = FlagWrite;
      LEDR[6:2] = constant[7:3];
      LEDR[1] = N;
      LEDR[0] = Z;
    end

    2'b11:
    begin
      LEDR[9:0] = 10'b0;
    end
  endcase
end
endmodule
