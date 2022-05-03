module master(
	input clk, reset,
	input [31:0] trans_data,
	input ready,
	output reg valid,
	output reg [31:0] data,
	output valid_var);
	
	reg state_m,nxt_state_m;
	parameter idle_m=0, valid_m=1;
	
	assign valid_var=!(trans_data==32'b0);
	
	always @ (*) begin
		case(state_m)
		idle_m: if(valid_var)
					nxt_state_m=valid_m;
					else nxt_state_m=idle_m;
		valid_m: if(valid_var)
					nxt_state_m=valid_m;
					else nxt_state_m=idle_m;
		default: nxt_state_m=idle_m;
		endcase
	end
	
	always @ (posedge clk) begin
		if(reset) begin
			state_m<=idle_m;
			valid<=0;
			end
			else begin 
			 state_m<=nxt_state_m;
			 valid<=valid_var;
			end
	end

	always @ (*) begin
		if(valid) begin
			data<=trans_data;
			end
		else data<=0;
	end
endmodule

module slave(
	input clk, reset,
	input valid,
	input reg [31:0] data,
	input valid_var,
	input [31:0] s_data_fill,
	output reg ready);
	
	wire ready_var, datapath_open;
	reg [31:0] s_data;
	reg state_s, nxt_state_s;
	parameter busy_s=0, ready_s=1;
	
	reg ready_var1;
	reg valid_delay;
	reg [31:0] data_delay;
	
	assign ready_var=(s_data==0);
	assign datapath_open=ready&&valid_delay;
	
	always @ (*) begin
		case(state_s)
		
		busy_s: if(ready_var)
					nxt_state_s=ready_s;
				else nxt_state_s=busy_s;
		ready_s: if(ready_s)
					nxt_state_s=ready_s;
				else nxt_state_s=busy_s;
		default: nxt_state_s=busy_s;
		
		endcase
	end
	
	always @ (posedge clk) begin
		if(reset) begin
			{ready,ready_var1}<=1'b0;
			state_s<=busy_s;
			end
		else begin
				nxt_state_s<=busy_s;
			{ready,ready_var1}<={ready_var1,ready_var};
			end
	end
	
	always @ (posedge clk) begin
		if(reset) begin
			data_delay<=0;
			valid_delay<=0;
			end
		else begin
			data_delay<=data;
			valid_delay<=valid;
		end
	end	
	
	always @ (*) begin
		if(datapath_open) 
			begin
				s_data<=data_delay;
			end
		else begin 
				s_data<=s_data_fill;
			end
	end
endmodule

	