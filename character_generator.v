`include "constant.vh"
module character_generator (
	input clk_load_design,

	input [`CHARHEIGHT_RANGE] ychar,

	input [`CHARINDEX_RANGE] character_index,

	input xsize,
	input ysize,

	input xpart,
	input ypart,

	input halftone,
	input underline,
	input invert,

	output reg [7:0] row_pixels
);

reg [79:0] character_design[`CHARS_AVAILABLE];
initial $readmemb("data/extended_videotex.txt", character_design);

wire draw_underline;
assign draw_underline = underline & (ychar == 4'd9);

reg [7:0] _row_pixels;
reg [7:0] _scale_pixels;
reg [7:0] row_select;
reg [7:0] mask;

always @(clk_load_design)
	if (draw_underline)
		_scale_pixels <= 8'b11111111;
	else begin
		// Compute mask for halftone function.
		case ({ halftone, ychar[0] })
			2'b00: mask = 8'b1111_1111;
			2'b01: mask = 8'b1111_1111;
			2'b10: mask = 8'b1010_1010;
			2'b11: mask = 8'b0101_0101;
		endcase

		// Compute vertical zoom.
		case ({ ypart, ysize })
			2'b00: row_select = ychar;
			2'b10: row_select = ychar;
			2'b01: row_select = { ychar[3], ychar[2], ychar[1] };
			2'b11: row_select = 8'd5 + { ychar[3], ychar[2], ychar[1] };
		endcase

		// Retrieve the design of the selected row.
		_row_pixels = character_design[character_index] >> { row_select, 1'b0, 1'b0, 1'b0 };

		// Compute horizontal zoom.
		case ({ xpart, xsize })
			// Standard width.
			2'b00: _scale_pixels = {
				_row_pixels[0],
				_row_pixels[1],
				_row_pixels[2],
				_row_pixels[3],
				_row_pixels[4],
				_row_pixels[5],
				_row_pixels[6],
				_row_pixels[7]
			};

			// Standard width (ignore illegal use of the part bit).
			2'b10: _scale_pixels = {
				_row_pixels[0],
				_row_pixels[1],
				_row_pixels[2],
				_row_pixels[3],
				_row_pixels[4],
				_row_pixels[5],
				_row_pixels[6],
				_row_pixels[7]
			};

			// Double width, left part.
			2'b01: _scale_pixels = {
				_row_pixels[4],
				_row_pixels[4],
				_row_pixels[5],
				_row_pixels[5],
				_row_pixels[6],
				_row_pixels[6],
				_row_pixels[7],
				_row_pixels[7]
			};

			// Double width, right part.
			2'b11: _scale_pixels = {
				_row_pixels[0],
				_row_pixels[0],
				_row_pixels[1],
				_row_pixels[1],
				_row_pixels[2],
				_row_pixels[2],
				_row_pixels[3],
				_row_pixels[3]
			};
		endcase
		
		row_pixels <= (invert ? ~_scale_pixels : _scale_pixels) & mask;
	end

endmodule
