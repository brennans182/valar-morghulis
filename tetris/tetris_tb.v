`timescale 1 ns / 1 ns

module tetris_tb;
	
reg Clk_tb;
reg Reset_tb;
reg Start_tb;
reg Ack_tb;
reg Left_tb;
reg Right_tb;
reg Down_tb;
wire [159:0] blocks_tb;

// Outputs
	wire q_I_tb;
	wire q_Gen_tb;
	wire q_Rot_tb;
	wire q_Col_tb;
	wire [7:0] score_tb;
	wire [1:0] orientation_tb;
	wire [7:0] location_tb;
// Instantiate the DUT

tetris dut ( 
	.Reset( Reset_tb),
	.Clk(Clk_tb),
	.Start(Start_tb), 
	.Ack(Ack_tb), 
	.Left(Left_tb),
	.Right(Right_tb),
	.Down(Down_tb),
	.q_I(q_I_tb),
	.q_Gen(q_Gen_tb),
	.q_Rot(q_Rot_tb),
	.q_Col(q_Col_tb),
	.blocks(blocks_tb),
	.score(score_tb),
	.orientation(orientation_tb),
	.location(location_tb)
	);
	
initial 
		begin: CLOCK_GENERATOR
		Clk_tb=0;
		forever
			begin
				#5 Clk_tb = ~ Clk_tb;
				
			end
		end
		
initial 
	begin
	Clk_tb = 0;
	Reset_tb = 0;
	Start_tb = 0;
	Ack_tb = 0;
	Left_tb = 0;
	Right_tb = 0;
	Down_tb = 0;
	
	@(posedge Clk_tb);
	@(posedge Clk_tb);
	#1;
		Reset_tb = 1;
	@(posedge Clk_tb);
	#1;
		Reset_tb = 0;
	@(posedge Clk_tb);
	#1;
		Start_tb = 1;
	@(posedge Clk_tb);
	#1;
		Start_tb = 0;
	@(posedge Clk_tb);
	#1;
	@(posedge Clk_tb);
	#1;
		Left_tb =1;
	@(posedge Clk_tb);
	#1;
	@(posedge Clk_tb);
	#1;
		Left_tb = 0;
		Right_tb = 1;
	@(posedge Clk_tb);
	
	@(posedge Clk_tb);
	@(posedge Clk_tb);
	#1;
		Right_tb = 0;
	end
	
endmodule