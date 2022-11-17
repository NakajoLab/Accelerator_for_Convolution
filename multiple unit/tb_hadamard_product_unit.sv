module tb_convolution_unit#(
    parameter WIDTH = 32,
    parameter SIZE = 9
)();

logic [SIZE - 1:0][WIDTH - 1:0] kernel;
logic [SIZE - 1:0][WIDTH - 1:0] patch;
logic [SIZE - 1:0][WIDTH - 1:0] res;

hadamard_product_unit dut(
    .kernel(kernel),
    .patch(patch),
    .res(res)
);

initial begin
    $dumpfile("tb_hadamard_product.vcd");
    $dumpvars(0, tb_hadamard_product);
end

initial begin
    kernel = 0; patch = 0; #10;


    $finish;
end

endmodule
`default_nettype wire