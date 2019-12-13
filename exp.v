module exp(clk, c, j, g, start, done);
wire S, NS;
reg [15:0]exp=16'b0;
reg [15:0]temp;
reg [1:0]S=2'b0;
reg [1:0]NS;	
assign p=0;
parameter
  INIT=2'd0
  COND=2'd1
  ITER=2'd2
	
always @ (posedge clk)
begin
  S<=NS;
end
always @(posedge clk)
begin
  case(S)
	INIT:begin 
		  if(start == 1'b1)
		  begin
			  temp<= c; //C
			  exp<= 16'd0;
			  NS<= COND; 
		  end
		  else NS<=2'd0;
	end
  	COND:begin
		if(temp<j)begin
			exp<=(exp+1'b1);
			temp<= (temp*c);
			NS<=COND;
		end
		  else NS<=ITER;
	end
  	ITER: begin
		g<=exp;
		done<=1'b1;
	end
	endcase
end
endmodule
