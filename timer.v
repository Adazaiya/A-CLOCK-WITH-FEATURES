module timer (
    input clk,
	 input pause,  //SW[8]
    input reset,  //SW[9] 
    output reg [6:0] seconds_counter,
    output reg [6:0] minutes_counter,
    output reg [6:0] hours_counter
);

//timer function-goes up
    always @(posedge clk or negedge reset) begin //when alarm mode is pressed everything is zero 
        if (~reset) begin 
		  
            seconds_counter <= 7'b0;
            minutes_counter <= 7'b0;
            hours_counter <= 7'b0;
        end else if (~pause) begin
		  
            if (seconds_counter == 7'd59) begin
                seconds_counter <= 7'b0;
                if (minutes_counter == 7'd59) begin
                    minutes_counter <= 7'b0;
                    if (hours_counter == 7'd23) begin
                        hours_counter <= 7'b0;
                    end else begin
                        hours_counter <= hours_counter + 1;
                    end
                end else begin
                    minutes_counter <= minutes_counter + 1;
                end
            end else begin
                seconds_counter <= seconds_counter + 1;
            end
        end
    end
endmodule



