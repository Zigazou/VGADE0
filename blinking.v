module blinking (
	input clk,
	input reset,
	
	output wire blinking
);

parameter duration_on  = 25_000_000;
parameter duration_off = 25_000_000;

localparam duration = duration_on + duration_off;

integer counter;
always @(posedge clk or posedge reset) 
	if (reset)
		counter <= 0;
	else begin
		counter <= counter + 1;
		if (counter == duration) counter <= 0;
	end

assign blinking = counter < duration_on;

endmodule
