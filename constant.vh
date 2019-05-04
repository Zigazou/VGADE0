`ifndef VGATEST_CONSTANT
`define VGATEST_CONSTANT

// Generic logical values
`define FALSE					1'b0
`define TRUE					1'b1

// Generic signal values
`define LOW						1'b0
`define HIGH					1'b1

// Generic bit ranges
`define BIT0					0:0
`define BIT1					1:1
`define BIT2					2:2
`define BIT3					3:3
`define BIT4					4:4
`define BIT5					5:5
`define BIT6					6:6
`define BIT7					7:7

// Coordinate width and range
`define COORDINATE_WIDTH	11
`define COORDINATE_RANGE	10:0

// Sync is active when signal is low, inactive when signal is high
`define ACTIVE_HSYNC			1'b0
`define INACTIVE_HSYNC		1'b1

`define ACTIVE_VSYNC			1'b0
`define INACTIVE_VSYNC		1'b1

// Character width and range
`define CHARWIDTH_PIXELS	8
`define CHARWIDTH_WIDTH    3
`define CHARWIDTH_RANGE		2:0

// Character height
`define CHARHEIGHT_PIXELS	10
`define CHARHEIGHT_WIDTH   4
`define CHARHEIGHT_RANGE	3:0

// Character index width and range
`define CHARINDEX_WIDTH		10
`define CHARINDEX_RANGE		9:0

// Character design
`define CHARROW_WIDTH		8
`define CHARROW_RANGE		7:0

`define CHARS_AVAILABLE		1024
`define CHARMEM_WIDTH		14
`define CHARMEM_RANGE		13:0

// Text grid
`define TEXTROWS_CHAR		60
`define TEXTROWS_WIDTH     6
`define TEXTROWS_RANGE		5:0

`define TEXTCOLS_CHAR		100
`define TEXTCOLS_WIDTH     7
`define TEXTCOLS_RANGE		6:0

`define VIDMEM_SIZE			(100 * 60 * 3)
`define VIDMEM_ADDR_BITS	15
`define VIDMEM_ADDR_RANGE	14:0

// Color width and range
`define COLOR_WIDTH			3
`define COLOR_RANGE			2:0

// Size/part width and range
`define SIZE_WIDTH			2
`define SIZE_RANGE			1:0
`define PART_WIDTH			2
`define PART_RANGE			1:0

// Video memory
`define VIDMEM_RANGE			12:0

// Character code/attribute width and range
`define CHARATTR_WIDTH		24
`define CHARATTR_RANGE		23:0

`define CHARATTR_INDEX		9:0
`define CHARATTR_HALFTONE	10:10
`define CHARATTR_SIZE		12:11
`define CHARATTR_SIZE_HORZ	11:11
`define CHARATTR_SIZE_VERT	12:12
`define CHARATTR_PART		14:13
`define CHARATTR_PART_HORZ	13:13
`define CHARATTR_PART_VERT	14:14
`define CHARATTR_BLINK		15:15

`define CHARATTR_FORE		18:16
`define CHARATTR_BACK		21:19
`define CHARATTR_UNDERLINE	22:22
`define CHARATTR_INVERT		23:23

// I2C addresses.
// Set register.
`define I2C_CHARACTER	8'h00
`define I2C_XTEXT			8'h01
`define I2C_YTEXT			8'h02
`define I2C_ATTRIBUTE1	8'h03
`define I2C_ATTRIBUTE2	8'h04
`define I2C_MASK_CHAR	8'h05
`define I2C_MASK_ATTR1	8'h06
`define I2C_MASK_ATTR2	8'h07

// Run command.
`define I2C_CLEARSCREEN	8'h80
`define I2C_PRINT			8'h81
`define I2C_LOCATE		8'h82
`define I2C_SETATTR		8'h83
`define I2C_SETMASK		8'h84

// TPU commands.
`define TPU_CLEARSCREEN 8'h01
`define TPU_PRINT 8'h02
`define TPU_LOCATE 8'h03
`define TPU_SETATTR 8'h04
`define TPU_SETMASK 8'h05

`endif