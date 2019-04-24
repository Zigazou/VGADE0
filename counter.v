module counter (
	input clk,
	input restart,

	output reg [value_bits:0] value
);

parameter increment_every = 1;
parameter increment_bits = 15;
parameter value_bits = 23;

reg [increment_bits:0] internal_counter = 0;

always @(posedge clk or posedge restart)
	if (restart) begin
		internal_counter <= 0;
		value <= 0;
	end else
		if (internal_counter == (increment_every - 1)) begin
			internal_counter <= 0;
			value <= value + 1;
		end else
			internal_counter <= internal_counter + 1;

endmodule
