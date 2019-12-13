module WRAPPER_EXAM_III(
	CLOCK_50,
	LEDG,
	LEDR,
	SW,
	KEY
);

//=======================================================
//  PORT declarations
//=======================================================

//////////// CLOCK //////////
input 		          		CLOCK_50;
input				[3:0]				KEY;
//////////// LED //////////
output		     [8:0]		LEDG;
output		    [17:0]		LEDR;
reg [17:0]LEDR;
reg [8:0]LEDG;

//////////// SW //////////
input 		    [17:0]		SW;

reg [15:0]a;
reg [15:0]b;
reg [15:0]c;
reg [15:0]d;
reg start;

wire [15:0]g;
wire [15:0]h;
wire rst;
wire done;

//=======================================================
//  MODULE declaration - THIS IS WHERE YOUR MODULE WILL LINK
//=======================================================
your_exam_module instantiated(CLOCK_50, rst, a, b, c, d, g, h, start, done); // when start goes high your code is executed and done goes on when your circuit is done

//=======================================================
//  Structural coding
//=======================================================
wire [16:0]SWO;
debounce_DE2_SW deb(CLOCK_50, rst, SW[16:0], SWO);

assign rst = SW[17]; // initialize the reset to swtich 17

reg [3:0]S; // STATE BITS
reg [3:0]NS;

// STATES
parameter WAIT_A = 4'd0,
		GET_A = 4'd1,
		WAIT_B = 4'd2,
		GET_B = 4'd3,
		WAIT_C = 4'd4,
		GET_C = 4'd5,
		WAIT_D = 4'd6,
		GET_D = 4'd7,
		EXECUTE = 4'd8,
		GOT_A = 4'd9,
		GOT_B = 4'd10,
		GOT_C = 4'd11,
		GOT_D = 4'd12,
		DANGER = 4'hF;
		
always @(posedge CLOCK_50 or negedge rst)
begin
	if (rst == 1'b0)
		S <= WAIT_A;
	else
		S <= NS;
end
		
/* 
	STATE MACHINE grabs each bit of your inputs in order a, b, c, d and then sets the start to 1 and your system should run.  To enter a number, first assign the 16 bit number
	on SW[15:0] and then flip SW[16] high to enter the value.  Then press KEY[0] enter the next number.  Continue this process four times.  KEY[1]
	selects between the 2 outputs.
	Note reset has to be high during all of this.  
	
	DISPLAYED:
		LEDR[15:0] displays either g or h
		LEDR[16] is on when you've entered the execute phase and sent start signal
		LEDR[17] displays the debounced value of SW[16] ... if it is not read properly, then restart ...
		LEDG[2:1] the sequence should be 1 on then both (which you won't see), then 2 on to grab a
		LEDG[0] in the end will show the done signal
		LEDG[4:3] the sequence should be 3 on then both (which you won't see), then 4 on to grab b
		LEDG[6:5] the sequence should be 5 on then both (which you won't see), then 6 on to grab c
		LEDG[8:7] the sequence should be 7 on then both (which you won't see), then 8 on to grab d
	*/
always @(*)		
begin
	case (S)
		GET_A: NS = GOT_A;
		GET_B: NS = GOT_B;
		GET_C: NS = GOT_C;
		GET_D: NS = GOT_D;
		GOT_A:
		begin
			if (KEY[0] == 1'b1)
				NS = WAIT_B;
			else
				NS = GOT_A;
		end
		GOT_B:
		begin
			if (KEY[0] == 1'b1)
				NS = WAIT_C;
			else
				NS = GOT_B;
		end
		GOT_C:
		begin
			if (KEY[0] == 1'b1)
				NS = WAIT_D;
			else
				NS = GOT_C;
		end
		GOT_D:
		begin
			if (KEY[0] == 1'b1)
				NS = EXECUTE;
			else
				NS = GOT_D;
		end
		WAIT_A:
		begin
			if (KEY[0] == 1'b1)
				NS = WAIT_A;
			else
				NS = GET_A;
		end
		WAIT_B:
		begin
			if (KEY[0] == 1'b1)
				NS = WAIT_B;
			else
				NS = GET_B;
		end
		WAIT_C:
		begin
			if (KEY[0] == 1'b1)
				NS = WAIT_C;
			else
				NS = GET_C;
		end
		WAIT_D:
		begin
			if (KEY[0] == 1'b1)
				NS = WAIT_D;
			else
				NS = GET_D;
		end
		EXECUTE: NS = EXECUTE; // spins here forever once here
		default: NS = DANGER;
	endcase
end

always @(posedge CLOCK_50 or negedge rst)
begin
	if (rst == 1'b0)
	begin	
		a <= 16'd0;
		b <= 16'd0;
		c <= 16'd0;
		d <= 16'd0;
		start <= 1'b0;
		LEDG[8:0] <= 9'd0;
		LEDR[17:0] <= 18'd0;
	end
	else
	begin
		LEDR[15:0] <= KEY[1] ? g : h; // look at g output if KEY[1] = 1 otherwise h
		LEDR[17] <= KEY[0];
		case (S)
			GOT_A: LEDG[1] <= 1'b0;
			GOT_B: LEDG[3] <= 1'b0;
			GOT_C: LEDG[5] <= 1'b0;
			GOT_D: LEDG[7] <= 1'b0;
			GET_A:
			begin
				a <= SWO[15:0];
				LEDG[2] <= 1'b1;
			end
			GET_B:
			begin
				b <= SWO[15:0];
				LEDG[4] <= 1'b1;
			end
			GET_C:
			begin
				c <= SWO[15:0];
				LEDG[6] <= 1'b1;
			end
			GET_D:
			begin
				d <= SWO[15:0];
				LEDG[8] <= 1'b1;
			end
			WAIT_A:
			begin
				LEDG[1] <= 1'b1;
			end
			WAIT_B:
			begin
				LEDG[3] <= 1'b1;
			end
			WAIT_C:
			begin
				LEDG[5] <= 1'b1;
			end
			WAIT_D:
			begin
				LEDG[7] <= 1'b1;
			end
			EXECUTE: 
			begin
				start <= 1'b1;
				LEDR[16] <= 1'b1;
				LEDG[0] <= done; // light goes on when your circuit is done		
			end
		endcase
	end
end

endmodule

//=======================================================
//  Don't change anything above
//=======================================================

//=======================================================
//  MODULE - This is where you write your code
//=======================================================

module pop_count1(clk, g, a, out, ena1, temp);
wire temp;
input clk, g, a, ena1, temp;
output out;
reg [1:0]S;
reg [1:0]NS;
assign temp = g+a;

parameter
INITIAL=2'd0,
CONDITION=2'd1,
TEMP1=2'd2,
TEMP2=2'd3,
TEMP3=2'd4,
TEMP4=2'd5,
TEMP5=2'd6,
TEMP6=2'd7,
TEMP7=2'd8,
TEMP8=2'd9,
TEMP9=2'd10,
TEMP10=2'd11,
TEMP11=2'd12,
TEMP12=2'd13,
TEMP13=2'd14,
TEMP14=2'd15,
TEMP15=2'd15,
TEMP16=2'd16,
STOP=2'd17;
	always @(posedge clk)begin
	if(clk ==1'd1 & ena1==1'b1 &start==1'b1)
		S=INITIAL;
	else
		S=NS;
		end
	always@(*)begin
	INITIAL: NS=CONDITION;
	CONDITION: NS=TEMP1;
	TEMP1: begin NS=TEMP2; if(a[0]==1'd1) out=out+1'd1; end
	TEMP2: begin NS=TEMP3;if(temp[1]==1'd1) out=out+1'd1; end
	TEMP3:begin NS=TEMP4;if(temp[2]==1'd1) out=out+1'd1; end
	TEMP4:begin NS=TEMP5;if(temp[3]==1'd1) out=out+1'd1; end
	TEMP5:begin NS=TEMP6;if(temp[4]==1'd1) out=out+1'd1; end
	TEMP6:begin NS=TEMP7;if(temp[5]==1'd1) out=out+1'd1; end
	TEMP7:begin NS=TEMP8;if(temp[6]==1'd1) out=out+1'd1; end
	TEMP8:begin NS=TEMP9;if(temp[7]==1'd1) out=out+1'd1; end
	TEMP9:begin NS=TEMP10;if(temp[8]==1'd1) out=out+1'd1; end
	TEMP10:begin NS=TEMP11;if(temp[9]==1'd1) out=out+1'd1; end
	TEMP11:begin NS=TEMP12;if(temp[10]==1'd1) out=out+1'd1; end
	TEMP12:begin NS=TEMP13;if(temp[11]==1'd1) out=out+1'd1; end
	TEMP13:begin NS=TEMP14;if(temp[12]==1'd1) out=out+1'd1; end
	TEMP14:begin NS=TEMP15;if(temp[13]==1'd1) out=out+1'd1; end
	TEMP15:begin NS=TEMP16;if(temp[14]==1'd1) out=out+1'd1; end
	TEMP16:begin NS=STOP;if(temp[15]==1'd1) out=out+1'd1; end
	STOP:NS=STOP;
	end
	
endmodule

module pop_count2(clk, c, h, ena2);
input clk, c, ena2;
output h;
reg [1:0]S;
reg [1:0]NS;
assign temp = c+c;

parameter
INITIAL=2'd0,
CONDITION=2'd1,
TEMP1=2'd2,
TEMP2=2'd3,
TEMP3=2'd4,
TEMP4=2'd5,
TEMP5=2'd6,
TEMP6=2'd7,
TEMP7=2'd8,
TEMP8=2'd9,
TEMP9=2'd10,
TEMP10=2'd11,
TEMP11=2'd12,
TEMP12=2'd13,
TEMP13=2'd14,
TEMP14=2'd15,
TEMP15=2'd15,
TEMP16=2'd16,
STOP=2'd17;
	always @(posedge clk)begin
	if(clk ==1'd1 & ena1==1'b1 &start==1'b1)
		S=INITIAL;
	else
		S=NS;
		end
	always@(*)begin
	INITIAL: NS=CONDITION;
	CONDITION: NS=TEMP1;
	TEMP1: begin NS=TEMP2; if(a[0]==1'b1) h=h+1'd1; end
	TEMP2: begin NS=TEMP3;if(temp[1]==1'b1) h=h+1'd1; end
	TEMP3:begin NS=TEMP4;if(temp[2]==1'b1) h=h+1'd1; end
	TEMP4: begin NS=TEMP5;if(temp[3]==1'b1) h=h+1'd1; end
	TEMP5: begin NS=TEMP6;if(temp[4]==1'b1) h=h+1'd1; end
	TEMP6:begin NS=TEMP7;if(temp[5]==1'b1) h=h+1'd1; end
	TEMP7:begin NS=TEMP8;if(temp[6]==1'b1) h=h+1'd1; end
	TEMP8:begin NS=TEMP9;if(temp[7]==1'b1) h=h+1'd1; end
	TEMP9:begin NS=TEMP10;if(temp[8]==1'b1) h=h+1'd1; end
	TEMP10:begin NS=TEMP11;if(temp[9]==1'b1) h=h+1'd1; end
	TEMP11:begin NS=TEMP12;if(temp[10]==1'b1) h=h+1'd1; end
	TEMP12: begin NS=TEMP13;if(temp[11]==1'b1) h=h+1'd1; end
	TEMP13:begin NS=TEMP14;if(temp[12]==1'b1) h=h+1'd1; end
	TEMP14:begin NS=TEMP15;if(temp[13]==1'b1) h=h+1'd1; end
	TEMP15:begin NS=TEMP16;if(temp[14]==1'b1) h=h+1'd1; end
	TEMP16:begin NS=STOP;if(temp[15]==1'b1) h=h+1'd1; end
	STOP:begin NS=STOP;
	end
	end
endmodule

module parity(out, a);
input a;
output out;
assign out = ^a;
endmodule

module exp(clk, c, j, g, done, start);
input clk, c, start;
output g, j, done;
reg g, done;
reg [15:0]exp=16'b0;

reg [31:0]temp;

reg [1:0]S;

reg [1:0]NS;	

assign j=1'd1;


parameter

  INIT=2'd0,

  COND=2'd1,

  ITER=2'd2;

	

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
module your_exam_module(clk, rst, a, b, c, d, g, h, start, done);

input clk, rst;
input [15:0]a;
input [15:0]b;
input [15:0]c;
input [15:0]d;
output [15:0]g;
output [15:0]h;
reg [15:0]g;
reg [15:0]h;
input start;
output done;
reg done;
reg[15:0]exp=16'b0;
reg[15:0]temp;
reg[1:0] S = 2'b0;
reg[1:0] NS;
assign i = a;
assign j = 1'd0;
reg out;
wire ena1, ena2;
parity oddp1(out, a);

exp exp1(clk, c, j, g, start, done);
assign ena1=1'b1;
pop_count1 pc1(g, c, a, ena1);
assign ena2=1'b1;
pop_count2 pc2(h, c, ena2);

parameter
INIT1=3'd0,
COND1=3'd1,
ITER1=3'd2,
INIT2=3'd3,
COND2=3'd4,
ISPARITY=3'd5,
RUNMODS=3'd6,
ITER2=3'd7;

always @(posedge clk)begin
	if (rst == 1'b0)
	begin
		g <= 16'd0;
		h <= 16'd0;
		done <= 1'b0;
		INIT <=1'd0;
	end
	else
	begin
		if (start == 1'b1)
		begin
			temp<=a;
			g <= a + b;
			
		end
	end
	end
always @(posedge clk)
begin
	if(start==1'b1)
	S<=INIT1;
	else
	S<=NS;
	end
always@(*)begin
	INIT1: NS=COND1;
	COND1: begin 
	if(i<=a+105)
				NS=INIT2;
			 else
				NS=ITER1;
				end
	ITER1: NS=COND1;
	INIT2: NS=COND2;
	COND2:begin
	if(j<101)
		NS=INIT1;
			else
		NS=ISPARITY;
		end
	ISPARITY: begin
	if(out%2!=0)NS=RUNMODS;
	else NS=ITER2;end
	RUNMODS: NS=ITER2;
	ITER2:NS=ITER;
end

endmodule


//=======================================================
//  Don't change anything below
//=======================================================
module debounce_DE2_SW (clk, rst_n, SW, SWO);
input rst_n, clk;
input [16:0]SW;
output [16:0]SWO;
wire [16:0]SWO;

debouncer sw0(clk, rst_n, SW[0], SWO[0]);
debouncer sw1(clk, rst_n, SW[1], SWO[1]);
debouncer sw2(clk, rst_n, SW[2], SWO[2]);
debouncer sw3(clk, rst_n, SW[3], SWO[3]);
debouncer sw4(clk, rst_n, SW[4], SWO[4]);
debouncer sw5(clk, rst_n, SW[5], SWO[5]);
debouncer sw6(clk, rst_n, SW[6], SWO[6]);
debouncer sw7(clk, rst_n, SW[7], SWO[7]);
debouncer sw8(clk, rst_n, SW[8], SWO[8]);
debouncer sw9(clk, rst_n, SW[9], SWO[9]);
debouncer sw10(clk, rst_n, SW[10], SWO[10]);
debouncer sw11(clk, rst_n, SW[11], SWO[11]);
debouncer sw12(clk, rst_n, SW[12], SWO[12]);
debouncer sw13(clk, rst_n, SW[13], SWO[13]);
debouncer sw14(clk, rst_n, SW[14], SWO[14]);
debouncer sw15(clk, rst_n, SW[15], SWO[15]);
debouncer sw16(clk, rst_n, SW[16], SWO[16]);

endmodule

module debouncer (clk, rst_n, noisy, clean);
input rst_n, clk, noisy;
output clean;
   
reg xnew, clean;

reg [19:0] b_counter;
reg [1:0] S, NS;

parameter 	ON=		2'd0, 
				ON_2_OFF=	2'd1, 
				OFF=		2'd2, 
				OFF_2_ON=	2'd3;

always @ (posedge clk or negedge rst_n) 
begin
	if (rst_n == 1'b0) 
		S <= OFF;
	else
		S <= NS;
end				

always @(*)
begin
	case(S)
		OFF:
		begin
			if (noisy == 1'b1)
				NS = OFF_2_ON;
			else
				NS = OFF;
		end
		ON:
		begin
			if (noisy == 1'b0)
				NS = ON_2_OFF;
			else
				NS = ON;
		end
		OFF_2_ON:
		begin
			if (b_counter >= 20'd1000)
				NS = ON;
			else if (noisy == 1'b0)
				NS = OFF;
			else
				NS = OFF_2_ON;
		end
		ON_2_OFF:
		begin
			if (b_counter >= 20'd1000)
				NS = OFF;
			else if (noisy == 1'b1)
				NS = ON;
			else
				NS = ON_2_OFF;
		end
	endcase
end

always @ (posedge clk or negedge rst_n) 
begin
	if (rst_n == 1'b0) 
	begin
		b_counter <= 20'd0;
		clean <= 1'b0;
	end
	else 
	begin
		case (S)
			ON:
			begin
				b_counter <= 20'd0;
				clean <= 1'b1;
			end
			OFF:
			begin
				b_counter <= 20'd0;
				clean <= 1'b0;
			end
			ON_2_OFF:
			begin
				b_counter <= b_counter + 1'b1;
				clean <= 1'b1;
			end
			OFF_2_ON:
			begin
				b_counter <= b_counter + 1'b1;
				clean <= 1'b0;
			end
		endcase
	end
end
	
endmodule
