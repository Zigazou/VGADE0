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

// Read command.
localparam readcommand = 0;

// Clear screen.
localparam clearscreen_init = 1;
localparam clearscreen_iteration = 2;

// Print character.
localparam printchar_init = 3;

localparam printchar_standard = 4;
localparam printchar_standard_end = 5;

localparam printchar_double_width_left = 6;
localparam printchar_double_width_right = 7;
localparam printchar_double_width_end = 8;

localparam printchar_double_height_top = 9;
localparam printchar_double_height_bottom = 10;
localparam printchar_double_height_end = 11;

localparam printchar_double_top_left = 12;
localparam printchar_double_top_right = 13;
localparam printchar_double_bottom_left = 14;
localparam printchar_double_bottom_right = 15;
localparam printchar_double_end = 16;

localparam locate = 17;

localparam set_attributes = 18;

localparam set_mask = 19;

// Current state.
reg [7:0] xtext;
reg [7:0] ytext;
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
	video_value <= 24'h000;
	video_mask <= 24'hFFFFFF;
	xtext <= 8'b0;
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
		video_value <= 24'h000;
		video_mask <= 24'hFFFFFF;

		xtext <= 0;
		ytext <= 0;
		foreground <= 7;
		background <= 0;
		blink <= `FALSE;
		halftone <= `FALSE;
		underline <= `FALSE;
		invert <= `FALSE;

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
						default: begin
							busy <= `FALSE;
							tpu_state <= readcommand;
						end
					endcase
				end

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

				printchar_init: begin
					video_address <= xtext + ytext * 16'd`TEXTCOLS_CHAR;
					case (size)
						2'b00: tpu_state <= printchar_standard;
						2'b01: tpu_state <= printchar_double_width_left;
						2'b10: tpu_state <= printchar_double_height_top;
						2'b11: tpu_state <= printchar_double_top_left;
					endcase
				end

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
					if (xtext == `TEXCOLS_CHAR - 1) begin
						xtext <= 0;
						if (ytext == `TEXTROWS_CHAR - 1)
							ytext <= 0;
						else
							ytext <= ytext + 1;
					end else
						xtext <= xtext + 1;

					tpu_state <= readcommand;
					busy <= `FALSE;
				end

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
					video_address <= video_address + 1;
					xtext <= xtext + 1;
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
					video_address <= video_address + 1;
					xtext <= xtext + 1;
					video_write <= `FALSE;
					tpu_state <= readcommand;
				end

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
					ytext <= ytext + 1;
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
					video_address <= video_address - (16'd`TEXTCOLS_CHAR - 1);
					xtext <= xtext + 1;
					ytext <= ytext - 1;
					video_write <= `FALSE;
					tpu_state <= readcommand;
				end

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
					video_address <= video_address + 1;
					xtext <= xtext + 1;
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
					video_address <= video_address + (16'd`TEXTCOLS_CHAR - 1);
					xtext <= xtext - 1;
					ytext <= ytext + 1;
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
					video_address <= video_address + 16'd1;
					xtext <= xtext + 1;
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
					video_address <= video_address - (16'd`TEXTCOLS_CHAR - 1);
					xtext <= xtext + 1;
					ytext <= ytext - 1;
					video_write <= `FALSE;
					tpu_state <= readcommand;
				end

				locate: begin
					xtext <= command[15:8];
					ytext <= command[23:16];

					busy <= `FALSE;
					tpu_state <= readcommand;
				end

			set_attributes: begin
				size <= command[12:11];
				foreground <= command[18:16];
				background <= command[21:19];
				blink <= command[15];
				halftone <= command[10];
				underline <= command[22];
				invert <= command[23];
				size <= command[12:11];
				page <= command[9:8];

				busy <= `FALSE;
				tpu_state <= readcommand;
			end

			set_mask: begin
				video_mask <= command[31:8];

				busy <= `FALSE;
				tpu_state <= readcommand;
			end

	endcase
endmodule