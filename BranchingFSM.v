module BranchingFSM(clock, reset, PCSel, branching);

input clock;
input PCSel;
input reset;
output branching;
reg branching;
/*****************************************************************************
 *                         Parameter Declarations                            *
 *****************************************************************************/

	parameter counting = 0, not_counting= 1;
	
/*****************************************************************************
 *                                  FSM                                      *
 *****************************************************************************/
 
reg state;
reg [1:0] counter;

always@(posedge clock)
	begin
		if(reset==1)
			begin
			state = not_counting;
			end
		else
			case(state)
				counting:
					begin
						if(counter==4) state = not_counting; // branch + 3 instruction
						else state = counting;
					end
				not_counting:
					begin
						if(PCSel==0) state = counting;
						else state = not_counting;
					end
			endcase
	end
				
/*****************************************************************************
 *                           Sequential Logic                               *
 *****************************************************************************/
				
always@(posedge clock)
	begin
	case(state)
		counting:
			counter = counter+1;
		not_counting:
			counter = 0;
	endcase
	end
				
/*****************************************************************************
 *                         Combination Logic                                 *
 *****************************************************************************/
 always@(*)
	begin
	if(state==counting) branching = 1;
	else branching = 0;
	end
 
endmodule
