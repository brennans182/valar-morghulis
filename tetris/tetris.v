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
//		COLLISION: The implementation of the full row clearing may cause problems in the top row. 
//
//
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 100 ps

module tetris( Reset, Clk, Start, Ack, Left, Right, Down, Rotate,
	q_I, q_Gen, q_Rot, q_Col, q_Lose, blocks, score
    );

input Reset, Clk;
input Start, Ack;	
input Left, Right, Down;
input Rotate;
	
output q_I, q_Gen;
output q_Rot, q_Col, q_Lose;


output reg [159:0] blocks;
output reg [31:0] score;
reg [7:0] state;

// Current Block Information
reg [7:0] location;
reg [7:0] i;
reg [2:0] block_type;
reg [1:0] orientation;

// Number of Loops for Rotate and Move
reg [24:0] loop;
reg [2:0] random_count;


// Check if space is avaliable for a rotate or move down Wire
// Square
wire square_l, square_r, square_d;
assign square_l = !blocks[location-2] && !blocks[location -10] && ((location-1)%8);
assign square_r = !blocks[location+1] && !blocks[location-7] && ((location+1)%8);
assign square_d = !blocks[location-16] && !blocks[location-17] && (location > 15) ;
//Bar
wire bar0_l, bar0_r, bar0_d, bar0_rot, bar1_l, bar1_r, bar1_d, bar1_rot;  // Two orientations  
assign bar0_l = !blocks[location-3] && ((location-2)%8);
assign bar0_r = !blocks[location+2] && ((location+2)%8);
assign bar0_d = !blocks[location-7] && !blocks[location-8] && !blocks[location-9] && !blocks[location-10] && location > 7; 
assign bar0_rot = (location/8 != 19) && !blocks[location+8] && !blocks[location-8] && !blocks[location-16] && (location >15);
assign bar1_l = !blocks[location-1] && !blocks[location-9] && !blocks[location-17] && !blocks[location+7] && location%8;
assign bar1_r = !blocks[location+1] && !blocks[location+9] && !blocks[location-7] && !blocks[location -15] && (location+1)%8;
assign bar1_d = !blocks[location-24] && (location > 23);
assign bar1_rot = !blocks[location +1] && !blocks[location-1] && !blocks[location-2] && (location+1)%8 && location%8;

//for Row clear condition
wire above_row, location_row, below_row, double_below_row;
assign above_row = blocks[(location/8 +1)*8] && blocks[(location/8+1)*8 + 1]
					&& blocks[(location/8+1)*8 + 2]&& blocks[(location/8+1)*8 + 3]
					&& blocks[(location/8+1)*8 + 4]&& blocks[(location/8+1)*8 + 5]
					&& blocks[(location/8+1)*8 + 6]&& blocks[(location/8+1)*8 + 7]; 
assign location_row = blocks[(location/8)*8] && blocks[(location/8)*8 + 1]
					&& blocks[(location/8)*8 + 2]&& blocks[(location/8)*8 + 3]
					&& blocks[(location/8)*8 + 4]&& blocks[(location/8)*8 + 5]
					&& blocks[(location/8)*8 + 6]&& blocks[(location/8)*8 + 7]; 
assign below_row = blocks[(location/8-1)*8] && blocks[(location/8-1)*8 + 1]
					&& blocks[(location/8-1)*8 + 2]&& blocks[(location/8-1)*8 + 3]
					&& blocks[(location/8-1)*8 + 4]&& blocks[(location/8-1)*8 + 5]
					&& blocks[(location/8-1)*8 + 6]&& blocks[(location/8-1)*8 + 7]; 
assign double_below_row = blocks[(location/8-2)*8] && blocks[(location/8-2)*8 + 1]
					&& blocks[(location/8-2)*8 + 2]&& blocks[(location/8-2)*8 + 3]
					&& blocks[(location/8-2)*8 + 4]&& blocks[(location/8-2)*8 + 5]
					&& blocks[(location/8-2)*8 + 6]&& blocks[(location/8-2)*8 + 7]; 


assign { q_Lose, q_Col, q_Rot, q_Gen, q_I} = state[4:0] ;
	

localparam
	INITIAL = 8'b0000_0001,
	GENERATE_PIECE = 8'b0000_0010,
	ROTATE_PIECE = 8'b0000_0100,
	COLLISION = 8'b0000_1000,
	LOSE = 8'b0001_0000;
	
//temp
localparam
	empty_row = 8'b0000_0000,
	full_row = 8'b1111_1111,
	loop_max = 25'b11111_11111_11111_11111_11111,
	bottom = 8'b1110_1101;

//pieces	
localparam
	SQUARE = 3'b000,
	BAR = 3'b001,
	S = 3'b010,
	Z = 3'b011,
	L = 3'b100,
	J = 3'b101,
	T = 3'b110;

	
always @ (posedge Clk )
	begin: RANDOM_NUMBER_GENERATOR
		if(random_count >= 0'b110)
			random_count <= 0;
		else
			random_count <= random_count+1;
	end
	
	
	
always @ (posedge Clk, posedge Reset)
	begin
		if(Reset)
			begin 
			state <= INITIAL;
			loop <= 0'b000;
			for(i=0; i<160; i = i+1)
				begin
				blocks[i] = 0;
				end
			score <= 0;
			location <= 0;
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
					
					loop <= 25'd0;
					for(i=0; i<160; i = i+1)
					begin
					blocks[i] = 0;
					end
					score <= 0;
					location <= 0;
					block_type <= SQUARE; 
					orientation <= 2'b00;
					
					end
				GENERATE_PIECE :
					begin
					if(block_type == SQUARE)
						begin
						if(blocks[154] || blocks[153] || blocks[146] || blocks[145]	)
							state <= LOSE;
						else
							state <= ROTATE_PIECE;
						end
					else if(block_type == BAR)
						begin
						if(blocks[152] || blocks[153] || blocks[154] || blocks[155])
							state <= LOSE;
						else 
							state <= ROTATE_PIECE;
						end
					
					
					//State Actions
					
					if(block_type == SQUARE)
						begin
						blocks [154] <= 1;
						blocks[153] <= 1;
						blocks[146]<= 1;
						blocks[145] <= 1;
						location <= 154;
						end
					else if( block_type == BAR)
						begin 
						blocks[152] <= 1;
						blocks[153] <= 1;
						blocks[154] <= 1;
						blocks[155] <= 1;
						location <= 154;
						end
					end
				ROTATE_PIECE :
					begin
					if( loop < loop_max)
						state <= ROTATE_PIECE;
					else if(loop == loop_max)
						state <= COLLISION;
						
					loop<= loop+1;
					
					if(block_type == SQUARE)
						begin					
						if(Left && square_l )
							begin
							blocks[location] <= 0;
							blocks[location-8] <= 0;
							blocks[location-10] <= 1;
							blocks[location -2] <= 1;
							location <= location -1;
							
							end
						else if( Right && square_r)
							begin
							blocks[location-1] <= 0;
							blocks[location-9] <=0;							
							blocks[location +1] <= 1;
							blocks[location - 7] <= 1;
							location <= location +1;
						 
							end
						else if( Down && square_d)
							begin
							blocks[location] <= 0;
							blocks[location-1] <= 0;							
							blocks[location-16] <= 1;
							blocks[location-17] <= 1;
							location <= location -8;
							loop<= 25'd0;
							end
						end
						
					if(block_type == BAR)
						begin
						if(Left && !orientation && bar0_l)
							begin
							blocks[location +1] <= 0;
							blocks[location -3] <= 1;
							location <= location -1;
							end							
						else if(Right && !orientation && bar0_r)
							begin
							blocks[location +2] <= 1;
							blocks[location -2] <= 0;
							end
						else if(Down && !orientation && bar0_d)
							begin
							blocks[location] <= 0;
							blocks[location+1] <= 0;
							blocks[location-1] <= 0;
							blocks[location-2] <= 0;
							blocks[location-7] <= 1;
							blocks[location-8] <= 1;
							blocks[location-9] <= 1;
							blocks[location-10] <= 1;
							location <= location -8;
							end
						else if(Rotate && !orientation && bar0_rot)
							begin
							blocks[location+8] <= 1;
							blocks[location-8] <= 1;
							blocks[location-16] <= 1;
							end
						else if(Left && orientation[0] && bar1_l)
							begin
							blocks[location +8] <= 0; 
							blocks[location] <= 0; 
							blocks[location -8] <= 0; 
							blocks[location -16] <= 0;
							blocks[location +7] <= 1; 
							blocks[location-1] <= 1; 
							blocks[location -9] <= 1; 
							blocks[location -17] <= 1;
							location <= location -1;
							end
						else if(Right && orientation[0] && bar1_r)
							begin
							blocks[location +8] <= 0; 
							blocks[location] <= 0; 
							blocks[location -8] <= 0; 
							blocks[location -16] <= 0;
							blocks[location +9] <= 1; 
							blocks[location+1] <= 1; 
							blocks[location -7] <= 1; 
							blocks[location -15] <= 1;
							location <= location -1;
							end
						else if(Down && orientation[0]  && bar1_d)
							begin
							blocks[location +8] <= 0;
							blocks[location -24] <= 1;
							end
						else if(Rotate && orientation[0] && bar1_rot)
							begin
							blocks[location+8] <= 0;
							blocks[location-8] <= 0;
							blocks[location-16] <= 0;
							blocks[location+1] <= 1;
							blocks[location-1] <= 1;
							blocks[location-2] <= 1;
							end
							
							
						end
					
					end
				COLLISION :
					begin
					if( (block_type == SQUARE && !square_d && (location_row + below_row) ==2 )   
						|| (block_type == BAR && !(orientation[0] ? bar1_d : bar0_d) && 
							(orientation[0] ? (above_row + location_row + below_row + double_below_row) >1 : location_row)))
						state <= COLLISION;
					else if( (block_type == SQUARE && !square_d)
							|| block_type == BAR && !(orientation[0] ? bar1_d : bar0_d))
						state <= GENERATE_PIECE;
					else 
						state <= ROTATE_PIECE;
					
					// Start of RTL
					if(block_type == SQUARE)
						begin
						if(square_d)
							begin
							blocks[location] <= 0;
							blocks[location-1] <= 0;							
							blocks[location-16] <= 1;
							blocks[location-17] <= 1;
							location <= location -8;
							loop<= 25'd0;
							end
						else 
							begin
							if( location_row)
							begin
							for(i = 0; i < 8'd150; i= i+1)
								begin
								if(i >= (location/8 *8))
									blocks[i] <= blocks[i+8] ;
								end
							blocks[159:150] <= empty_row;
							score <= score +1;
							end	
							if(below_row)
								begin
								for(i = 0; i < 8'd150; i= i+1)
									begin
									if(i >= ((location-8)/8 *8))
										blocks[i] <= blocks[i+8] ;
									end
								blocks[159:150] <= empty_row;
								score <= score +1;
								end
							end
						end
					else if(block_type == BAR)
						begin
						if( !orientation)
							begin
							if(bar0_d)
								begin
								blocks[location] <= 0;
								blocks[location+1] <= 0;
								blocks[location-1] <= 0;
								blocks[location-2] <= 0;
								blocks[location-7] <= 1;
								blocks[location-8] <= 1;
								blocks[location-9] <= 1;
								blocks[location-10] <= 1;
								location <= location -8;
								loop <= 25'd0;
								end
							else 
								begin
								if( location_row)
									begin
									for(i = 0; i < 8'd150; i= i+1)
										begin
										if(i >= (location/8 *8))
											blocks[i] <= blocks[i+8] ;
										end
									blocks[159:150] <= empty_row;
									score <= score +1;
									end									
								end
							end	
						else if(orientation[0])
							begin
							if(bar1_d)
								begin
								blocks[location+8] <= 0;
								blocks[location-24] <= 1;
								end
							else
								begin
								if( above_row)
									begin
									for(i = 0; i < 8'd150; i= i+1)
										begin
										if(i >= ((location+8)/8 *8))
											blocks[i] <= blocks[i+8] ;
										end
										blocks[159:150] <= empty_row;
										score <= score +1;
										end					
								if( location_row)
									begin
									for(i = 0; i < 8'd150; i= i+1)
										begin
										if(i >= (location/8 *8))
											blocks[i] <= blocks[i+8] ;
										end
									blocks[159:150] <= empty_row;
									score <= score +1;
									end					
								if( below_row)
									begin
									for(i = 0; i < 8'd150; i= i+1)
										begin
										if(i >= ((location-8)/8 *8))
											blocks[i] <= blocks[i+8] ;
										end
									blocks[159:150] <= empty_row;
									score <= score +1;
									end
								if( double_below_row)
									begin
									for(i = 0; i < 8'd150; i= i+1)
										begin
										if(i >= ((location-16)/8 *8))
											blocks[i] <= blocks[i+8] ;
										end
									blocks[159:150] <= empty_row;
									score <= score +1;
									end
								end					
							end
						end	// end of RTL
					end // end of the Collision State
				LOSE: 
					begin
					if(Ack)
						state<= INITIAL;
					else
						state<= LOSE;					
					end
				endcase
			end
	end
endmodule
