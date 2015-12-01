// ---------------------------------------------------------------------
// Copyright (c) 2007 by University of Toronto ECE 243 development team 
// ---------------------------------------------------------------------
//
// Major Functions:	control processor's datapath
// 
// Input(s):	1. enable: stops incrementing counter when this bit becomes a 1.
//						   The counter cannot be started again until reset.
//
// ---------------------------------------------------------------------
module counter
(
	enable, reset, clock, q
);

	input enable;
	input clock;
	input reset;
	output [15:0] q;

	parameter counting = 0, stopped = 1;
	reg [15:0] mem;
	reg state;

/*****************************************************************************
 *                         Finite State Machine(s)                           *
 *****************************************************************************/

	always @(posedge clock)
	begin
		if (reset==1)
		begin
			state = counting;
		end
		else
		begin
			case(state)
			counting:
				if (enable==0)
					state = stopped;
				else
					state = counting;
			stopped:
				state = stopped;
			endcase
		end
	end

/*****************************************************************************
 *                         Sequential Logic                                  *
 *****************************************************************************/

	always @(posedge clock)
	begin
		if (reset==1)
			mem = 0;
		else
		begin
			if (state==counting)
				mem = mem+1;
			else if(state==stopped)
				mem = mem;
		end
	end

	assign q = mem;

endmodule