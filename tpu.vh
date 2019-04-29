`ifndef TPU_CONSTANT
`define TPU_CONSTANT

// TPU commands
`define TPUCOMMANDS_RANGE	7:0

`define CMD_CLEARSCREEN		0
`define CMD_PRINTCHAR		1
`define CMD_SETMASK			2
`define CMD_SETATTRIBUTES	3
`define CMD_LOCATE			4
`define CMD_FILLAREA			5
`define CMD_COPYAREA			6

// TPU states
`define TPUSTATES_RANGE		7:0

`define STA_READCOMMAND 0

`endif