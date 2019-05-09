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
wire [`SIZE_RANGE] next_size;
wire [`PART_RANGE] next_part;
wire [`CHARINDEX_RANGE] next_charindex;
wire next_halftone;
wire next_blink;
wire next_underline;
wire next_invert;
wire [`COLOR_RANGE] next_foreground;
wire [`COLOR_RANGE] next_background;

wire video_write;
wire [15:0] video_address;
wire [23:0] video_value;
wire [23:0] video_mask;

video_memory memory (
	.clk (clk),
	.clk_load_char (clk_load_char),

	.xtext (xtext),
	.ytext (ytext),

	.charindex (next_charindex),

	.halftone (next_halftone),
	.foreground (next_foreground),
	.background (next_background),
	.size (next_size),
	.part (next_part),
	.blink (next_blink),
	.underline (next_underline),
	.invert (next_invert),
	
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

wire [7:0] next_row;
character_generator char_gen (
	.clk (clk),
	.clk_load_design (clk_load_char),

	.ychar (ychar),

	.charindex (next_charindex),

	.xsize (next_size[0]),
	.ysize (next_size[1]),

	.xpart (next_part[0]),
	.ypart (next_part[1]),

	.underline (next_underline),
	.pixels (next_row)
);

wire blinking;
blinking timer (
	.clk (clk),
	.reset (~reset_button),
	.blinking (blinking)
);

reg [`COLOR_RANGE] current_foreground;
reg [`COLOR_RANGE] current_background;
reg current_blink;
reg current_invert;
reg [7:0] current_row;
reg [7:0] current_mask;

always @(posedge clk)
	if (clk_draw_char) begin
		current_row        <= next_row;
		current_foreground <= next_foreground;
		current_background <= next_background;
		current_blink      <= next_blink;
		current_invert     <= next_invert;

		case ({ next_halftone, ychar[0] })
			2'b00: current_mask <= 8'b11111111;
			2'b01: current_mask <= 8'b11111111;
			2'b10: current_mask <= 8'b10101010;
			2'b11: current_mask <= 8'b01010101;
			default: current_mask <= 8'bxxxxxxxx;
		endcase
	end

always @(posedge clk)
	if (drawing & current_mask[xchar])
		case ({ current_row[xchar], current_invert, ~current_blink | blinking })
			3'b000: dac <= current_background;
			3'b001: dac <= current_background;
			3'b010: dac <= current_background;
			3'b011: dac <= current_foreground;

			3'b100: dac <= current_background;
			3'b101: dac <= current_foreground;
			3'b110: dac <= current_foreground;
			3'b111: dac <= current_background;
			default: dac <= 3'b000;
		endcase
	else
		dac <= 3'b000;

endmodule
