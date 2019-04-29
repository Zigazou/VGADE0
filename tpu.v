// Text Processing Unit
`include "constant.vh"
`include "tpu.vh"

module tpu (
	input wire clk,
	input wire reset,

	input wire write,
	
	output reg memupdate,
);

reg [TPUSTATES_RANGE] state;
reg 

always @(posedge clk or posedge write)
	if (reset) begin
		memupdate <= `FALSE;
	end else
		case (state)
			`STA_READCOMMAND:
				if ()
				

				xtext <= _xtext;
				ytext <= _ytext;
				_character = dataIn;
				charattr = { _attribute2, _attribute1, _character };

				if (_xtext == `TEXTCOLS_CHAR - 1) begin
					_xtext <= 0;
					if (_ytext == `TEXTROWS_CHAR - 1)
						_ytext <= 0;
					else
						_ytext <= _ytext + 1;
				end else
					_xtext <= _xtext + 1;
		
		
endmodule
