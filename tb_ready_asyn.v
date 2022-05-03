`timescale 1ns/1ns
module testbench;

	reg clk_tb, reset_tb;
	reg [31:0] data_tb; // synchronous
	reg [31:0] s_data_fill; // asynchronous
	parameter halfperiod=5;
	parameter reset_delay=100;

	wire [31:0] data;	// synchronous
	wire valid, ready;  // valid synchronous, ready asynchronous
	wire valid_var;
	
	master m0(.clk(clk_tb), 
				.reset(reset_tb), 
				.trans_data(data_tb), 
				.ready(ready),
				.data(data),
				.valid(valid),
				.valid_var(valid_var)
				);
	slave s0(.clk(clk_tb),
			.reset(reset_tb),
			.data(data),
			.valid(valid),
			.ready(ready),
			.valid_var(valid_var),
			.s_data_fill(s_data_fill)
			);
// clock generation
	initial begin
		clk_tb=0;
		forever begin
			#halfperiod clk_tb=~clk_tb;
		end
	end
// reset generation
	initial begin
		reset_tb=1;
			#reset_delay reset_tb=0;
	end
// transmit data generation
	initial begin
		data_tb=32'b0;
		#195;
		data_tb=32'h20220503;
		#10;
		data_tb=32'b0;
		#200;
		data_tb=32'h10000006;
	end
	
	initial begin
		s_data_fill=32'h10000006;
		#192;
		s_data_fill=32'b0;
	end
endmodule