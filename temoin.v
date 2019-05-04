module temoin (
	input wire clk,
	input wire reset,
	
	input wire signal,

	output reg light
);

reg [31:0] counter;

initial begin
	counter = 0;
	light = 0;
end

always @(posedge clk)
	if (reset) begin
		counter <= 0;
		light <= 0;
	end else
		if (signal) begin
			counter <= 32'd20_000_000;
			light <= 1'b1;
		end else
			if (counter == 32'd0)
				light <= 1'b0;
			else
				counter <= counter - 32'd1;

endmodule
