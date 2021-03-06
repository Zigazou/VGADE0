`include "constant.vh"
module character_generator (
	input clk,
	input clk_load_design,

	input [`CHARHEIGHT_RANGE] ychar,

	input [`CHARINDEX_RANGE] charindex,

	input xsize,
	input ysize,

	input xpart,
	input ypart,

	input underline,

	output reg [7:0] pixels
);

reg [79:0] chardesign[`CHARS_AVAILABLE];
initial $readmemb("data/extended_videotex.txt", chardesign);

reg [7:0] line;
reg [7:0] scaled;
reg [7:0] row_index;

reg [2:0] state = 0;

`define CG_WAIT_FOR_LOAD_DESIGN 0
`define CG_VERTICAL_ZOOM 1
`define CG_GET_DESIGN 2
`define CG_HORIZONTAL_ZOOM 3

always @(posedge clk)
	case (state)
		// Wait until a load design triggers.
		`CG_WAIT_FOR_LOAD_DESIGN: begin
			if (clk_load_design)
				state <= `CG_VERTICAL_ZOOM;
			else
				state <= `CG_WAIT_FOR_LOAD_DESIGN;
		end

		`CG_VERTICAL_ZOOM: begin
			// Compute vertical zoom.
			case ({ ypart, ysize })
				// Standard height.
				2'b00: row_index <= ychar;

				// Standard height with invalid ypart.
				2'b10: row_index <= ychar;

				// Double height, top part.
				2'b01: row_index <= { ychar[3], ychar[2], ychar[1] };

				// Double height, bottom part.
				2'b11: row_index <= 8'd5 + { ychar[3], ychar[2], ychar[1] };

				default: row_index <= 8'bxxxx_xxxx;
			endcase
			state <= `CG_GET_DESIGN;
		end

		`CG_GET_DESIGN: begin
			if (underline && row_index == 4'd9)
				// Ignore the design and draw a line.
				line <= 8'b11111111;
			else
				// Retrieve the design of the selected row.
				line <= chardesign[charindex] >> { row_index, 3'b000 };

			state <= `CG_HORIZONTAL_ZOOM;
		end

		`CG_HORIZONTAL_ZOOM: begin
			// Compute horizontal zoom.
			case ({ xpart, xsize })
				// Standard width.
				2'b00: pixels <= {
					line[0], line[1], line[2], line[3],
					line[4], line[5], line[6], line[7]
				};

				// Standard width (ignore illegal use of the part bit).
				2'b10: pixels <= {
					line[0], line[1], line[2], line[3],
					line[4], line[5], line[6], line[7]
				};

				// Double width, left part.
				2'b01: pixels <= {
					line[4], line[4], line[5], line[5],
					line[6], line[6], line[7], line[7]
				};

				// Double width, right part.
				2'b11: pixels <= {
					line[0], line[0], line[1], line[1],
					line[2], line[2], line[3], line[3]
				};

				default: scaled <= 8'bxxxx_xxxx;
			endcase

			state <= `CG_WAIT_FOR_LOAD_DESIGN;
		end
	endcase
endmodule
