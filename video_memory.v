`include "constant.vh"
module video_memory(
	input clk,
	input reset,

	input [`TEXTCOLS_RANGE] xtext,
	input [`TEXTROWS_RANGE] ytext,

	output wire [`CHARINDEX_RANGE] charindex,
	output wire [`COLOR_RANGE] foreground,
	output wire [`COLOR_RANGE] background,
	output wire [`SIZE_RANGE] size,
	output wire [`PART_RANGE] part,
	output wire blink,
	output wire underline,

	// Signals for external reads and writes
	input write,
	input [`TEXTCOLS_RANGE] xtextwrite,
	input [`TEXTROWS_RANGE] ytextwrite,
	input [`CHARATTR_RANGE] value
);

// Video memory consists of a grid of character and attributes
reg [`CHARATTR_RANGE] memory [0:`TEXTCOLS_CHAR * `TEXTROWS_CHAR - 1];
initial $readmemb("data/initial_screen.txt", memory);

// Calculate character and attributes position in the video memory
wire [`VIDMEM_RANGE] mempos;
assign mempos = (ytext * 13'd`TEXTCOLS_CHAR) + xtext;

// Keep current character and attributes in cache
reg [`CHARATTR_RANGE] character;
always @(posedge clk) character <= memory[mempos];

// Split entry into character attributes
assign charindex	= character[`CHARATTR_INDEX];
assign foreground	= character[`CHARATTR_FORE];
assign background	= character[`CHARATTR_BACK];
assign blink		= character[`CHARATTR_BLINK];
assign underline	= character[`CHARATTR_UNDERLINE];
assign size			= character[`CHARATTR_SIZE];
assign part			= character[`CHARATTR_PART];

// Handle external writes to the video memory
always @(posedge clk)
	if (write) memory[(ytextwrite * 13'd`TEXTCOLS_CHAR) + xtextwrite] <= value;

endmodule
