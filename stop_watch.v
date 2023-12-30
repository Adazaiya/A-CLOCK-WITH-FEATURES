module stop_watch(
input clk, reset, play, lap,
input [3:0] switches,
output [18:0] cout
);				

reg [31:0] count = 32'd0;		
reg detect = 1'd0;						
reg regular = 2'd0;						
reg [11:0] lap_buffer [18:0];			
reg [3:0] current_lap = 4'd1;				
reg [18:0] cout_buffer = 19'd0;		
reg [18:0] out_buffer = 19'd0;

parameter full_sec = 32'd500000;	//cycles in a full second of a 50Mhz clock.

//stop_watch function
always @(negedge clk or negedge reset or negedge lap)
begin
	if (reset == 0)		
	begin	
		count <= 32'd0;
		cout_buffer <= 19'd0;
		detect <= 1'd0;
		lap_buffer[11] <= 19'd0;
		lap_buffer[10] <= 19'd0;
		lap_buffer[9] <= 19'd0;
		lap_buffer[8] <= 19'd0;
		lap_buffer[7] <= 19'd0;
		lap_buffer[6] <= 19'd0;
		lap_buffer[5] <= 19'd0;
		lap_buffer[4] <= 19'd0;
		lap_buffer[3] <= 19'd0;
		lap_buffer[2] <= 19'd0;
		lap_buffer[1] <= 19'd0;
		lap_buffer[0] <= 19'd0;
		current_lap <= 4'd1;
	end	
	else 	//reset == 0
	begin
		if(lap == 0)		
		begin
			detect <= (regular==2'd0) ? (1'd0) : (1'd1);
		end
		else					
		begin
			if (play == 1)					
			begin
				if(detect==1'd1 && regular!=2'd0) //if push was detected
				begin
				detect <= 1'd0;
				regular <= 1'd1;
				lap_buffer[current_lap] <= (current_lap >= 4'd11) ? (lap_buffer[current_lap]) : cout_buffer;
				current_lap <= (current_lap >= 4'd11) ? (current_lap) : current_lap + 4'd1;		
				end
				else	//if no push detected
				begin
					regular <= 2'd1;
					lap_buffer[current_lap] <= 19'd0; 
					current_lap <= current_lap;
				end
				count <= count + 32'd1;
				if(count >= full_sec - 32'd1) //if full second is reached, reset count
				begin
					count <= 32'd0;
					cout_buffer <= cout_buffer + 19'd1;
				end
				else
				begin
					cout_buffer <= cout_buffer;
				end				
			end
			else								
			begin
				if(detect==1'd1 && regular!=2'd0) //if push was detected
				begin
					detect <= 1'd0;
					regular <= 2'd1;
					lap_buffer[current_lap] <= (current_lap >= 4'd11) ? (lap_buffer[current_lap]) : cout_buffer;
					current_lap <= (current_lap >= 4'd11) ? (current_lap) : current_lap + 4'd1;
				end
				else	//if no push was detected
				begin
					regular <= 2'd1;
					lap_buffer[current_lap] <= 19'd0; 
					current_lap <= current_lap;
				end
				count <= count;
				cout_buffer <= cout_buffer;				
			end
		end	
	end
end	


always @ (posedge clk) 
begin
	if (switches == 4'd0)
		out_buffer <= (cout_buffer >= 19'd360000) ? (cout_buffer - 19'd360000) : (cout_buffer);
	else
		out_buffer <= (cout_buffer >= 19'd360000) ? ( (current_lap >= 4'd3) ? ((lap_buffer[switches]==19'd0)?(19'd0):(lap_buffer[switches] - lap_buffer[switches-4'd1])) : (lap_buffer[switches] - 19'd360000)) : ( (current_lap >= 4'd3) ? ((lap_buffer[switches]==19'd0)?(19'd0):(lap_buffer[switches] - lap_buffer[switches-4'd1])) : (lap_buffer[switches]) );
end

assign cout = out_buffer;

endmodule