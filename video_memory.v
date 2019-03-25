`include "constant.vh"
module video_memory(
	input clk,

	input [`TEXTCOLS_RANGE] xtext,
	input [`TEXTROWS_RANGE] ytext,

	input write,
	input [`TEXTCOLS_RANGE] xtextwrite,
	input [`TEXTROWS_RANGE] ytextwrite,
	input [`CHARATTR_RANGE] value,
	
	output wire [`CHARINDEX_RANGE] charindex,
	output wire [`COLOR_RANGE] foreground,
	output wire [`COLOR_RANGE] background,
	output wire blink
);

reg [`CHARATTR_RANGE] memory [0:`TEXTCOLS_CHAR * `TEXTROWS_CHAR - 1];
initial $readmemb("data/video_memory.txt", memory);

reg [`CHARATTR_RANGE] character;

wire [`VIDMEM_RANGE] mempos;
assign mempos = (ytext * 13'd100) + xtext;

assign charindex  = character[`CHARATTR_INDEX];
assign foreground = character[`CHARATTR_FORE];
assign background = character[`CHARATTR_BACK];
assign blink      = character[`CHARATTR_BLINK];

always @(posedge clk) begin
	character <= memory[mempos];
/*	if (write) memory[(ytextwrite * 13'd100) + xtextwrite] <= value;*/
end

always @(posedge clk) begin
	if (write) memory[(ytextwrite * 13'd100) + xtextwrite] <= value;
end

endmodule
