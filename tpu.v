`timescale 1 ns / 100 ps
`include "constant.vh"
module tpu (
	input wire clk,
	input wire reset,

	// Command input.
	input wire execute,
	input wire [47:0] command,

	// Module availability.
	output reg busy,

	// Connection with video memory.
	output reg video_write,
	output reg [15:0] video_address,
	output reg [`CHARATTR_RANGE] video_value,
	output reg [`CHARATTR_RANGE] video_mask
);

// Define all automaton states.
localparam
	// Read command.
	readcommand = 0,

	// Clear screen.
	clearscreen_init = 1,
	clearscreen_iteration = 2,

	// Print character.
	printchar_init = 3,

	printchar_standard = 4,
	printchar_standard_end = 5,

	printchar_double_width_left = 6,
	printchar_double_width_right = 7,
	printchar_double_width_end = 8,

	printchar_double_height_top = 9,
	printchar_double_height_bottom = 10,
	printchar_double_height_end = 11,

	printchar_double_top_left = 12,
	printchar_double_top_right = 13,
	printchar_double_bottom_left = 14,
	printchar_double_bottom_right = 15,
	printchar_double_end = 16,

	// Locate.
	locate = 17,

	// Set attributes.
	set_attributes = 18,

	// Set mask.
	set_mask = 19,

	// Fill area.
	fillarea_init = 20,
	fillarea_xloop = 21,
	fillarea_yloop = 22,
	fillarea_end = 23;

// Current state.
reg [7:0] xtext;
reg [7:0] xtext_start;
reg [7:0] ytext;
reg [7:0] xtext_end;
reg [7:0] ytext_end;
reg [2:0] foreground;
reg [2:0] background;
reg blink;
reg halftone;
reg underline;
reg invert;
reg [1:0] size;
reg [1:0] page;

// Current automaton state.
reg [7:0] tpu_state;

initial begin
	tpu_state <= 0;
	busy <= `FALSE;
	video_write <= `FALSE;
	video_value <= 24'h000000;
	video_mask <= 24'hFFFFFF;
	xtext <= 8'b0;
	xtext_start <= 8'b0;
	ytext <= 8'b0;
	size <= 2'b00;
	page <= 2'b00;
	foreground <= 3'd7;
	background <= 3'd0;
	blink <= `FALSE;
	halftone <= `FALSE;
	underline <= `FALSE;
	invert <= `FALSE;
end

always @(posedge clk)
	if (reset) begin
		video_write <= `FALSE;
		video_address <= 0;
		video_value <= 24'h000000;
		video_mask <= 24'hFFFFFF;

		xtext <= 0;
		ytext <= 0;
		xtext_end <= 0;
		ytext_end <= 0;
		foreground <= 7;
		background <= 0;
		blink <= `FALSE;
		halftone <= `FALSE;
		underline <= `FALSE;
		invert <= `FALSE;

		tpu_state <= readcommand;
		busy <= `FALSE;
	end else
		case (tpu_state)
			readcommand:
				if (execute) begin
					busy <= `TRUE;
					case (command[7:0])
						`TPU_CLEARSCREEN: tpu_state <= clearscreen_init;
						`TPU_PRINT: tpu_state <= printchar_init;
						`TPU_LOCATE: tpu_state <= locate;
						`TPU_SETATTR: tpu_state <= set_attributes;
						`TPU_SETMASK: tpu_state <= set_mask;
						`TPU_FILLAREA: tpu_state <= fillarea_init;
						default: begin
							busy <= `FALSE;
							tpu_state <= readcommand;
						end
					endcase
				end

			// ------------------------------------------------------------------
			// Clear screen and reset values
			// ------------------------------------------------------------------
			clearscreen_init: begin
				video_write <= `TRUE;
				video_address <= 16'h0000;
				video_value <= { 8'h07, 8'h00, 8'h20 };

				// Reset registers.
				xtext <= 8'h00;
				ytext <= 8'h00;
				size <= 2'b00;
				page <= 2'b00;
				foreground <= 3'd7;
				background <= 3'd0;
				blink <= `FALSE;
				halftone <= `FALSE;
				underline <= `FALSE;
				invert <= `FALSE;
				video_mask <= 24'hFFFFFF;

				tpu_state <= clearscreen_iteration;
			end

			clearscreen_iteration:
				if (video_address == (16'd`TEXT_TOTAL - 1)) begin
					video_address <= 16'h0000;
					video_write <= `FALSE;
					busy <= `FALSE;
					tpu_state <= readcommand;
				end else begin
					video_address <= video_address + 16'h0001;
				end

			// ------------------------------------------------------------------
			// Print character
			// ------------------------------------------------------------------
			printchar_init: begin
				video_address <= xtext + ytext * 16'd`TEXTCOLS_CHAR;
				case (size)
					2'b00: tpu_state <= printchar_standard;
					2'b01: tpu_state <= printchar_double_width_left;
					2'b10: tpu_state <= printchar_double_height_top;
					2'b11: tpu_state <= printchar_double_top_left;
					default: tpu_state <= readcommand;
				endcase
			end

			// ------------------------------------------------------------------
			// Print standard size
			// ------------------------------------------------------------------
			printchar_standard: begin
				video_write <= `TRUE;
				video_value <= {
					invert,
					underline,
					background,
					foreground,
					blink,
					2'b00,
					size,
					halftone,
					page,
					command[15:8]
				};
				tpu_state <= printchar_standard_end;
			end

			printchar_standard_end: begin
				video_write <= `FALSE;
				if (xtext == `TEXTCOLS_CHAR - 1) begin
					xtext <= 0;
					if (ytext == `TEXTROWS_CHAR - 1)
						ytext <= 0;
					else
						ytext <= ytext + 8'h01;
				end else
					xtext <= xtext + 8'h01;

				tpu_state <= readcommand;
				busy <= `FALSE;
			end

			// ------------------------------------------------------------------
			// Print double width
			// ------------------------------------------------------------------
			printchar_double_width_left: begin
				video_write <= `TRUE;
				video_value <= {
					invert,
					underline,
					background,
					foreground,
					blink,
					2'b00,
					size,
					halftone,
					page,
					command[15:8]
				};
				tpu_state <= printchar_double_width_right;
			end

			printchar_double_width_right: begin
				video_address <= video_address + 16'h0001;
				xtext <= xtext + 8'h01;
				video_value <= {
					invert,
					underline,
					background,
					foreground,
					blink,
					2'b01,
					size,
					halftone,
					page,
					command[15:8]
				};
				tpu_state <= printchar_double_width_end;
			end

			printchar_double_width_end: begin
				busy <= `FALSE;
				video_address <= video_address + 16'h0001;
				xtext <= xtext + 8'h01;
				video_write <= `FALSE;
				tpu_state <= readcommand;
			end

			// ------------------------------------------------------------------
			// Print double height
			// ------------------------------------------------------------------
			printchar_double_height_top: begin
				video_write <= `TRUE;
				video_value <= {
					invert,
					underline,
					background,
					foreground,
					blink,
					2'b00,
					size,
					halftone,
					page,
					command[15:8]
				};
				tpu_state <= printchar_double_height_bottom;
			end

			printchar_double_height_bottom: begin
				video_address <= video_address + 16'd`TEXTCOLS_CHAR;
				ytext <= ytext + 8'h01;
				video_value <= {
					invert,
					underline,
					background,
					foreground,
					blink,
					2'b10,
					size,
					halftone,
					page,
					command[15:8]
				};
				tpu_state <= printchar_double_height_end;
			end

			printchar_double_height_end: begin
				busy <= `FALSE;
				video_address <= video_address - (16'd`TEXTCOLS_CHAR - 16'h0001);
				xtext <= xtext + 8'h01;
				ytext <= ytext - 8'h01;
				video_write <= `FALSE;
				tpu_state <= readcommand;
			end

			// ------------------------------------------------------------------
			// Print double size
			// ------------------------------------------------------------------
			printchar_double_top_left: begin
				video_write <= `TRUE;
				video_value <= {
					invert,
					underline,
					background,
					foreground,
					blink,
					2'b00,
					size,
					halftone,
					page,
					command[15:8]
				};
				tpu_state <= printchar_double_top_right;
			end

			printchar_double_top_right: begin
				video_address <= video_address + 16'h0001;
				xtext <= xtext + 8'h01;
				video_value <= {
					invert,
					underline,
					background,
					foreground,
					blink,
					2'b01,
					size,
					halftone,
					page,
					command[15:8]
				};
				tpu_state <= printchar_double_bottom_left;
			end

			printchar_double_bottom_left: begin
				video_address <= video_address + (16'd`TEXTCOLS_CHAR - 16'h0001);
				xtext <= xtext - 8'h01;
				ytext <= ytext + 8'h01;
				video_value <= {
					invert,
					underline,
					background,
					foreground,
					blink,
					2'b10,
					size,
					halftone,
					page,
					command[15:8]
				};
				tpu_state <= printchar_double_bottom_right;
			end
				
			printchar_double_bottom_right: begin
				video_address <= video_address + 16'h0001;
				xtext <= xtext + 8'h01;
				video_value <= {
					invert,
					underline,
					background,
					foreground,
					blink,
					2'b11,
					size,
					halftone,
					page,
					command[15:8]
				};
				tpu_state <= printchar_double_end;
			end

			printchar_double_end: begin
				busy <= `FALSE;
				video_address <= video_address - (16'd`TEXTCOLS_CHAR - 16'h0001);
				xtext <= xtext + 8'h01;
				ytext <= ytext - 8'h01;
				video_write <= `FALSE;
				tpu_state <= readcommand;
			end

			// ------------------------------------------------------------------
			// Locate
			// ------------------------------------------------------------------
			locate: begin
				xtext <= command[15:8];
				ytext <= command[23:16];

				busy <= `FALSE;
				tpu_state <= readcommand;
			end

			// ------------------------------------------------------------------
			// Set attributes
			// ------------------------------------------------------------------
			set_attributes: begin
				// Attributes 1
				page <= command[9:8];
				halftone <= command[10];
				size <= command[12:11];
				// The part is ignored.
				blink <= command[15];

				// Attributes 2
				foreground <= command[18:16];
				background <= command[21:19];
				underline <= command[22];
				invert <= command[23];

				busy <= `FALSE;
				tpu_state <= readcommand;
			end

			// ------------------------------------------------------------------
			// Set mask
			// ------------------------------------------------------------------
			set_mask: begin
				video_mask <= command[31:8];

				busy <= `FALSE;
				tpu_state <= readcommand;
			end

			// ------------------------------------------------------------------
			// Fill area
			// ------------------------------------------------------------------
			fillarea_init: begin
				if (xtext > command[15:8] || ytext > command[23:16]) begin
					// Ignore command if starting point is after ending point.
					busy <= `FALSE;
					video_write <= `FALSE;
					tpu_state <= readcommand;
				end else begin
					video_address <= xtext + ytext * 16'd`TEXTCOLS_CHAR;
					xtext_end <= command[15:8];
					ytext_end <= command[23:16];
					video_value <= {
						invert,
						underline,
						background,
						foreground,
						blink,
						2'b00,
						size,
						halftone,
						page,
						command[31:24]
					};
					xtext_start <= xtext;
					video_write <= `TRUE;
					tpu_state <= fillarea_xloop;
				end
			end

			fillarea_xloop: begin
				if (xtext == xtext_end)
					tpu_state <= fillarea_yloop;
				else begin
					xtext <= xtext + 8'h01;
					video_address <= video_address + 8'h01;
					tpu_state <= fillarea_xloop;
				end
			end

			fillarea_yloop: begin
				if (ytext == ytext_end)
					tpu_state <= fillarea_end;
				else begin
					video_address <= xtext_start + (ytext + 8'h01) * 16'd`TEXTCOLS_CHAR;
					xtext <= xtext_start;
					ytext <= ytext + 8'h01;
					tpu_state <= fillarea_xloop;
				end
				
			end
			
			fillarea_end: begin
				busy <= `FALSE;
				video_write <= `FALSE;
				tpu_state <= readcommand;
			end

			// ------------------------------------------------------------------
			// Default action is to reset state.
			// ------------------------------------------------------------------
			default: begin
				video_write <= `FALSE;
				video_address <= 0;
				video_value <= 24'h000000;
				video_mask <= 24'hFFFFFF;

				xtext <= 0;
				xtext_start <= 0;
				ytext <= 0;
				xtext_end <= 0;
				ytext_end <= 0;
				foreground <= 7;
				background <= 0;
				blink <= `FALSE;
				halftone <= `FALSE;
				underline <= `FALSE;
				invert <= `FALSE;

				tpu_state <= readcommand;
				busy <= `FALSE;
			end
		endcase
endmodule