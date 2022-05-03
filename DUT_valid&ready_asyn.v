module master(
	input clk, reset,
	input [31:0] trans_data,
	input ready,
	output reg valid,
	output [31:0] data,
	output valid_var);
	
	reg state_m,nxt_state_m;
	parameter idle_m=0, valid_m=1;
	reg valid_var1;
	reg [31:0] trans_data_var, trans_data_sync;
	
	assign data=trans_data_sync;
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
			{valid,valid_var1}<=0;
			{trans_data_sync,trans_data_var}<=0;
			end
			else begin 
			 state_m<=nxt_state_m;
			 {valid,valid_var1}<={valid_var1,valid_var};
			 {trans_data_sync,trans_data_var}<={trans_data_var,trans_data};
			end
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
	
	assign ready_var=(s_data==0);
	assign datapath_open=ready&&valid;
	
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
	
	always @ (*) begin
		if(datapath_open) 
			begin
				s_data<=data;
			end
		else begin 
				s_data<=s_data_fill;
			end
	end
endmodule

	