module alarm (
input clk, reset, pause,
input [16:0] start_time,
output [16:0] cout,
output flash_hh_sig, flash_mm_sig, flash_ss_sig
);

parameter full_sec = 32'd50000000;	//cycles in full ssond of 50Mhz clock

reg [31:0] count = 32'd0;				
reg state = 1'd1;							
reg detect = 1'd0;						
reg regular = 2'd0;						
reg done = 1'd0;							
reg [16:0] cout_reg = 17'd0;		
reg [16:0] out_reg = 17'd0;	
	
//hh:mm:ss flashes
reg flash_hh = 1'd0;
reg flash_mm = 1'd0;
reg flash_ss = 1'd0;

//this alarm will act as count down timer... 
//user will set the time and when it will go upto 00:00:00 (HH:MM:SS)- all light will keep flashing until resetting

always @(negedge clk or negedge reset or negedge pause)
begin
	if (reset == 0)		
	begin	
		count <= 32'd0;
		cout_reg <= 17'd0;
		state <= 1'd1;
		detect <= 1'd0;
		done <= 1'd0;
		flash_hh <= done ? (~flash_hh) : (1'd0);
		flash_mm <= done ? (~flash_mm) : (1'd0);
		flash_ss <= done ? (~flash_ss) : (1'd0);
	end	
	else 
	begin
		if (pause == 0)		
		begin
		detect <= (regular == 2'd0) ? 1'd0 : 1'd1;
		flash_hh <= 1'd0;
		flash_mm <= 1'd0;
		flash_ss <= 1'd0;
		end
		else
		begin
			if ((detect == 1'd1) && (regular != 2'd0))		
			begin
			detect <= 1'd0;			
			state <= ~state;			
			if (state == 1'd1)		
			begin
				count <= count + 32'd1;
				if (count >= full_sec - 32'd1)	//increment sec by 1
					begin
						count <= 32'd0;
						cout_reg <= cout_reg + 17'd1;
						if(cout_reg >= start_time - 17'd1)
						begin
						cout_reg <= start_time;
						done <= 1'd1;
						flash_hh <= done ? (~flash_hh) : (1'd0);
						flash_mm <= done ? (~flash_mm) : (1'd0);
						flash_ss <= done ? (~flash_ss) : (1'd0);
						end
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
				if (count >= full_sec - 32'd1) //increment sec by 1	
				begin
				count <= 32'd0;
				cout_reg <= cout_reg + 17'd1;
				if(cout_reg >= start_time - 17'd1)
				begin
					cout_reg <= start_time;
					done <= 1'd1;
					flash_hh <= done ? (~flash_hh) : (1'd0);
					flash_mm <= done ? (~flash_mm) : (1'd0);
					flash_ss <= done ? (~flash_ss) : (1'd0);
					end
					
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
	out_reg <= (start_time == 17'd0) ? (17'd0) : start_time - cout_reg;
end

assign flash_hh_sig = (start_time == 17'd0) ? 1'd0 : flash_hh;
assign flash_mm_sig = (start_time == 17'd0) ? 1'd0 : flash_mm;
assign flash_ss_sig = (start_time == 17'd0) ? 1'd0 : flash_ss;
assign cout = out_reg;

endmodule