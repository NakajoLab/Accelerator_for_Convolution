module tb_addertree();
localparam INPUT_NUM = 9;
localparam WIDTH = 32;
logic clk;
logic rst;
logic mul_valid;
logic [INPUT_NUM - 1:0][WIDTH - 1:0] din;
logic [WIDTH - 1:0] dout;

localparam CLK_PERIOD = 2;
initial begin
    clk <= 1;
    forever #(CLK_PERIOD/2) clk=~clk;
end

adder_tree #(
                    .WIDTH(WIDTH)
)dut(               .clk(clk), 
                    .rst(rst), 
                    .din(din),
                    .mul_valid(mul_valid),
                    .dout(dout));

initial begin
    $dumpfile("tb_addertree.vcd");
    $dumpvars(0, tb_addertree);
end

task din_per_clock(logic [WIDTH - 1:0] data);
    begin
        integer i;
        for(i = 0;i < INPUT_NUM;i++) begin
            din[i] = data;
        end
    end
endtask 

initial begin
    rst = 0; din = 0; mul_valid = 0; #4;
    #(CLK_PERIOD * 2) rst = 1;
    #(CLK_PERIOD) rst = 0;
    #(CLK_PERIOD * 2) din[0] = 4; mul_valid = 0;
    #(CLK_PERIOD) din_per_clock(3); mul_valid = 1;
    #(CLK_PERIOD) din_per_clock(4);
    #(CLK_PERIOD) din_per_clock(8);
    #(CLK_PERIOD) din[8] = 0;
    #10;
    $finish;
end

endmodule
`default_nettype wire