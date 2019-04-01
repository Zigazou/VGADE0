//////////////////////////////////////////////////////////////////////
////                                                              ////
//// registerInterface.v                                          ////
////                                                              ////
//// This file is part of the i2cSlave opencores effort.
//// <http://www.opencores.org/cores//>                           ////
////                                                              ////
//// Module Description:                                          ////
//// You will need to modify this file to implement your 
//// interface.
//// Add your control and status bytes/bits to module inputs and outputs,
//// and also to the I2C read and write process blocks  
////                                                              ////
//// To Do:                                                       ////
//// 
////                                                              ////
//// Author(s):                                                   ////
//// - Steve Fielding, sfielding@base2designs.com                 ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2008 Steve Fielding and OPENCORES.ORG          ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 2.1 of the License, or (at your option) any   ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE. See the GNU Lesser General Public License for more  ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from <http://www.opencores.org/lgpl.shtml>                   ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
//
`include "constant.vh"
`include "i2c_slave.vh"

module i2c_slave_register (
	input clk,
	input [7:0] addr,
	input [7:0] dataIn,
	input writeEn,
	output reg [7:0] dataOut,

	output reg character_change,
	
	output reg [7:0] character,
	output reg [7:0] xtext,
	output reg [7:0] ytext,
	output reg [7:0] attribute1,
	output reg [7:0] attribute2
);

// --- I2C Read
always @(posedge clk)
	case (addr)
		8'h00: dataOut <= character;  
		8'h01: dataOut <= xtext;
		8'h02: dataOut <= ytext;
		8'h03: dataOut <= attribute1;
		8'h04: dataOut <= attribute2;
		default: dataOut <= 8'h00;
	endcase

// --- I2C Write
always @(posedge clk)
	if (writeEn) begin
		if (character_change) begin
			character_change <= `FALSE;

			xtext <= xtext + 1;
			if (xtext >= `TEXTCOLS_CHAR) begin
				xtext <= 0;
				ytext <= ytext + 1;
				if (ytext >= `TEXTROWS_CHAR) ytext <= 0;
			end
		end

		case (addr)
			8'h00: begin
				character_change <= `TRUE;
				character <= dataIn;
			end

			8'h01: xtext <= dataIn;
			8'h02: ytext <= dataIn;
			8'h03: attribute1 <= dataIn;
			8'h04: attribute2 <= dataIn;
		endcase
	end

endmodule
