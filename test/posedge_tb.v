`timescale 1 ns / 1 ns
module posedge_tb();

// Create a 50 Mhz clock (its state changes every 10 nanoseconds).
reg clk_50 = 1'b0;
always #10 clk_50 = ~clk_50;

reg write = 1'b0;

reg value1 = 1'b0;
reg value2 = 1'b0;

always @(posedge clk_50 or posedge write) begin
    if (clk_50) value1 <= ~value1;
    else
        if (write) value2 <= ~value2;
end

// Run the simulation.
initial begin
	// Dump simulation data to simul.vcd. It could then be read by GTKWave.
    $dumpfile("simul.vcd");
	$dumpvars(); // Dump everything!

    #115 write = 1'b1;

	#500;

	// Stop the simulation.
    $finish;
end 

endmodule

