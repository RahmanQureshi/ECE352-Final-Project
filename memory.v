// Copyright (C) 1991-2015 Altera Corporation. All rights reserved.
// Your use of Altera Corporation's design tools, logic functions 
// and other software and tools, and its AMPP partner logic 
// functions, and any output files from any of the foregoing 
// (including device programming or simulation files), and any 
// associated documentation or information are expressly subject 
// to the terms and conditions of the Altera Program License 
// Subscription Agreement, the Altera Quartus II License Agreement,
// the Altera MegaCore Function License Agreement, or other 
// applicable license agreement, including, without limitation, 
// that your use is for the sole purpose of programming logic 
// devices manufactured by Altera and sold by Altera or its 
// authorized distributors.  Please refer to the applicable 
// agreement for further details.

// PROGRAM		"Quartus II 64-Bit"
// VERSION		"Version 15.0.0 Build 145 04/22/2015 SJ Full Version"
// CREATED		"Thu Nov 19 18:12:14 2015"

module memory(
	clock,
	MemRead,
	wren,
	address,
	address_pc,
	data,
	q,
	q_pc
);


input wire	clock;
input wire	MemRead;
input wire	wren;
input wire	[7:0] address;
input wire	[7:0] address_pc;
input wire	[7:0] data;
output wire	[7:0] q;
output wire	[7:0] q_pc;

wire	SYNTHESIZED_WIRE_0;
wire	[0:7] SYNTHESIZED_WIRE_1;
wire	[7:0] SYNTHESIZED_WIRE_2;

assign	SYNTHESIZED_WIRE_1 = 0;




DualMem	b2v_inst(
	.wren_a(wren),
	
	.clock(SYNTHESIZED_WIRE_0),
	.address_a(address),
	.address_b(address_pc),
	.data_a(data),
	
	.q_a(SYNTHESIZED_WIRE_2),
	.q_b(q_pc));

assign	SYNTHESIZED_WIRE_0 =  ~clock;


mux2to1_8bit	b2v_inst3(
	.sel(MemRead),
	.data0x(SYNTHESIZED_WIRE_1),
	.data1x(SYNTHESIZED_WIRE_2),
	.result(q));



endmodule
