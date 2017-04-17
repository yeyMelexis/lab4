`timescale 1 ns / 1 ps

module my_fir
				(
				clk,
				rst_n,
				filter_in,
				freq,
				filter_out
				);

input	clk;
input	rst_n;
input 	[6:0]	freq;	
	
input	     signed	[17:0]	filter_in;	
output	reg signed	[17:0]	filter_out;	

///////////////////////////////////////////////////////////
//Module Architecture
///////////////////////////////////////////////////////////
	
reg signed	[17:0]	x [0:10];
reg signed	[21:0]	mux_reg;
reg signed	[21:0]	neg_mux_reg;
wire signed	[21:0]	adder1;
reg signed	[21:0]	mux_fin;
reg signed	[24:0]	acc_sum;
reg 	sign_mux_out;	
reg 	sync_rst;
reg [6:0]	cnt;
integer i;

always @(posedge clk, negedge rst_n)begin:	COUNTER
	if(!rst_n) begin
		cnt <= freq;
		sync_rst <= 0;
	end	
	else begin
		if(cnt == 5'b1111)
			sync_rst <= 1;
		if(cnt == freq) begin
			cnt <= 0;
			sync_rst <= 0;
		end	
		else begin
			cnt <= cnt + 1'b1;
		end
	end
end 	//COUNTER

always @(posedge clk, negedge rst_n)begin:	INPUT_REGISTER
	if(!rst_n) 
		for(i = 0; i < 11; i = i + 1)
			x[i] <= 0;
	else 
		if(cnt == freq) begin
			x[0] <= filter_in;
			for(i = 1; i < 11; i = i + 1)
				x[i] <= x[i - 1];
		end
end 	//INPUT_REGISTER

always @*begin
	case(cnt[3:0])
	1:	begin	
			mux_reg = x[0];
			sign_mux_out = 1;
		end
	2:	begin
			mux_reg = x[0]<<1;
			sign_mux_out = 1;
		end	
	3:	begin
			mux_reg = x[1]<<3;
			sign_mux_out = 1;
		end
	4:	begin	
			mux_reg = x[2]<<3;
			sign_mux_out = 1;
		end		
	5:	begin
			mux_reg = x[4]<<3;
			sign_mux_out = 0;
		end
	6:	begin
			mux_reg = x[4]<<1;	
			sign_mux_out = 0;
		end
	7:	begin	
			mux_reg = x[4];
			sign_mux_out = 0;
		end	
	8:	begin
			mux_reg = x[5]<<4;
			sign_mux_out = 0;
		end
	9:	begin
			mux_reg = x[6]<<3;
			sign_mux_out = 0;
		end
	10:	begin
			mux_reg = x[6]<<1;
			sign_mux_out = 0;
		end
	11:	begin
			mux_reg = x[6];
			sign_mux_out = 0;
		end
	12:	begin
			mux_reg = x[8]<<3;
			sign_mux_out = 1;
		end
	13:	begin
			mux_reg = x[9]<<3;
			sign_mux_out = 1;
		end
	14:	begin	
			mux_reg = x[10]<<1;
			sign_mux_out = 1;
		end
	15:	begin
			mux_reg = x[10];
			sign_mux_out = 1;
		end
	default:	begin
					mux_reg = 0;
					sign_mux_out = 0;
				end
	endcase
end 	

always @*	begin
	if(mux_reg[21]&&~(|mux_reg[20:0]))
		neg_mux_reg = 22'h1FFFF;
	else
		neg_mux_reg = ~mux_reg + 1'b1;

	if(!sign_mux_out)
	   mux_fin = mux_reg;
	else
	   mux_fin = neg_mux_reg;
end 	

assign adder1 = mux_fin & {25{!sync_rst}};

always @(posedge clk)	begin
	
	if(~(|cnt)) 
		acc_sum <= 0;
	else
		acc_sum <= acc_sum + adder1;	
end 	

always @(posedge clk, negedge rst_n)begin
	if(!rst_n)
		filter_out <= 0;
	else if(sync_rst)begin
			if(!(acc_sum[24]^acc_sum[23]))
				filter_out <= acc_sum[22:5] + {acc_sum[4]&&(|acc_sum[3:0]||acc_sum[5])};
			else
				case(acc_sum[24])
				0:	filter_out <= 18'h1_FFFF;	
				1:	filter_out <= 18'h2_0000;
				endcase
		end
end

endmodule
