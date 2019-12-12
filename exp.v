module exp(clk, rst, x, n)
wire S, NS
reg S
reg NS
parameter
  INIT=2'd0
  COND=2'd1
  ITER=2'd2
always @ (posedge clk or negedge rst)
if(rst=2'b0)
  NS=INIT
else
  NS=S
always(*)
  case(S)
  INIT:
  COND:
  ITER: S=
    always @ (posedge rst or negedge rst)
begin
	if (rst == 1'd0)
	begin
		INIT <= 11'd0;
		COND<= 11'd0;
		 <= 11'd0;
		S3 <= 11'd0;
		S4 <= 11'd0;
		S5 <= 11'd0;
		S6 <= 11'd0;
		S7 <= 11'd0;
		S8 <= 11'd0;
		S9 <= 11'd0;
	end
