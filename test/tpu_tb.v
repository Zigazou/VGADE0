`timescale 1 ns / 100 ps
`include "tpu.v"
`include "constant.vh"
module tpu_tb();

// Initializes wires.
wire busy;
reg reset = `FALSE;
reg execute = `FALSE;
reg [47:0] command;

// Create a 50 Mhz clock (its state changes every 10 nanoseconds).
reg clk_50 = `FALSE;
always #10 clk_50 = ~clk_50;

// Create the VGA timer. No need to connect anything apart from clk and reset,
// the VCD dump will catch everything we need for us.
tpu tpu_instance (
    .clk (clk_50),
    .reset (reset),
    .execute (execute),
    .command (command),
    .busy (busy)
);

// Run the simulation.
initial begin
	// Dump simulation data to simul.vcd. It could then be read by GTKWave.
    $dumpfile("tpu.vcd");
	$dumplimit(10_000_000); // No more than 10 megabytes.
	$dumpvars(); // Dump everything!
/*
    #20;
    command <= 48'h00_00_00_00_00_01; // Clear screen.
    execute <= `TRUE;

    #40;
    execute <= `FALSE;

    #(20 * 6005);
*/

    #10;
    command <= 48'h00_00_00_20_10_03; // Locate.
    execute <= `TRUE;

    #20;
    execute <= `FALSE;
    wait(~busy);

    #20;
    command <= 48'h00_00_00_00_23_02; // Print character.
    execute <= `TRUE;

    #20;
    execute <= `FALSE;

    wait(~busy);

    #500;

	// Stop the simulation.
    $finish;
end 

endmodule
