module top_module(
input clk, reset, pause, 
input [1:0] state,	
input [5:0] start_num, 
input fDown, fClock, 
output [6:0] hex0, hex1, hex2, hex3, hex4, hex5
);	


//display
wire [18:0] cout;
wire [18:0] ss;																	
wire [18:0] mm;																	
wire [18:0] hh;
wire [3:0] ss0;
wire [3:0] ss1;
wire [3:0] mm0;
wire [3:0] mm1;
wire [3:0] hh0;
wire [3:0] hh1;
wire flash_hh;
wire flash_mm;
wire flash_ss;

//clock.v
wire [16:0] cout_clock;
wire [16:0] reset_clock;
wire [16:0] pause_clock;
wire [16:0] init_time_clock;

//select.v
wire [16:0] cout_select;
wire [5:0] start_num_select;
wire [16:0] reset_select;
wire [16:0] pause_select;
wire flash_hh_sig_select;
wire flash_mm_sig_select;
wire flash_ss_sig_select;

//alarm.v
wire [16:0] cout_down;
wire [16:0] reset_down;
wire [16:0] pause_down;
wire [16:0] init_time_down;
wire flash_hh_sig_down;
wire flash_mm_sig_down;
wire flash_ss_sig_down;

//stop_watch.v
wire [18:0] cout_stopwatch;	
wire [3:0] lap_display;
wire [16:0] reset_stopwatch;
wire [16:0] pause_stopwatch;

//timer.v
wire [16:0] cout_timer;
wire [16:0] reset_timer;
wire [16:0] pause_timer;
wire [6:0] ones_sec, tens_sec, ones_min, tens_min,ones_hr, tens_hr;
			

reg [16:0] cout_reg = 17'd0;	//Stores time all modules


//HH:MM:SS- flashing						
reg flash_hh_reg = 1'd0;
reg flash_mm_reg = 1'd0;
reg flash_ss_reg = 1'd0;


//input, reset(KEY[1]) and pause(KEY[0]) from mod.v
reg [5:0] start_num_select_reg = 6'd0;									
reg reset_select_reg = 1'd1;													
reg pause_select_reg = 1'd1;	
											
//input, reset(KEY[1]) and pause(KEY[0]) from alarm.v
reg [16:0] init_time_down_reg = 17'd0;									
reg reset_down_reg = 1'd1;													
reg pause_down_reg = 1'd1;		
											
//input, reset(KEY[1]) and pause(KEY[0]) from clock.v
reg [16:0] init_time_clock_reg = 17'd0;								
reg reset_clock_reg = 1'd1;													
reg pause_clock_reg = 1'd1;	
											
//input, lap, reset(KEY[1]) and pause(KEY[0]) from stop_watch.v
reg [18:0] cout_reg_stopwatch = 19'd0;								
reg reset_stopwatch_reg = 1'd1;												
reg lap_stopwatch_reg = 1'd1;												
reg pause_stopwatch_reg = 1'd0;											
reg [3:0] lap_display_reg = 4'd0;	
							


parameter zero = 2'b00;
parameter one = 2'b01;
parameter two = 2'b10;



//instantiation 
mode instance1 (
.clk(clk), 
.start_num(start_num_select), 
.reset(reset_select), 
.button(pause_select), 
.cout(cout_select), 
.flash_hh_sig(flash_hh_sig_select), 
.flash_mm_sig(flash_mm_sig_select), 
.flash_ss_sig(flash_ss_sig_select)
);


clock instance2 (
.clk(clk), 
.start_time(init_time_clock), 
.reset(reset_clock), 
.pause(pause_clock), 
.cout(cout_clock)
);


alarm instance3 (
.clk(clk), 
.start_time(init_time_down), 
.reset(reset_down), 
.pause(pause_down), 
.flash_hh_sig(flash_hh_sig_down), 
.flash_mm_sig(flash_mm_sig_down),
.flash_ss_sig(flash_ss_sig_down), 
.cout (cout_down)
);


stop_watch instance4 (
.clk(clk), 
.reset(reset_stopwatch), 
.play(pause_stopwatch), 
.lap(lap_stopwatch), 
.cout(cout_stopwatch), 
.switches(lap_display)
);

timer instance5 (
.clk(clk), 
.pause(pause_timer), 
.reset(reset_timer), 
.seconds_counter(seconds_counter), 
.minutes_counter(minutes_counter), 
.hours_counter(hours_counter)
);

always @(posedge clk)
begin
	case (state)
		zero:	
//to select between modes		
		begin
			cout_reg <= cout_select;
			reset_select_reg <= reset;
			pause_select_reg <= pause;
			start_num_select_reg [5:0] <= start_num [5:0];
			reset_down_reg <= 1'd1;
			pause_down_reg <= 1'd1;
			reset_clock_reg <= 1'd1;
			pause_clock_reg <= 1'd1;
			lap_stopwatch_reg <= 1'd1;
		reset_stopwatch_reg <= 1'd1;
			lap_display_reg [3:0] <= 4'd0;
			flash_hh_reg <= flash_hh_sig_select;
			flash_mm_reg <= flash_mm_sig_select;
			flash_ss_reg <= flash_ss_sig_select;
		end
		//clock
		one:										
		begin
			
			cout_reg <= cout_clock;
			reset_clock_reg <= reset;
			pause_clock_reg <= pause;
			start_num_select_reg [5:0] <= 6'd0;
			reset_select_reg <= 1'd1;
			pause_select_reg <= 1'd1;
			reset_down_reg <= 1'd1;
			pause_down_reg <= 1'd1;
			lap_stopwatch_reg <= 1'd1;
		reset_stopwatch_reg <= 1'd1;
		lap_display_reg [3:0] <= 4'd0;
			flash_hh_reg <= 1'd0;
			flash_mm_reg <= 1'd0;
			flash_ss_reg <= 1'd0;
		end
		
		//alarm 
		two:
		begin
			cout_reg <= cout_down;
			reset_down_reg <= reset;
			pause_down_reg <= pause;
			start_num_select_reg [5:0] <= 6'd0;
			reset_select_reg <= 1'd1;
			pause_select_reg <= 1'd1;
			reset_clock_reg <= 1'd1;
			pause_clock_reg <= 1'd1;
			lap_stopwatch_reg <= 1'd1;
			reset_stopwatch_reg <= 1'd1;
			lap_display_reg [3:0] <= 4'd0;
			flash_hh_reg <= flash_hh_sig_down;
			flash_mm_reg <= flash_mm_sig_down;
			flash_ss_reg <= flash_ss_sig_down;
		end
		// deafult will be stopwatch (SW[8] && SW[9] == 1)
		default:									
		begin
			cout_reg_stopwatch <= cout_stopwatch;
			reset_select_reg <= 1'd1;
			pause_select_reg <= 1'd1;
			reset_down_reg <= 1'd1;
			pause_down_reg <= 1'd1;
			reset_clock_reg <= 1'd1;
			pause_clock_reg <= 1'd1;
			start_num_select_reg [5:0] <= 6'd0;
			lap_stopwatch_reg <= pause;
			reset_stopwatch_reg <= reset;
			pause_stopwatch_reg <= start_num[5];
			lap_display_reg [3:0] <= start_num [3:0];
			flash_hh_reg <= 1'd0;
			flash_mm_reg <= 1'd0;
			flash_ss_reg <= 1'd0;
		end
	endcase
end

//confirms time when SW[6]==1 
always @(posedge clk, posedge fDown, posedge fClock)
begin
	if (fClock == 1)
	begin
		if (fDown == 1)
		begin
			init_time_clock_reg <= init_time_clock_reg;
			init_time_down_reg <= init_time_down_reg;
		end
		else
		begin
			init_time_clock_reg <= init_time_clock_reg;
			init_time_down_reg <= cout_reg;
		end
	end
	else
	begin
		if (fDown == 1)
		begin
			init_time_clock_reg <= cout_reg;
			init_time_down_reg <= init_time_down_reg;
		end
		else
		begin
			init_time_clock_reg <= cout_reg;
			init_time_down_reg <= cout_reg;
		end
	end
	
end


assign cout = (state == 2'b11) ? cout_reg_stopwatch : cout_reg;

//modified from our lab 4
//	digit for hex0[6:0]
	assign hex0[0] = (flash_ss == 1) ? (1'b1) : (~ss0[3]  & ~ss0[2]  & ~ss0[1]  & ss0[0]) | (~ss0[3]  & ss0[2]  & ~ss0[1]  & ~ss0[0]);
	assign hex0[1] = (flash_ss == 1) ? (1'b1) : (~ss0[3]  & ss0[2]  & ~ss0[1]  & ss0[0]) | (~ss0[3]  & ss0[2]  & ss0[1]  & ~ss0[0]);
	assign hex0[2] = (flash_ss == 1) ? (1'b1) : (~ss0[3]  & ~ss0[2]  & ss0[1]  & ~ss0[0]);
	assign hex0[3] = (flash_ss == 1) ? (1'b1) : (~ss0[3]  & ~ss0[2]  & ~ss0[1]  & ss0[0]) | (~ss0[3]  & ss0[2]  & ~ss0[1]  & ~ss0[0]) | (~ss0[3]  & ss0[2]  & ss0[1]  & ss0[0]);
	assign hex0[4] = (flash_ss == 1) ? (1'b1) : (~ss0[3]  & ~ss0[2]  & ~ss0[1]  & ss0[0]) | (~ss0[3]  & ~ss0[2]  & ss0[1]  & ss0[0]) | (~ss0[3]  & ss0[2]  & ~ss0[1]  & ~ss0[0]) | (~ss0[3]  & ss0[2]  & ~ss0[1]  & ss0[0]) | (~ss0[3]  & ss0[2]  & ss0[1]  & ss0[0]) | (ss0[3]  & ~ss0[2]  & ~ss0[1]  & ss0[0]);
	assign hex0[5] = (flash_ss == 1) ? (1'b1) : (~ss0[3]  & ~ss0[2]  & ~ss0[1]  & ss0[0]) | (~ss0[3]  & ~ss0[2]  & ss0[1]  & ~ss0[0]) | (~ss0[3]  & ~ss0[2]  & ss0[1]  & ss0[0]) | (~ss0[3]  & ss0[2]  & ss0[1]  & ss0[0]);
	assign hex0[6] = (flash_ss == 1) ? (1'b1) : (~ss0[3]  & ~ss0[2]  & ~ss0[1]  & ~ss0[0]) | (~ss0[3]  & ~ss0[2]  & ~ss0[1]  & ss0[0]) | (~ss0[3]  & ss0[2]  & ss0[1]  & ss0[0]);
	
//	digit for hex1[6:0]
	assign hex1[0] = (flash_ss == 1) ? (1'b1) : (~ss1[3]  & ~ss1[2]  & ~ss1[1]  & ss1[0]) | (~ss1[3]  & ss1[2]  & ~ss1[1]  & ~ss1[0]);
	assign hex1[1] = (flash_ss == 1) ? (1'b1) : (~ss1[3]  & ss1[2]  & ~ss1[1]  & ss1[0]) | (~ss1[3]  & ss1[2]  & ss1[1]  & ~ss1[0]);
	assign hex1[2] = (flash_ss == 1) ? (1'b1) : (~ss1[3]  & ~ss1[2]  & ss1[1]  & ~ss1[0]);
	assign hex1[3] = (flash_ss == 1) ? (1'b1) : (~ss1[3]  & ~ss1[2]  & ~ss1[1]  & ss1[0]) | (~ss1[3]  & ss1[2]  & ~ss1[1]  & ~ss1[0]) | (~ss1[3]  & ss1[2]  & ss1[1]  & ss1[0]);
	assign hex1[4] = (flash_ss == 1) ? (1'b1) : (~ss1[3]  & ~ss1[2]  & ~ss1[1]  & ss1[0]) | (~ss1[3]  & ~ss1[2]  & ss1[1]  & ss1[0]) | (~ss1[3]  & ss1[2]  & ~ss1[1]  & ~ss1[0]) | (~ss1[3]  & ss1[2]  & ~ss1[1]  & ss1[0]) | (~ss1[3]  & ss1[2]  & ss1[1]  & ss1[0]) | (ss1[3]  & ~ss1[2]  & ~ss1[1]  & ss1[0]);
	assign hex1[5] = (flash_ss == 1) ? (1'b1) : (~ss1[3]  & ~ss1[2]  & ~ss1[1]  & ss1[0]) | (~ss1[3]  & ~ss1[2]  & ss1[1]  & ~ss1[0]) | (~ss1[3]  & ~ss1[2]  & ss1[1]  & ss1[0]) | (~ss1[3]  & ss1[2]  & ss1[1]  & ss1[0]);
	assign hex1[6] = (flash_ss == 1) ? (1'b1) : (~ss1[3]  & ~ss1[2]  & ~ss1[1]  & ~ss1[0]) | (~ss1[3]  & ~ss1[2]  & ~ss1[1]  & ss1[0]) | (~ss1[3]  & ss1[2]  & ss1[1]  & ss1[0]);

//	digit for hex2[6:0]
	assign hex2[0] = (flash_mm == 1) ? (1'b1) : (~mm0[3]  & ~mm0[2]  & ~mm0[1]  & mm0[0]) | (~mm0[3]  & mm0[2]  & ~mm0[1]  & ~mm0[0]);
	assign hex2[1] = (flash_mm == 1) ? (1'b1) : (~mm0[3]  & mm0[2]  & ~mm0[1]  & mm0[0]) | (~mm0[3]  & mm0[2]  & mm0[1]  & ~mm0[0]);
	assign hex2[2] = (flash_mm == 1) ? (1'b1) : (~mm0[3]  & ~mm0[2]  & mm0[1]  & ~mm0[0]);
	assign hex2[3] = (flash_mm == 1) ? (1'b1) : (~mm0[3]  & ~mm0[2]  & ~mm0[1]  & mm0[0]) | (~mm0[3]  & mm0[2]  & ~mm0[1]  & ~mm0[0]) | (~mm0[3]  & mm0[2]  & mm0[1]  & mm0[0]);
	assign hex2[4] = (flash_mm == 1) ? (1'b1) : (~mm0[3]  & ~mm0[2]  & ~mm0[1]  & mm0[0]) | (~mm0[3]  & ~mm0[2]  & mm0[1]  & mm0[0]) | (~mm0[3]  & mm0[2]  & ~mm0[1]  & ~mm0[0]) | (~mm0[3]  & mm0[2]  & ~mm0[1]  & mm0[0]) | (~mm0[3]  & mm0[2]  & mm0[1]  & mm0[0]) | (mm0[3]  & ~mm0[2]  & ~mm0[1]  & mm0[0]);
	assign hex2[5] = (flash_mm == 1) ? (1'b1) : (~mm0[3]  & ~mm0[2]  & ~mm0[1]  & mm0[0]) | (~mm0[3]  & ~mm0[2]  & mm0[1]  & ~mm0[0]) | (~mm0[3]  & ~mm0[2]  & mm0[1]  & mm0[0]) | (~mm0[3]  & mm0[2]  & mm0[1]  & mm0[0]);
	assign hex2[6] = (flash_mm == 1) ? (1'b1) : (~mm0[3]  & ~mm0[2]  & ~mm0[1]  & ~mm0[0]) | (~mm0[3]  & ~mm0[2]  & ~mm0[1]  & mm0[0]) | (~mm0[3]  & mm0[2]  & mm0[1]  & mm0[0]);
	
//	digit for hex3[6:0]
	assign hex3[0] = (flash_mm == 1) ? (1'b1) : (~mm1[3]  & ~mm1[2]  & ~mm1[1]  & mm1[0]) | (~mm1[3]  & mm1[2]  & ~mm1[1]  & ~mm1[0]);
	assign hex3[1] = (flash_mm == 1) ? (1'b1) : (~mm1[3]  & mm1[2]  & ~mm1[1]  & mm1[0]) | (~mm1[3]  & mm1[2]  & mm1[1]  & ~mm1[0]);
	assign hex3[2] = (flash_mm == 1) ? (1'b1) : (~mm1[3]  & ~mm1[2]  & mm1[1]  & ~mm1[0]);
	assign hex3[3] = (flash_mm == 1) ? (1'b1) : (~mm1[3]  & ~mm1[2]  & ~mm1[1]  & mm1[0]) | (~mm1[3]  & mm1[2]  & ~mm1[1]  & ~mm1[0]) | (~mm1[3]  & mm1[2]  & mm1[1]  & mm1[0]);
	assign hex3[4] = (flash_mm == 1) ? (1'b1) : (~mm1[3]  & ~mm1[2]  & ~mm1[1]  & mm1[0]) | (~mm1[3]  & ~mm1[2]  & mm1[1]  & mm1[0]) | (~mm1[3]  & mm1[2]  & ~mm1[1]  & ~mm1[0]) | (~mm1[3]  & mm1[2]  & ~mm1[1]  & mm1[0]) | (~mm1[3]  & mm1[2]  & mm1[1]  & mm1[0]) | (mm1[3]  & ~mm1[2]  & ~mm1[1]  & mm1[0]);
	assign hex3[5] = (flash_mm == 1) ? (1'b1) : (~mm1[3]  & ~mm1[2]  & ~mm1[1]  & mm1[0]) | (~mm1[3]  & ~mm1[2]  & mm1[1]  & ~mm1[0]) | (~mm1[3]  & ~mm1[2]  & mm1[1]  & mm1[0]) | (~mm1[3]  & mm1[2]  & mm1[1]  & mm1[0]);
	assign hex3[6] = (flash_mm == 1) ? (1'b1) : (~mm1[3]  & ~mm1[2]  & ~mm1[1]  & ~mm1[0]) | (~mm1[3]  & ~mm1[2]  & ~mm1[1]  & mm1[0]) | (~mm1[3]  & mm1[2]  & mm1[1]  & mm1[0]);
	
//	digit for hex4[6:0]
	assign hex4[0] = (flash_hh == 1) ? (1'b1) : (~hh0[3]  & ~hh0[2]  & ~hh0[1]  & hh0[0]) | (~hh0[3]  & hh0[2]  & ~hh0[1]  & ~hh0[0]);
	assign hex4[1] = (flash_hh == 1) ? (1'b1) : (~hh0[3]  & hh0[2]  & ~hh0[1]  & hh0[0]) | (~hh0[3]  & hh0[2]  & hh0[1]  & ~hh0[0]);
	assign hex4[2] = (flash_hh == 1) ? (1'b1) : (~hh0[3]  & ~hh0[2]  & hh0[1]  & ~hh0[0]);
	assign hex4[3] = (flash_hh == 1) ? (1'b1) : (~hh0[3]  & ~hh0[2]  & ~hh0[1]  & hh0[0]) | (~hh0[3]  & hh0[2]  & ~hh0[1]  & ~hh0[0]) | (~hh0[3]  & hh0[2]  & hh0[1]  & hh0[0]);
	assign hex4[4] = (flash_hh == 1) ? (1'b1) : (~hh0[3]  & ~hh0[2]  & ~hh0[1]  & hh0[0]) | (~hh0[3]  & ~hh0[2]  & hh0[1]  & hh0[0]) | (~hh0[3]  & hh0[2]  & ~hh0[1]  & ~hh0[0]) | (~hh0[3]  & hh0[2]  & ~hh0[1]  & hh0[0]) | (~hh0[3]  & hh0[2]  & hh0[1]  & hh0[0]) | (hh0[3]  & ~hh0[2]  & ~hh0[1]  & hh0[0]);
	assign hex4[5] = (flash_hh == 1) ? (1'b1) : (~hh0[3]  & ~hh0[2]  & ~hh0[1]  & hh0[0]) | (~hh0[3]  & ~hh0[2]  & hh0[1]  & ~hh0[0]) | (~hh0[3]  & ~hh0[2]  & hh0[1]  & hh0[0]) | (~hh0[3]  & hh0[2]  & hh0[1]  & hh0[0]);
	assign hex4[6] = (flash_hh == 1) ? (1'b1) : (~hh0[3]  & ~hh0[2]  & ~hh0[1]  & ~hh0[0]) | (~hh0[3]  & ~hh0[2]  & ~hh0[1]  & hh0[0]) | (~hh0[3]  & hh0[2]  & hh0[1]  & hh0[0]);
	
//	digit for hex5[6:0]
	assign hex5[0] = (flash_hh == 1) ? (1'b1) : (~hh1[3]  & ~hh1[2]  & ~hh1[1]  & hh1[0]) | (~hh1[3]  & hh1[2]  & ~hh1[1]  & ~hh1[0]);
	assign hex5[1] = (flash_hh == 1) ? (1'b1) : (~hh1[3]  & hh1[2]  & ~hh1[1]  & hh1[0]) | (~hh1[3]  & hh1[2]  & hh1[1]  & ~hh1[0]);
	assign hex5[2] = (flash_hh == 1) ? (1'b1) : (~hh1[3]  & ~hh1[2]  & hh1[1]  & ~hh1[0]);
	assign hex5[3] = (flash_hh == 1) ? (1'b1) : (~hh1[3]  & ~hh1[2]  & ~hh1[1]  & hh1[0]) | (~hh1[3]  & hh1[2]  & ~hh1[1]  & ~hh1[0]) | (~hh1[3]  & hh1[2]  & hh1[1]  & hh1[0]);
	assign hex5[4] = (flash_hh == 1) ? (1'b1) : (~hh1[3]  & ~hh1[2]  & ~hh1[1]  & hh1[0]) | (~hh1[3]  & ~hh1[2]  & hh1[1]  & hh1[0]) | (~hh1[3]  & hh1[2]  & ~hh1[1]  & ~hh1[0]) | (~hh1[3]  & hh1[2]  & ~hh1[1]  & hh1[0]) | (~hh1[3]  & hh1[2]  & hh1[1]  & hh1[0]) | (hh1[3]  & ~hh1[2]  & ~hh1[1]  & hh1[0]);
	assign hex5[5] = (flash_hh == 1) ? (1'b1) : (~hh1[3]  & ~hh1[2]  & ~hh1[1]  & hh1[0]) | (~hh1[3]  & ~hh1[2]  & hh1[1]  & ~hh1[0]) | (~hh1[3]  & ~hh1[2]  & hh1[1]  & hh1[0]) | (~hh1[3]  & hh1[2]  & hh1[1]  & hh1[0]);
	assign hex5[6] = (flash_hh == 1) ? (1'b1) : (~hh1[3]  & ~hh1[2]  & ~hh1[1]  & ~hh1[0]) | (~hh1[3]  & ~hh1[2]  & ~hh1[1]  & hh1[0]) | (~hh1[3]  & hh1[2]  & hh1[1]  & hh1[0]);
	

// assign HH:MM:SS flash
assign flash_hh = flash_hh_reg;
assign flash_mm = flash_mm_reg;
assign flash_ss = flash_ss_reg;

//assign for clock.v
assign init_time_clock = init_time_clock_reg;
assign reset_clock = reset_clock_reg;
assign pause_clock = pause_clock_reg;

//assign for select.v
assign start_num_select = start_num_select_reg;
assign reset_select = reset_select_reg; 
assign pause_select = pause_select_reg;

//assign for alarm.v
assign init_time_down = init_time_down_reg;
assign reset_down = reset_down_reg; 
assign pause_down = pause_down_reg;

//assign for stop_watch.v
assign pause_stopwatch = pause_stopwatch_reg;
assign reset_stopwatch = reset_stopwatch_reg;
assign lap_stopwatch = lap_stopwatch_reg;
assign lap_display = lap_display_reg;


//ss, mm hours
assign ss = (state == 2'b11) ? ((cout >= 100) ? ( (cout >= 6000) ? ((cout%6000)%100) : (cout % 100) ) : (cout)) : ((cout >= 60) ? ( (cout >= 3600) ? ( (cout%3600)%60) : (cout % 60) ) : (cout));
assign mm = (state == 2'b11) ? ((cout >= 100) ? ( (cout >= 6000) ? ((cout%6000)/100) : (cout / 100) ) : (19'd0)) : ((cout >= 60) ? ( (cout >= 3600) ? ((cout%3600)/60) : (cout / 60) ) : (17'd0));
assign hh = (state == 2'b11) ? ((cout >= 100) ? ( (cout >= 6000) ? (cout/6000) : (19'd0) ) : (19'd0)) : ((cout >= 60) ? ( (cout >= 3600) ? (cout/3600) : (17'd0) ) : (17'd0));

//tens and ones
assign ss0 = (state == 2'b11) ? (ss % 19'd10) : (ss % 17'd10);
assign ss1 = (state == 2'b11) ? (ss / 19'd10) : (ss / 17'd10);
assign mm0 = (state == 2'b11) ? (mm % 19'd10) : (mm % 17'd10);
assign mm1 = (state == 2'b11) ? (mm / 19'd10) : (mm / 17'd10);
assign hh0 = (state == 2'b11) ? (hh % 19'd10) : (hh % 17'd10);
assign hh1 = (state == 2'b11) ? (hh / 19'd10) : (hh / 17'd10);



endmodule

