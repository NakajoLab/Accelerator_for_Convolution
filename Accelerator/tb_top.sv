module tb_top();
localparam DATA_WIDTH = 32;
localparam BUFFER_SIZE = 4;
localparam KERNEL_SIZE = 9;
localparam NUM_OF_MUL = 14;
localparam DATA_OF_SET = 128;
localparam IN_NUM_OF_SET = 4;
localparam OUT_NUM_OF_SET = 3;

logic clk;
logic rst;
logic wen;
logic [KERNEL_SIZE - 1:0][DATA_WIDTH - 1:0] kernel;
logic [IN_NUM_OF_SET - 1:0][DATA_OF_SET - 1:0][DATA_WIDTH - 1:0] din;
logic [DATA_OF_SET - 1:0][DATA_WIDTH - 1:0] dout;
logic dout_valid;

localparam CLK_PERIOD = 2;
initial begin
    clk <= 1;
    forever #(CLK_PERIOD/2) clk=~clk;
end

top #(
    .DATA_WIDTH(DATA_WIDTH),
    .BUFFER_SIZE(BUFFER_SIZE),
    .KERNEL_SIZE(KERNEL_SIZE),
    .NUM_OF_MUL(NUM_OF_MUL),
    .DATA_OF_SET(DATA_OF_SET),
    .IN_NUM_OF_SET(IN_NUM_OF_SET),
    .OUT_NUM_OF_SET(OUT_NUM_OF_SET)
) dut(
            .clk(clk),
            .rst(rst),
            .wen(wen),
            .din(din),
            .kernel(kernel),
            .dout(dout),
            .dout_valid(dout_valid)
);

initial begin
    $dumpfile("tb_top.vcd");
    $dumpvars(0, tb_top);
end


task din_per_set(int num, logic [DATA_WIDTH - 1:0] data);
    begin
        integer i;
        for(i = 0;i < DATA_OF_SET;i++) begin
            din[num][i] = data;
        end
    end
endtask

task din_in(logic [DATA_WIDTH - 1:0] data);
    begin
        integer j, k;
        for(j = 0;j < IN_NUM_OF_SET;j++) begin
            for(k = 0;k < DATA_OF_SET;k++) begin
                din[j][k] = data;
            end
        end
    end
endtask

task kernel_in(logic [DATA_WIDTH - 1:0] data_kernel);
    begin
        integer j;
        for(j = 0;j < KERNEL_SIZE;j++) begin
            kernel[j] = data_kernel;
        end
    end
endtask

initial begin
    rst = 0; din = 0; wen = 0; kernel = 0;
    #(CLK_PERIOD * 3)   rst = 1;
    #(CLK_PERIOD)       rst = 0;
    #(CLK_PERIOD * 4)   din_in(1); kernel_in(3); wen = 1;
    #(CLK_PERIOD)       din_in(2);  
    #(CLK_PERIOD)       din_in(3); wen = 1;
    #(CLK_PERIOD)       din_in(4); wen = 1;
    #(CLK_PERIOD * 20); 
    $finish;
end

endmodule
`default_nettype wire