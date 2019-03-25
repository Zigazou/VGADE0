// Generate timing for a standard 800x600@72 VGA screen
// clk must be 50 MHz
`include "constant.vh"
module vga_timing_800_600_72 (
	input wire clk,
	input wire reset,

	output wire hsync,
	output wire vsync,
	output reg [`COORDINATE_RANGE] xpos,
	output reg [`COORDINATE_RANGE] ypos,

	output wire [`COORDINATE_RANGE] xdraw,
	output wire [`COORDINATE_RANGE] ydraw,

	output wire [`CHARWIDTH_RANGE] xchar,
	output reg [`CHARHEIGHT_RANGE] ychar,

	output wire [`TEXTCOLS_RANGE] xtext,
	output reg [`TEXTROWS_RANGE] ytext,
	
	output wire drawing
);

// Horizontal timing in pixels (line)
// http://www.tinyvga.com/vga-timing/800x600@72Hz
localparam line_visible_area = `COORDINATE_WIDTH'd800;
localparam line_front_porch  = `COORDINATE_WIDTH'd56;
localparam line_sync_pulse   = `COORDINATE_WIDTH'd120;
localparam line_back_porch   = `COORDINATE_WIDTH'd64;

// Vertical timing in lines (frame)
// http://www.tinyvga.com/vga-timing/800x600@72Hz
localparam frame_visible_area = `COORDINATE_WIDTH'd600;
localparam frame_front_porch  = `COORDINATE_WIDTH'd37;
localparam frame_sync_pulse   = `COORDINATE_WIDTH'd6;
localparam frame_back_porch   = `COORDINATE_WIDTH'd23;

// Start and end of the horizontal sync (in pixels)
localparam hsync_start = line_front_porch
                       + line_visible_area
							  + line_back_porch;

localparam hsync_end = hsync_start + line_sync_pulse;

// Start and end of the horizontal drawing
localparam hdrawing_start = line_front_porch;
localparam hdrawing_end   = hdrawing_start + line_visible_area;

// Start and end of the vertical sync (in lines)
localparam vsync_start = frame_front_porch
                       + frame_visible_area
							  + frame_back_porch;

localparam vsync_end = vsync_start + frame_sync_pulse;

// Start and end of the vertical drawing
localparam vdrawing_start = frame_front_porch;
localparam vdrawing_end   = vdrawing_start + frame_visible_area;

wire hdrawing;
wire vdrawing;

initial begin
	xpos = 0;
	ypos = 0;
	ychar = 0;
end

// Connect wires to the registers

// Reset and increments need to be handled in the
// same process block since they update the same registers.
always @(posedge clk or posedge reset)
	if (reset) begin
		xpos <= 0;
		ypos <= 0;
	end else begin
		xpos <= xpos + 11'd1;

		// Horizontal move of the beam
		if (xpos == hsync_end) begin
			xpos <= 0;
			ypos <= ypos + 11'd1;
			if (ypos == vsync_end) ypos <= 0;
		end
	end

assign hdrawing = (xpos >= hdrawing_start) & (xpos < hdrawing_end);
assign vdrawing = (ypos >= vdrawing_start) & (ypos < vdrawing_end);
assign drawing = hdrawing & vdrawing;

assign xdraw = drawing ? (xpos - hdrawing_start) : 11'd0;
assign ydraw = drawing ? (ypos - vdrawing_start) : 11'd0;

assign vsync = reset | (ypos < vsync_start);
assign hsync = reset | (xpos < hsync_start);

assign xchar = xdraw[`CHARWIDTH_RANGE];
assign xtext = xdraw[`COORDINATE_WIDTH - 2:3];

always @(posedge clk or posedge reset)
	if (reset) begin
		ychar <= 0;
		ytext <= 0;
	end else
		if (xpos == 0 & vdrawing) begin
			ychar <= ychar + 4'd1;
			if (ychar == `CHARHEIGHT_PIXELS - 1) begin
				ychar <= 0;
				ytext <= ytext + 6'd1;
			end
		end else
			if (~vdrawing) ytext <= 0;

endmodule
