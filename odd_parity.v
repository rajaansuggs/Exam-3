module odd_parity(clk, rst, a);
wire a;
wire parity;
  parameter
  PARITY
  NOTPARITY
always(Posedge clk or negedge rst)
  if(rst==1'b0)
    parity=1'b0
    else if(rst==1'b1 and enParity==1'b0)
    parity=1'b0
      else 
        
      
      
    
