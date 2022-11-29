module tb_buffer();
localparam DATA_WIDTH = 32;
localparam BUFFER_SIZE = 1024;
localparam KERNEL_SIZE = 9;
localparam NUM_OF_MUL = 16;
localparam DATA_OF_SET = 128;
localparam NUM_OF_SET = 1;
logic clk;
logic rst;
logic wen, ren;
logic [DATA_OF_SET - 1:0][DATA_WIDTH - 1:0] din;
logic full_flag, empty_flag;
logic [NUM_OF_MUL - 1:0][DATA_WIDTH - 1:0] dout;
 
buffer dut( .*);

initial begin
    $dumpfile("tb_buffer.vcd");
    $dumpvars(0, tb_buffer);
end
localparam CLK_PERIOD = 2;
initial begin
    clk <= 0;
    forever #(CLK_PERIOD/2) clk=~clk;
    $finish();
end

endmodule
`default_nettype wire