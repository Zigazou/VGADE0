module counter (
	input clk,
	input restart,

	output reg [23:0] value
);

parameter increment_every = 1;
parameter limit = 1;

integer internal_counter = 0;

always @(posedge clk or posedge restart)
	if (restart) begin
		internal_counter <= 0;
		value <= 0;
	end else
		if (internal_counter == (increment_every - 1)) begin
			internal_counter <= 0;
			if (value == (limit - 1))
				value = 0;
			else
				value <= value + 1;
		end else
			internal_counter <= internal_counter + 1;

endmodule
