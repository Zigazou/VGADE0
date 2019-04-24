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

	output wire [`TEXTCOLS_RANGE] xtext,
	output wire [`TEXTROWS_RANGE] ytext,

	output wire drawing
);

// Horizontal timing in pixels (line)
// http://www.tinyvga.com/vga-timing/800x600@72Hz
parameter line_visible_area = `COORDINATE_WIDTH'd800;
parameter line_front_porch  = `COORDINATE_WIDTH'd56;
parameter line_sync_pulse   = `COORDINATE_WIDTH'd120;
parameter line_back_porch   = `COORDINATE_WIDTH'd64;

// Vertical timing in lines (frame)
// http://www.tinyvga.com/vga-timing/800x600@72Hz
parameter frame_visible_area = `COORDINATE_WIDTH'd600;
parameter frame_front_porch  = `COORDINATE_WIDTH'd37;
parameter frame_sync_pulse   = `COORDINATE_WIDTH'd6;
parameter frame_back_porch   = `COORDINATE_WIDTH'd23;

// Start and end of the horizontal sync (in pixels)
localparam hsync_start = line_back_porch
                       + line_visible_area
							  + line_front_porch;

localparam hsync_end = hsync_start + line_sync_pulse;

// Start and end of the horizontal drawing
localparam hdrawing_start = line_back_porch;
localparam hdrawing_end   = hdrawing_start + line_visible_area;

// Start and end of the horizontal loading
localparam hloading_start = hdrawing_start - 7;
localparam hloading_end   = hdrawing_end - 7;

// Start and end of the vertical sync (in lines)
localparam vsync_start = frame_back_porch
                       + frame_visible_area
							  + frame_front_porch;

localparam vsync_end = vsync_start + frame_sync_pulse;

// Start and end of the vertical drawing
localparam vdrawing_start = frame_back_porch;
localparam vdrawing_end   = vdrawing_start + frame_visible_area;

initial begin
	xpos <= 0;
	ypos <= 0;
end

// Connect wires to the registers
always @(posedge clk or posedge reset)
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

wire hdrawing;
assign hdrawing = !reset
					&& (xpos >= hdrawing_start - 4)
					&& (xpos < hdrawing_end);

wire hloading;
assign hloading = !reset
					&& (xpos >= hloading_start)
					&& (xpos < hloading_end);

wire vdrawing;
assign vdrawing = !reset
					&& (ypos >= vdrawing_start)
					&& (ypos < vdrawing_end);

assign drawing = hdrawing && vdrawing;

wire loading;
assign loading = hloading && vdrawing;

assign vsync = reset || (ypos < vsync_start);
assign hsync = reset || (xpos < hsync_start);

assign xtext = loading ? (xpos - hloading_start) / 8 : 0;
assign xchar = drawing ? (xpos - hdrawing_start) & 7 : 0;

assign ytext = vdrawing ? (ypos - vdrawing_start) / 10 : 0;
assign ychar = drawing ? (ypos - vdrawing_start) % 10 : 0;

assign clk_load_char = (xpos >= hloading_start)
                    && (xpos < hloading_end)
						  && (((xpos - hloading_start) % 8) == 0);

assign clk_load_design = (xpos >= hloading_start + 4)
                      && (xpos < hloading_end + 4)
					       && (((xpos - (hloading_start + 4)) % 8) == 0);

assign clk_draw_char = drawing && (xchar == 0);

endmodule
