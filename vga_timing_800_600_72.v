// Generate timing for a standard 800x600@72 VGA screen
// clk must be 50 MHz
`include "constant.vh"
module vga_timing_800_600_72 (
	input wire clk,
	input wire reset,

	output wire hsync,
	output wire vsync,

	output wire clk_load_char,
	output wire clk_load_design,
	output wire clk_draw_char,
	
	output reg [`COORDINATE_RANGE] xpos,
	output reg [`COORDINATE_RANGE] ypos,

	output wire [`CHARWIDTH_RANGE] xchar,
	output wire [`CHARHEIGHT_RANGE] ychar,

	output wire	[`TEXTCOLS_RANGE] xtext,
	output wire [`TEXTROWS_RANGE] ytext,

	output wire drawing
);

parameter
	// Horizontal timing in pixels (line)
	// http://www.tinyvga.com/vga-timing/800x600@72Hz
	line_visible_area = `COORDINATE_WIDTH'd800,
	line_front_porch  = `COORDINATE_WIDTH'd56,
	line_sync_pulse   = `COORDINATE_WIDTH'd120,
	line_back_porch   = `COORDINATE_WIDTH'd64,

	// Vertical timing in lines (frame)
	// http://www.tinyvga.com/vga-timing/800x600@72Hz
	frame_visible_area = `COORDINATE_WIDTH'd600,
	frame_front_porch  = `COORDINATE_WIDTH'd37,
	frame_sync_pulse   = `COORDINATE_WIDTH'd6,
	frame_back_porch   = `COORDINATE_WIDTH'd23;

localparam
	// Start and end of the horizontal sync (in pixels)
	hsync_start = line_back_porch + line_visible_area + line_front_porch,
	hsync_end = hsync_start + line_sync_pulse,

	// Start and end of the horizontal drawing
	hdrawing_start = line_back_porch,
	hdrawing_end   = hdrawing_start + line_visible_area,

	// Start and end of the horizontal loading
	hloading_start = hdrawing_start - 7,
	hloading_end   = hdrawing_end - 7,

	// Start and end of the vertical sync (in lines)
	vsync_start = frame_back_porch + frame_visible_area + frame_front_porch,
	vsync_end = vsync_start + frame_sync_pulse,

	// Start and end of the vertical drawing
	vdrawing_start = frame_back_porch,
	vdrawing_end   = vdrawing_start + frame_visible_area;

// Connect wires to the registers
always @(posedge clk)
	if (reset) begin
		xpos <= 0;
		ypos <= 0;
	end else
		if (xpos == hsync_end - 1) begin
			xpos <= 0;
			if (ypos == vsync_end - 1)
				ypos <= 0;
			else
				ypos <= ypos + `COORDINATE_WIDTH'd1;
		end else
			xpos <= xpos + `COORDINATE_WIDTH'd1;

wire hdrawing = (xpos >= hdrawing_start) && (xpos < hdrawing_end);
wire hloading = (xpos >= hloading_start) && (xpos < hloading_end);
wire vdrawing = (ypos >= vdrawing_start) && (ypos < vdrawing_end);

assign drawing = hdrawing && vdrawing;

wire loading = hloading && vdrawing;

assign vsync = reset || (ypos < vsync_start);
assign hsync = reset || (xpos < hsync_start);

assign xtext = loading ? (xpos - hloading_start) / 11'h8 : 7'h00;
assign xchar = (xpos - hdrawing_start) & 11'h7;

assign ytext = vdrawing ? (ypos - vdrawing_start) / 11'd10 : 6'h00;
assign ychar = vdrawing ? (ypos - vdrawing_start) % 11'd10 : 4'h0;

assign clk_load_char = (xpos >= hloading_start)
                    && (xpos < hloading_end)
						  && (((xpos - hloading_start) & 7) == 0);

assign clk_load_design = (xpos >= hloading_start + 2)
                      && (xpos < hloading_end + 2)
					       && (((xpos - (hloading_start + 2)) & 7) == 0);

assign clk_draw_char = vdrawing && (xpos >= hdrawing_start - 1) && (xpos < hdrawing_end) && (xchar == 7);

endmodule
