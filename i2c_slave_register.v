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
	output reg [7:0] xtext,
	output reg [7:0] ytext,
	output reg [`CHARATTR_RANGE] charattr
);

reg [7:0] _character;
reg [7:0] _xtext;
reg [7:0] _ytext;
reg [7:0] _attribute1;
reg [7:0] _attribute2;

// --- I2C Read
always @(posedge clk)
	case (addr)
		8'h00: dataOut <= _character;
		8'h01: dataOut <= _xtext;
		8'h02: dataOut <= _ytext;
		8'h03: dataOut <= _attribute1;
		8'h04: dataOut <= _attribute2;
		default: dataOut <= 8'h00;
	endcase

// --- I2C Write

always @(posedge clk) begin
	if (writeEn)
		case (addr)
			8'h00: begin
				_character <= dataIn;
				xtext <= _xtext;
				ytext <= _ytext;
				charattr <= { _attribute2, _attribute1, _character };
				character_change <= `TRUE;

				if (_xtext == `TEXTCOLS_CHAR - 1) begin
					_xtext <= 0;
					if (_ytext == `TEXTROWS_CHAR - 1)
						_ytext <= 0;
					else
						_ytext <= _ytext + 1;
				end else
					_xtext <= _xtext + 1;

				character_change <= `FALSE;
			end

			8'h01: _xtext <= dataIn;
			8'h02: _ytext <= dataIn;
			8'h03: _attribute1 <= dataIn;
			8'h04: _attribute2 <= dataIn;
		endcase
end

endmodule
