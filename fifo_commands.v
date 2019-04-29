`include "fifo_commands.vh"
module fifo (
	input wire clk,
	input wire reset,

	output wire empty,
	output wire full, 

	input wire read,
	input wire [`COMMAND_RANGE] data_in, 

	input wire write,
	output reg [`COMMAND_RANGE] data_out
); 

reg [`FIFO_RANGE] fifo_count;

reg [`COMMAND_RANGE] fifo_ram[`FIFO_LAST + 1];
reg [`FIFO_RANGE read_pointer;
reg [`FIFO_RANGE] write_pointer;

assign empty = fifo_count == 0;
assign full = fifo_count == `FIFO_LAST;

// Write
always @(posedge clk)
	if (write && !full)
		fifo_ram[write_pointer] <= data_in;
	else
		if(write && read)
			fifo_ram[write_pointer] <= data_in;

// Read
always @(posedge clk) 
	if (read && !empty)
		data_out <= fifo_ram[read_pointer];
	else
		if (read && write && empty) 
			data_out <= fifo_ram[read_pointer];

// Pointer
always @(posedge clk)
  if (reset) begin 
    write_pointer <= 0; 
    read_pointer <= 0;
  end else begin
		if ((write && !full) || (write && read)) write_pointer <= write_pointer + 1;
		if ((read && !empty) || (write && read)) read_pointer <= read_pointer + 1;
  end 

// Count
always @(posedge clk) 
	if (reset) 
		fifo_count <= 0;
	else
		if (read ^^ write)
			if (read && fifo_count != 0)
				fifo_count <= fifo_count - 1;
			else
				if (write && fifo_count != `FIFO_LAST)
					fifo_count <= fifo_count + 1;

endmodule
