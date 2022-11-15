`default_nettype none
module tb_addertree();
reg clk;
reg rst_n;
logic [INPUT_NUM - 1:0][WIDTH - 1:0] indata;
logic [WIDTH - 1:0] res;

adder_tree #(
    .WIDTH(32),
    .INPUT_NUM(8),
    .STAGE_NUM($clog2(INPUT_NUM)) 
) dut(.clk(clk), .rst(rst_n), .indata(indata), .res(res));

localparam CLK_PERIOD = 10;
always #(CLK_PERIOD/2) clk=~clk;

initial begin
    $dumpfile("tb_addertree.vcd");
    $dumpvars(0, tb_addertree);
end

always @(posedge clk) begin
    $display("%d", data[2]);
end

initial begin
    #1 rst_n<=1'bx;clk<=1'bx;
    #(CLK_PERIOD*3) rst_n<=1;
    #(CLK_PERIOD*3) rst_n<=0;clk<=0;
    repeat(5) @(posedge clk) indata[0] = 32;
    repeat(10) @(posedge clk);
    
    $finish(2);
end

endmodule
