module exp(clk, rst, x, n)
parameter
INIT
COND
ITER
always(posedge clk or negedge rst)
if(rst=2'b0)
NS=INIT
else
NS=S
always(*)
case(*)
  INIT:
  COND:
  ITER:
