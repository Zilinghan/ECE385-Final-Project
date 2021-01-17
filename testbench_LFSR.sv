module testbench_LFSR();
	// half clock cycle at 50 MHz
	// this is the amount of time represented by #1 delay
	timeunit 10ns;
	timeprecision 1ns;

	// internal variables
	logic Clk;
	logic load;
	logic [15:0] seed, random_number;
	
	// initialize the toplevel entity
	LFSR LFSR_test(.Clk(Clk),.load(load),.seed(seed),.random_number(random_number));
	
	// set clock rule
	always begin : CLOCK_GENERATION 
		#1 Clk = ~Clk;
	end
	
	// initialize clock signal 
	initial begin: CLOCK_INITIALIZATION 
		Clk = 0;
	end
	
	// begin testing
	initial begin: TEST_VECTORS
    load = 1'b1;
    seed = 16'b0;

	#2 load = 1'b0;
    
	end
	 
endmodule