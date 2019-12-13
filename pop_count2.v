module pop_count2(h, c)
output[15:0]h;
assign pop = c+c;
    always@(*)begin
    if(start == 1'b1)
      begin
      h=pop[0]+pop[1]+pop[2]+pop[3]+pop[4]+pop[5]+pop[6]+pop[7]+pop[8]+pop[9]+pop[10]+pop[11]+pop[12]+pop[13]+pop[14]+pop[15];
      done=1'b1;
      end
  end
endmodule
