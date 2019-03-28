`include "constant.vh"
module character_generator (
	input clk,

	input [`CHARWIDTH_RANGE] xchar,
	input [`CHARHEIGHT_RANGE] ychar,

	input [`CHARINDEX_RANGE] character_index,

	input underline,
	input invert,
	
	output wire pixel
);

reg [`CHARROW_RANGE] character_design[`CHARS_AVAILABLE * `CHARHEIGHT_PIXELS];
initial $readmemb("data/extended_videotex.txt", character_design);

wire [`CHARMEM_RANGE] char_start;
assign char_start = character_index * `CHARMEM_WIDTH'd`CHARHEIGHT_PIXELS + ychar;

reg [7:0] mask;
always @(posedge clk)
	case (xchar)
		3'd0: mask <= 128;
		3'd1: mask <= 64;
		3'd2: mask <= 32;
		3'd3: mask <= 16;
		3'd4: mask <= 8;
		3'd5: mask <= 4;
		3'd6: mask <= 2;
		3'd7: mask <= 1;
	endcase

wire draw_underline;
wire draw_pixel;
assign draw_underline = underline & (ychar == 4'd9);
assign draw_pixel = (character_design[char_start] & mask) != `CHARWIDTH_PIXELS'd0;

assign pixel = (draw_underline | draw_pixel) ^ invert;

endmodule
