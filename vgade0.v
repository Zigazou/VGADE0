`include "constant.vh"
module vgade0 (
	input clk,
	input reset_button,

	// The 5 wires needed for VGA 3 bit color
	output wire hsync,
	output wire vsync,

	output wire red,
	output wire green,
	output wire blue,
	
	// I2C communication
	inout sda,
	input scl
);

wire [`COORDINATE_RANGE] xpos;
wire [`COORDINATE_RANGE] ypos;
wire drawing;

wire [`COORDINATE_RANGE] xdraw;
wire [`COORDINATE_RANGE] ydraw;
wire [`CHARWIDTH_RANGE] xchar;
wire [`CHARHEIGHT_RANGE] ychar;

wire [`TEXTCOLS_RANGE] xtext;
wire [`TEXTROWS_RANGE] ytext;
vga_timing_800_600_72 vga_timer (
	.clk (clk),
	.reset (~reset_button),

	.hsync (hsync),
	.vsync (vsync),

	.xpos (xpos),
	.ypos (ypos),

	.xdraw (xdraw),
	.ydraw (ydraw),

	.xchar (xchar),
	.ychar (ychar),
	
	.xtext (xtext),
	.ytext (ytext),
	
	.drawing (drawing)
);

// Character attributes
wire [`COLOR_RANGE] foreground;
wire [`COLOR_RANGE] background;
wire [`SIZE_RANGE] size;
wire [`PART_RANGE] part;
wire [`CHARINDEX_RANGE] charindex;
wire blink;
wire underline;
wire invert;

video_memory memory (
	.clk (clk),

	.xtext (xtext),
	.ytext (ytext),

	.charindex (charindex),

	.foreground (foreground),
	.background (background),
	.size (size),
	.part (part),
	.blink (blink),
	.underline (underline),
	
	.write (character_change),
	.xtextwrite (xtextwrite),
	.ytextwrite (ytextwrite),
	.value (charattr)
);

wire character_change;
wire [`TEXTCOLS_RANGE] xtextwrite;
wire [`TEXTROWS_RANGE] ytextwrite;
wire [7:0] attribute2;
wire [7:0] attribute1;
wire [7:0] character;
wire [23:0] charattr;
assign charattr = { attribute2, attribute1, character };

i2c_slave i2c (
	.clk (clk),
	.sda (sda),
	.scl (scl),
	.rst (~reset_button),

	.character_change (character_change),
	
	.character (character),
	.xtext (xtextwrite),
	.ytext (ytextwrite),
	.attribute1 (attribute1),
	.attribute2 (attribute2)
);

wire pixel;
character_generator char_gen (
	.clk (clk),
	.xchar (xchar),
	.ychar (ychar),
	.character_index (charindex),
	.underline (underline),
	.invert (invert),
	.pixel (pixel)
);

wire blinking;
blinking timer (
	.clk (clk),
	.reset (~reset_button),
	.blinking (blinking)
);

wire fred;
wire fgreen;
wire fblue;

wire bred;
wire bgreen;
wire bblue;

assign fred   = drawing & foreground[`BIT0];
assign fgreen = drawing & foreground[`BIT1];
assign fblue  = drawing & foreground[`BIT2];

assign bred   = drawing & background[`BIT0];
assign bgreen = drawing & background[`BIT1];
assign bblue  = drawing & background[`BIT2];

assign red   = (pixel & (~blink | blinking)) ? fred : bred;
assign green = (pixel & (~blink | blinking)) ? fgreen : bgreen;
assign blue  = (pixel & (~blink | blinking)) ? fblue : bblue;

endmodule
