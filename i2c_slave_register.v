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

	input busy,
	output reg execute,
	output reg [47:0] command
);

reg [7:0] _character;
reg [7:0] _xtext;
reg [7:0] _ytext;
reg [7:0] _attribute1;
reg [7:0] _attribute2;

reg [7:0] _mask_char;
reg [7:0] _mask_attr1;
reg [7:0] _mask_attr2;

// --- I2C Read
always @(posedge clk)
	case (addr)
		`I2C_CHARACTER: dataOut <= _character;
		`I2C_XTEXT: dataOut <= _xtext;
		`I2C_YTEXT: dataOut <= _ytext;
		`I2C_ATTRIBUTE1: dataOut <= _attribute1;
		`I2C_ATTRIBUTE2: dataOut <= _attribute2;
		`I2C_MASK_CHAR: dataOut <= _mask_char;
		`I2C_MASK_ATTR1: dataOut <= _mask_attr1;
		`I2C_MASK_ATTR2: dataOut <= _mask_attr2;
		default: dataOut <= 8'h00;
	endcase

// --- I2C Write
always @(posedge clk)
	if (writeEn & ~busy) begin
		case (addr)
			// Set register value.
			`I2C_CHARACTER: _character <= dataIn;
			`I2C_XTEXT: _xtext <= dataIn;
			`I2C_YTEXT: _ytext <= dataIn;
			`I2C_ATTRIBUTE1: _attribute1 <= dataIn;
			`I2C_ATTRIBUTE2: _attribute2 <= dataIn;
			`I2C_MASK_CHAR: _mask_char <= dataIn;
			`I2C_MASK_ATTR1: _mask_attr1 <= dataIn;
			`I2C_MASK_ATTR2: _mask_attr2 <= dataIn;

			// Run command.
			`I2C_CLEARSCREEN: command <= { 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, `TPU_CLEARSCREEN };
			`I2C_PRINT: command <= { 8'h00, 8'h00, 8'h00, 8'h00, _character, `TPU_PRINT };
			`I2C_LOCATE: command <= { 8'h00, 8'h00, 8'h00, _ytext, _xtext, `TPU_LOCATE };
			`I2C_SETATTR: command <= { 8'h00, 8'h00, 8'h00, _attribute2, _attribute1, `TPU_SETATTR };
			`I2C_SETMASK: command <= { 8'h00, 8'h00, _mask_attr2, _mask_attr1, _mask_char, `TPU_SETMASK };
		endcase

		// If it is a command, it must be executed.
		if (addr >= 8'h80) execute <= `TRUE;
	end else
		execute <= `FALSE;

endmodule
