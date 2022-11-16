module tb_sample();
localparam INPUT_NUM = 4;
localparam WIDTH = 32;
logic clk;
logic rst;
logic [INPUT_NUM - 1:0][WIDTH - 1:0] in;
logic [WIDTH - 1:0] out;

localparam CLK_PERIOD = 2;
initial begin
    clk <= 0;
    forever #(CLK_PERIOD/2) clk=~clk;
end

sample dut(.in(in), .clk(clk), .rst(rst), .out(out));

initial begin
    $dumpfile("tb_sample.vcd");
    $dumpvars(0, tb_sample);
end

initial begin
    rst = 0; in[0] <= 0; in[1] <= 0; in[2] <= 0; in[3] <= 0; #5;
    repeat(5) @(posedge clk) rst = 1;
    repeat(2) @(posedge clk) in[0] <= 4;
    repeat(2) @(posedge clk) in[1] <= 2;
    $finish(10);
end

endmodule
`default_nettype wire