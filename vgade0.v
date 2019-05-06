`timescale 1ns/10ps
`include "constant.vh"
module vgade0 (
	input clk,
	input reset_button,

	// The 5 wires needed for VGA 3 bit color
	output wire hsync,
	output wire vsync,

	output reg [2:0] dac,
	
	// I2C communication
	inout sda,
	input scl
);

wire drawing;

wire [`CHARWIDTH_RANGE] xchar;
wire [`CHARHEIGHT_RANGE] ychar;

wire [`TEXTCOLS_RANGE] xtext;
wire [`TEXTROWS_RANGE] ytext;
wire clk_load_design;
wire clk_load_char;
wire clk_draw_char;
vga_timing_800_600_72 vga_timer (
	.clk (clk),
	.reset (~reset_button),

	.clk_load_design (clk_load_design),
	.clk_load_char (clk_load_char),
	.clk_draw_char (clk_draw_char),

	.hsync (hsync),
	.vsync (vsync),

	.xchar (xchar),
	.ychar (ychar),
	
	.xtext (xtext),
	.ytext (ytext),
	
	.drawing (drawing)
);

// Character attributes
wire [`SIZE_RANGE] _size;
wire [`PART_RANGE] _part;
wire [`CHARINDEX_RANGE] _charindex;
wire _halftone;
wire _blink;
wire _underline;
wire _invert;
wire [`COLOR_RANGE] _foreground;
wire [`COLOR_RANGE] _background;

wire video_write;
wire [15:0] video_address;
wire [23:0] video_value;
wire [23:0] video_mask;

video_memory memory (
	.clk (clk),
	.clk_load_char (clk_load_char),

	.xtext (xtext),
	.ytext (ytext),

	.charindex (_charindex),

	.halftone (_halftone),
	.foreground (_foreground),
	.background (_background),
	.size (_size),
	.part (_part),
	.blink (_blink),
	.underline (_underline),
	.invert (_invert),
	
	.video_write (video_write),
	.video_address (video_address),
	.video_value (video_value),
	.video_mask (video_mask)
);

wire busy;
wire execute;
wire [47:0] command;
i2c_slave i2c (
	.clk (clk),
	.sda (sda),
	.scl (scl),
	.rst (~reset_button),

	.busy (busy),
	.execute (execute),
	.command (command)
);

tpu tpu_instance (
	.clk (clk),
	.reset (~reset_button),

	.execute (execute),
	.command (command),
	.busy (busy),

	.video_write (video_write),
	.video_address (video_address),
	.video_value (video_value),
	.video_mask (video_mask)
);

wire [7:0] _row;
character_generator char_gen (
	.clk (clk),
	.clk_load_design (clk_load_char),

	.ychar (ychar),

	.charindex (_charindex),

	.xsize (_size[0]),
	.ysize (_size[1]),

	.xpart (_part[0]),
	.ypart (_part[1]),

	.halftone (_halftone),
	.underline (_underline),
	.invert (_invert),
	.pixels (_row)
);

wire blinking;
blinking timer (
	.clk (clk),
	.reset (~reset_button),
	.blinking (blinking)
);

reg [`COLOR_RANGE] foreground;
reg [`COLOR_RANGE] background;
reg blink;
reg pixel;
reg [7:0] row;

always @(posedge clk_draw_char) begin
	row        <= _row;
	foreground <= _foreground;
	background <= _background;
	blink      <= _blink;
end

/*
always @(posedge clk)
	if (clk_draw_char) begin
		row        <= _row;
		foreground <= _foreground;
		background <= _background;
		blink      <= _blink;
	end
*/

always @(posedge clk)
	case ({ drawing, row[xchar] & (~blink | blinking) })
		2'b11: dac <= foreground;
		2'b10: dac <= background;
		default: dac <= 3'b0;
	endcase


endmodule
