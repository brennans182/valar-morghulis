`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:33:35 12/02/2013 
// Design Name: 
// Module Name:    tetris 
// Project Name:  EE201 Final Project 
// Target Devices: Diligent Spartan-6
// Tool versions: 
// Description: 
//
// Dependencies: Food
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 100 ps

module tetris( Reset, Clk, Start, Ack, Left, Right, q_I, q_Gen, q_Rot, blocks
    );

input Reset, Clk;
input Start, Ack;	
input Left, Right;
	
output q_I, q_Gen;
output q_Rot;


output reg [199:0] blocks;
reg [7:0] state;

// Current Block Location
reg [7:0] location;
reg [7:0] i;


assign { q_Rot, q_Gen, q_I} = state[2:0] ;
	

localparam
	INITIAL = 8'b0000_0001,
	GENERATE_PIECE = 8'b0000_0010,
	ROTATE_PIECE = 8'b0000_0100,
	MOVE_PIECE = 8'b0000_1000,
	COLLISION = 8'b0001_0000;
	
	
always @ (posedge Clk, posedge Reset)
	begin
		if(Reset)
			begin 
			state <= INITIAL;
			for(i=0; i<200; i = i+1)
				begin
				blocks[i] = 0;
				end
			state <= INITIAL;
			end
		else
			begin
			case(state)
				INITIAL : 
					begin
					if(Start)
						state <= GENERATE_PIECE;
					else
						state <= INITIAL;
					end
				GENERATE_PIECE :
					begin
					state <= ROTATE_PIECE;
					
					//State Actions
					blocks [194] <= 1;
					location <= 194;
					
					end
				ROTATE_PIECE :
					begin
					state <= ROTATE_PIECE;
					
					if(Left && (location%10) )
						begin
						blocks[location] <= 0;
						blocks[location -1] <= 1;
						location <= location -1;
						end
					else if( Right && ((location+1)%10 ))
						begin
						blocks[location] <= 0;
						blocks[location +1] <= 1;
						location <= location +1;
						end
					end		
				endcase
			end
	end
endmodule
