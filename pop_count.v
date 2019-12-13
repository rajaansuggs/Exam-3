module pop_count(g, c, a)
input a, c, g;
wire peach;
assign peach = g[0]+g[1]+g[2]+g[3]+g[4]+g[5]+g[6]+g[7]+g[8]+g[9]+g[10]+g[11]+g[12]+g[13]+g[14]+g[15]+ a[0]+a[1]+a[2]+a[3]+a[4]+a[5]+a[6]+a[7]+a[8]+a[9]+a[10]+a[11]+a[12]+a[13]+a[14]+a[15]
always@(*)begin
    if(start == 1'b1)
      begin
       if(peach%2!=0)begin
          done=1'b1;
          enable=1'b1;
        end
      end
  end
endmodule
