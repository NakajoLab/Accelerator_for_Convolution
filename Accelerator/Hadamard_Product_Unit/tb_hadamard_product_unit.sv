module tb_hadamard_product_unit#(
    parameter WIDTH = 32,
    parameter SIZE = 9
)();

logic clk;
logic [SIZE - 1:0][WIDTH - 1:0] kernel;
logic [SIZE - 1:0][WIDTH - 1:0] patch;
logic [SIZE - 1:0][WIDTH - 1:0] dout;
logic buffer_valid;
logic mul_valid;

hadamard_product_unit #(
    .WIDTH(WIDTH),
    .SIZE(SIZE)
) dut(
    .kernel(kernel),
    .patch(patch),
    .buffer_valid(buffer_valid),
    .mul_valid(mul_valid),
    .dout(dout)
);

localparam CLK_PERIOD = 2;
initial begin
    clk <= 0;
    forever #(CLK_PERIOD/2) clk=~clk;
end

initial begin
    $dumpfile("tb_hadamard_product_unit.vcd");
    $dumpvars(0, tb_hadamard_product_unit);
end

initial begin
    kernel = 0; patch = 0; buffer_valid = 0;
    #(CLK_PERIOD) kernel[0] = 10; kernel[1] = 5; buffer_valid = 1;
    #(CLK_PERIOD) patch[0] = 10;
    #(CLK_PERIOD) patch[1] = 6; 
    #10;
    $finish;
end

endmodule
`default_nettype wire