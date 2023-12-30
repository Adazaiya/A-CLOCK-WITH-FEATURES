module mode(
input clk, button, reset,
input [5:0] start_num,
output [16:0] cout,
output flash_hh_sig, flash_mm_sig, flash_ss_sig
);

parameter half_ss = 32'd25000000;   //cycles in half ssond of 50Mhz clock
parameter full_ss = 32'd50000000;   //cycles in full ssond of 50Mhz clock

reg [16:0] hh = 17'd0;
reg [16:0] mm = 17'd0;
reg [16:0] ss = 17'd0;

//hh:mm:ss flashs
reg flash_hh = 1'b0;
reg flash_mm = 1'b0; 
reg flash_ss = 1'b0; 

reg [1:0] pushes = 2'd0;
reg detect = 1'd0;   
reg [1:0] regular = 2'd0;
reg [31:0] count = 32'd0;


//conversion 
reg converse= 11'd0;
wire [16:0] bcd;
assign bcd = {converse, start_num};
      
//user can set the time
always @(posedge clk, negedge reset, negedge button)
begin
   if(reset == 0)             
   begin
      hh = 17'd0;
      mm = 17'd0;
      ss = 17'd0;
      pushes = 2'd0;
      detect = 1'd0; 
      regular = 2'd0;
      flash_hh = 1'b0;
      flash_mm = 1'b0; 
      flash_ss = 1'b0; 
      count = 32'd0;
      converse= 11'd0;
   end
   else                       
   begin
      if (button == 0)        
         begin
         count <= count + 32'd1;
         detect <= (regular == 2'd0) ? 1'd0 : 1'd1;
         flash_hh <= flash_hh;
         flash_mm <= flash_mm;
         flash_ss <= flash_ss;
         ss <= ss;
         mm <= mm;
         hh <= hh;
         pushes <= pushes;
         regular <= regular;
      end
      else                    
      begin 
         if ((detect == 1'd1) && (regular != 2'd0))   
         begin
            detect <= 1'd0;                     
            //hh:mm:ss flashs
            if (count >= full_ss - 32'd1) 
            begin
               count <= 32'd0;
               flash_hh <= 1'd0;
               flash_mm <= 1'd0;
               flash_ss <= 1'd0;
               
            end
            else if (count >= half_ss - 32'd1)
            begin
               count <= count + 32'd1;
               flash_hh <= (pushes == 2'd0) ? 1'd1 : 1'd0;
               flash_mm <= (pushes == 2'd1) ? 1'd1 : 1'd0;
               flash_ss <= (pushes == 2'd2) ? 1'd1 : 1'd0;
            end
            else
            begin
               count <= count + 32'd1;
               flash_hh <= flash_hh;
               flash_mm <= flash_mm;
               flash_ss <= flash_ss;
            end
            if(pushes == 2'd0)                  //first push: HH --> store and increment
            begin
               hh <= bcd;
               mm <= mm;
               ss <= ss;
               pushes <= pushes + 2'd1;
            end
            else if (pushes == 2'd1)            //second push: MM --> store and increment
            begin
               mm <= bcd;
               ss <= ss;
               hh <= hh;
               pushes <= pushes + 2'd1;
            end
            else if (pushes == 2'd2)            //third push: SS --> store and increment
            begin
               ss <= bcd;
               mm <= mm;
               hh <= hh;
               pushes <= pushes + 2'd1;
            end
            else                                
            begin
               ss <= ss;
               mm <= mm;
               hh <= hh;
               pushes <= pushes;
            end
         end
         else                                   
         begin
            regular <= 2'd1;                    
            detect <= 1'd0;                     
            pushes <= pushes;
            
            //flash hh:mm:ss
            
            if (count >= full_ss - 32'd1) 
            begin
               count <= 32'd0;
               flash_hh <= 1'd0;
               flash_mm <= 1'd0;
               flash_ss <= 1'd0;
               
            end
            else if (count >= half_ss - 32'd1)
            begin
               count <= count + 32'd1;
               flash_hh <= (pushes == 2'd0) ? 1'd1 : 1'd0;
               flash_mm <= (pushes == 2'd1) ? 1'd1 : 1'd0;
               flash_ss <= (pushes == 2'd2) ? 1'd1 : 1'd0;
            end
            else
            begin
               count <= count + 32'd1;
               flash_hh <= flash_hh;
               flash_mm <= flash_mm;
               flash_ss <= flash_ss;
            end
            if(pushes == 2'd0)                  
            begin
               hh <= bcd;
               ss <= ss;
               mm <= mm;
            end
            else if (pushes == 2'd1)            
            begin
               mm <= bcd;
               ss <= ss;
               hh <= hh;
            end
            else if (pushes == 2'd2)            
            begin
               ss <= bcd;
               mm <= mm;
               hh <= hh;
            end
            else                                
            begin
               ss <= ss;
               mm <= mm;
               hh <= hh;
            end
         end
      end
   end
end

assign cout = ( (hh * 17'd3600) + (mm*17'd60) + ss );
assign flash_hh_sig = flash_hh;
assign flash_mm_sig = flash_mm;
assign flash_ss_sig = flash_ss;

endmodule