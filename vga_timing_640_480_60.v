// Generate timing for a standard 640x480@60 VGA screen
// clk must be 25 MHz
`include "constant.vh"
module vga_timing_640_480_60 (
	input wire clk,
	input wire reset,

	output wire hsync,
	output wire vsync,
	output wire [`COORDINATE_RANGE] xpos,
	output wire [`COORDINATE_RANGE] ypos,
	output wire drawing
);

// Horizontal timing in pixels (line)
// http://www.tinyvga.com/vga-timing/640x480@60Hz
localparam line_visible_area = 640;
localparam line_front_porch  = 16;
localparam line_sync_pulse   = 96;
localparam line_back_porch   = 48;

// Vertical timing in lines (frame)
// http://www.tinyvga.com/vga-timing/640x480@60Hz
localparam frame_visible_area = 480;
localparam frame_front_porch  = 10;
localparam frame_sync_pulse   = 2;
localparam frame_back_porch   = 33;

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

// Internal registers
reg [`COORDINATE_RANGE] _xpos = 0;
reg [`COORDINATE_RANGE] _ypos = 0;
reg _hsync = `INACTIVE_HSYNC;
reg _vsync = `INACTIVE_VSYNC;
reg _hdrawing = `FALSE;
reg _vdrawing = `FALSE;

// Connect wires to the registers
assign hsync = _hsync;
assign vsync = _vsync;
assign xpos  = _xpos;
assign ypos  = _ypos;
assign drawing = _hdrawing & _vdrawing;

// Reset and increments need to be handled in the
// same process block since they update the same registers.
always @(posedge clk or posedge reset)
begin
	// Reset was asked, reset our custom clock.
	if (reset) begin
		_xpos <= 0;
		_ypos <= 0;
		_hsync <= `INACTIVE_HSYNC;
		_vsync <= `INACTIVE_VSYNC;
	end else begin
		_xpos <= _xpos + 1'b1;

		// Horizontal move of the beam
		case (_xpos)
			hdrawing_start: _hdrawing <= `TRUE;
			hdrawing_end: _hdrawing <= `FALSE;
			hsync_start: _hsync <= `ACTIVE_HSYNC;
			hsync_end: begin
				_hsync <= `INACTIVE_HSYNC;
				_xpos <= 0;
				_ypos <= _ypos + 1'b1;
			end
		endcase

		// Vertical move of the beam
		if (_xpos == 0)
			case (_ypos)
				vdrawing_start: _vdrawing <= `TRUE;
				vdrawing_end: _vdrawing <= `FALSE;
				vsync_start: _vsync <= `ACTIVE_VSYNC;
				vsync_end: begin
					_vsync <= `INACTIVE_VSYNC;
					_ypos <= 1'b0;
				end
			endcase
	end
end

endmodule
