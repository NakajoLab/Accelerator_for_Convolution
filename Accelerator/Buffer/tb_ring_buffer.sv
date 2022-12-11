module tb_ring_buffer();
localparam DATA_WIDTH = 4;
localparam BUFFER_SIZE = 4;
localparam DATA_OF_SET  = 4;

logic clk;
logic rst;
logic wen;
logic ren;
logic [DATA_OF_SET - 1:0][DATA_WIDTH - 1:0] din;
logic full_flag;
logic empty_flag;
logic [DATA_OF_SET - 1:0][DATA_WIDTH - 1:0] dout;
logic [$clog2(BUFFER_SIZE) - 1:0] wptr_check, rptr_check;
logic [DATA_WIDTH - 1:0] fifo_check0;

ring_buffer dut(
                    .clk(clk),
                    .rst(rst),
                    .wen(wen),
                    .ren(ren),
                    .din(din),
                    .full_flag(full_flag),
                    .empty_flag(empty_flag),
                    .dout(dout),
                    .wptr_check(wptr_check),
                    .rptr_check(rptr_check),
                    .fifo_check0(fifo_check0)
);

localparam CLK_PERIOD = 2;
initial begin
    clk <= 1;
    forever #(CLK_PERIOD/2) clk=~clk;
end

initial begin
    $dumpfile("tb_ring_buffer.vcd");
    $dumpvars(0, tb_ring_buffer);
end

task test(logic wen_b, logic [DATA_OF_SET - 1:0][DATA_WIDTH - 1:0] ren_b, logic [DATA_OF_SET - 1:0][DATA_WIDTH - 1:0] din_0, logic [DATA_OF_SET - 1:0][DATA_WIDTH - 1:0] din_1, logic [DATA_OF_SET - 1:0][DATA_WIDTH - 1:0] din_2, logic [DATA_OF_SET - 1:0][DATA_WIDTH - 1:0] din_3);
    begin
        wen = wen_b;
        ren = ren_b;
        din[0] = din_0;
        din[1] = din_1;
        din[2] = din_2;
        din[3] = din_3;
    end
endtask

initial begin
    rst = 0; wen = 0; ren = 0; din = 0; 
    #(CLK_PERIOD * 2) rst = 1;
    #(CLK_PERIOD) rst = 0;
    #(CLK_PERIOD * 2)   test(0, 0, 0, 0, 0, 0);
    #(CLK_PERIOD)       test(1, 0, 1, 2, 3, 4);
    #(CLK_PERIOD)       test(1, 1, 1, 1, 1, 1);
    #(CLK_PERIOD)       test(1, 0, 2, 2, 2, 2);
    #(CLK_PERIOD)       test(1, 0, 3, 3, 3, 3);
    #(CLK_PERIOD)       test(1, 0, 4, 4, 4, 4);
    #(CLK_PERIOD)       test(1, 0, 5, 5, 5, 5);
    #(CLK_PERIOD * 2)   test(0, 0, 0, 0, 0, 0);
    
    #(CLK_PERIOD)       test(0, 1, 1, 2, 3, 4);
    #(CLK_PERIOD)       test(0, 1, 1, 1, 1, 1);
    #(CLK_PERIOD)       test(0, 1, 2, 2, 2, 2);
    #(CLK_PERIOD)       test(0, 1, 3, 3, 3, 3);
    #(CLK_PERIOD)       test(1, 0, 4, 4, 4, 4);
    #(CLK_PERIOD)       test(0, 1, 5, 5, 5, 5);
    #(CLK_PERIOD * 20);
    $finish();
end

endmodule
`default_nettype wire