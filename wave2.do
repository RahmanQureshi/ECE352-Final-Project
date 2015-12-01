onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /multicycle_tb/reset
add wave -noupdate /multicycle_tb/clock
add wave -noupdate -divider {Hex Display}
add wave -noupdate -radix hexadecimal /multicycle_tb/DUT/HEX_display/in0
add wave -noupdate -radix hexadecimal /multicycle_tb/DUT/HEX_display/in1
add wave -noupdate -radix hexadecimal /multicycle_tb/DUT/HEX_display/in2
add wave -noupdate -radix hexadecimal /multicycle_tb/DUT/HEX_display/in3
add wave -noupdate -radix hexadecimal /multicycle_tb/DUT/ClockCounter/q
add wave -noupdate -radix hexadecimal /multicycle_tb/DUT/PC/q
add wave -noupdate -radix hexadecimal /multicycle_tb/DUT/PC2/q
add wave -noupdate -radix hexadecimal /multicycle_tb/DUT/PC3/q
add wave -noupdate -radix hexadecimal /multicycle_tb/DUT/PC4/q
add wave -noupdate -radix hexadecimal /multicycle_tb/DUT/IR_reg/q
add wave -noupdate -radix hexadecimal /multicycle_tb/DUT/IR2/q
add wave -noupdate -radix hexadecimal /multicycle_tb/DUT/IR3/q
add wave -noupdate -radix hexadecimal /multicycle_tb/DUT/IR4/q
add wave -noupdate -radix hexadecimal /multicycle_tb/DUT/ALU/in1
add wave -noupdate -radix hexadecimal /multicycle_tb/DUT/ALU/in2
add wave -noupdate -radix hexadecimal /multicycle_tb/DUT/ALU/out 
add wave -noupdate -radix hexadecimal /multicycle_tb/DUT/ALUOut_reg/q
add wave -noupdate -radix hexadecimal /multicycle_tb/DUT/R1Mux/sel 
add wave -noupdate -radix hexadecimal /multicycle_tb/DUT/R1/q
add wave -noupdate -radix hexadecimal /multicycle_tb/DUT/R2Mux/sel
add wave -noupdate -radix hexadecimal /multicycle_tb/DUT/R2/q 
add wave -noupdate -radix hexadecimal /multicycle_tb/DUT/MDR_reg/q
add wave -noupdate -radix hexadecimal /multicycle_tb/DUT/ALU1_mux/sel
add wave -noupdate -radix hexadecimal /multicycle_tb/DUT/ALU/in1
add wave -noupdate -radix hexadecimal /multicycle_tb/DUT/ALU2_mux/sel  
add wave -noupdate -radix hexadecimal /multicycle_tb/DUT/ALU/in2
add wave -noupdate -radix hexadecimal /multicycle_tb/DUT/ALU/ALUOp
add wave -noupdate -radix hexadecimal /multicycle_tb/DUT/ALU/out 
add wave -noupdate -radix hexadecimal /multicycle_tb/DUT/N
add wave -noupdate -radix hexadecimal /multicycle_tb/DUT/Z


add wave -noupdate -divider {multicycle.v inputs}
add wave -noupdate /multicycle_tb/KEY
add wave -noupdate /multicycle_tb/SW
add wave -noupdate -divider {multicycle.v outputs}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {2500 ns} 0}
configure wave -namecolwidth 227
configure wave -valuecolwidth 57
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1000
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {2500 ns}
