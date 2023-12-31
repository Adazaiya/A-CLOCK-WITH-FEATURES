module clock (
  input clk,
  input [16:0] start_time,
  input reset,
  input pause,
  output [16:0] cout
);


reg [31:0] count = 32'd0;				
reg state = 1'd1;						
reg detect = 1'd0;						
reg regular = 2'd0;						
reg [16:0] cout_reg = 17'd0;		
reg [16:0] out_reg = 17'd0;	


parameter full_sec = 32'd50000000;	//cycles in full second of 50Mhz clock.
parameter full_day = 17'd86400;		//24 h = 86400 sec
	

//clock function
always @(negedge clk or negedge reset or negedge pause)
begin
	if (reset == 0)		
	begin	
		count <= 32'd0;
		cout_reg <= 17'd0;
		state <= 1'd1;
		detect <= 1'd0;
end	
	else 
		begin
		if (pause == 0)		
	begin
		detect <= (regular == 2'd0) ? 1'd0 : 1'd1;
	end else begin
			if ((detect == 1'd1) && (regular != 2'd0))		
		begin
			detect <= 1'd0;			
			state <= ~state;			
			if (state == 1'd1)		
		begin
			count <= count + 32'd1;
			if (count >= full_sec - 32'd1)	
		begin
			count <= 32'd0;
			cout_reg <= ((cout_reg + start_time) >= 17'd86399) ? (17'd0 - start_time) : cout_reg + 17'd1;
			if (regular <= 2'd0)
		begin
			regular <= regular + 2'd1;
			detect <= 1'd0;
				end
			end
		end				
	end else	begin
			if (state == 1'd1)	
		begin
			count <= count + 32'd1;
				if (count >= full_sec - 32'd1) //increment by 1 sec
		begin
			count <= 32'd0;
				cout_reg <= ((cout_reg + start_time) >= 17'd86399) ? (17'd0 - start_time) : cout_reg + 17'd1;
						
				if (regular <= 2'd0)
		begin
			regular <= regular + 2'd1;
				detect <= 1'd0;
		end
		end
		end
	end
   end
end
	end	


always @(negedge clk)
begin
out_reg <= cout_reg + start_time;
end

assign cout = out_reg;

endmodule