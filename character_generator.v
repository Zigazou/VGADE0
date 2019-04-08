`include "constant.vh"
module character_generator (
	input clk_load_char,

	input [`CHARHEIGHT_RANGE] ychar,

	input [`CHARINDEX_RANGE] character_index,

	input xsize,
	input ysize,

	input xpart,
	input ypart,

	input underline,
	input invert,

	output wire [7:0] row_pixels
);

reg [79:0] character_design[`CHARS_AVAILABLE];
initial $readmemb("data/extended_videotex.txt", character_design);

wire draw_underline;
assign draw_underline = underline & (ychar == 4'd9);

reg [7:0] _row_pixels;
reg [7:0] _scale_pixels;
always @(posedge clk_load_char)
	if (draw_underline)
		_scale_pixels <= 8'b11111111;
	else begin
		_row_pixels <= character_design[character_index] >> { ychar, 1'b0, 1'b0, 1'b0 };
		case ({ xpart, xsize })
			2'b00: _scale_pixels <= _row_pixels;
			2'b10: _scale_pixels <= _row_pixels;
			2'b01: _scale_pixels <= {
				_row_pixels[7],
				_row_pixels[7],
				_row_pixels[6],
				_row_pixels[6],
				_row_pixels[5],
				_row_pixels[5],
				_row_pixels[4],
				_row_pixels[4]
			};
			2'b11: _scale_pixels <= {
				_row_pixels[3],
				_row_pixels[3],
				_row_pixels[2],
				_row_pixels[2],
				_row_pixels[1],
				_row_pixels[1],
				_row_pixels[0],
				_row_pixels[0]
			};
		endcase
	end

assign row_pixels = invert ? ~_scale_pixels : _scale_pixels;

endmodule
