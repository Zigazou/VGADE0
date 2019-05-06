module blinking (
	input clk,
	input reset,
	
	output wire blinking
);

parameter duration_on  = 25_000_000;
parameter duration_off = 25_000_000;

localparam duration = duration_on + duration_off;

integer counter;
always @(posedge clk) 
	if (reset)
		counter <= 0;
	else
		if (counter == duration - 1)
			counter <= 0;
		else
			counter <= counter + 1;

assign blinking = counter < duration_on;

endmodule
