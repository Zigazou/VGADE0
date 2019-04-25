`timescale 1 ns / 100 ps
`include "vga_timing_800_600_72.v"
`include "constant.vh"
module vga_timing_800_600_72_tb();

// Initializes reset.
reg reset = `FALSE;

// Create a 50 Mhz clock (its state changes every 10 nanoseconds).
reg clk_50 = 1'b0;
always #10 clk_50 = ~clk_50;

// Create the VGA timer. No need to connect anything apart from clk and reset,
// the VCD dump will catch everything we need for us.
vga_timing_800_600_72 vga_timer (.clk(clk_50), .reset(reset));

// Run the simulation.
initial begin
	// Dump simulation data to simul.vcd. It could then be read by GTKWave.
    $dumpfile("simul.vcd");
	$dumplimit(100_000_000); // No more than 100 megabytes.
	$dumpvars(); // Dump everything!

	// Run the simulation for 1/72th second (13,888,889 nanoseconds).
	// This will generate data for exactly one frame.
	#13_888_889;

	// Stop the simulation.
    $finish;
end 

endmodule

