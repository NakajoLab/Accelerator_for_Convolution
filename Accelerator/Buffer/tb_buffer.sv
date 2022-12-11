module tb_buffer();
localparam DATA_WIDTH = 4;
localparam BUFFER_SIZE = 4;
localparam DATA_OF_SET = 4;
localparam IN_NUM_OF_SET = 4;
localparam OUT_NUM_OF_SET = 2;

logic clk;
logic rst;
logic wen;
logic [IN_NUM_OF_SET - 1:0][DATA_OF_SET - 1:0][DATA_WIDTH - 1:0] din;
logic full_flag;
logic [OUT_NUM_OF_SET - 1:0][DATA_OF_SET - 1:0][DATA_WIDTH - 1:0] dout;
logic [OUT_NUM_OF_SET - 1:0] valid; 

buffer #(
                    .DATA_WIDTH(DATA_WIDTH),
                    .BUFFER_SIZE(BUFFER_SIZE),
                    .DATA_OF_SET(DATA_OF_SET),
                    .IN_NUM_OF_SET(IN_NUM_OF_SET),
                    .OUT_NUM_OF_SET(OUT_NUM_OF_SET)
)dut(
                    .clk(clk),
                    .rst(rst),
                    .wen(wen),
                    .din(din),
                    .full_flag(full_flag),
                    .dout(dout),
                    .valid(valid)                   
);

localparam CLK_PERIOD = 2;
initial begin
    clk <= 1;
    forever #(CLK_PERIOD/2) clk=~clk;
end

initial begin
    $dumpfile("tb_buffer.vcd");
    $dumpvars(0, tb_buffer);
end

task din_same(int num, logic [DATA_WIDTH - 1:0] data);
    begin
        integer i;
        for(i = 0;i < DATA_OF_SET;i++) 
            din[num][i] = data;
    end
endtask

task din_stair(int num, logic [DATA_WIDTH - 1:0] data);
    begin
        integer i;
        for(i = 0;i < DATA_OF_SET;i++) 
            din[num][i] = data + i;
    end
endtask

task din_in(logic [DATA_WIDTH - 1:0] data);
    begin
        integer i, j;
        for(i = 0;i < IN_NUM_OF_SET;i++) begin
            for(j = 0;j < DATA_OF_SET;j++) begin
                din[i][j] = data;
            end
        end
    end
endtask

initial begin
    rst = 0; wen = 0; din = 0; // din_same(0,0); din_same(1,0); din_same(2,0); din_same(3,0); 
    #(CLK_PERIOD * 2)   rst = 1;
    #(CLK_PERIOD)       rst = 0;
    #(CLK_PERIOD * 2)   wen = 1; din_in(1); // din_same(0,1); din_same(1,1);din_same(2,1); din_same(3,1);
    #(CLK_PERIOD)       wen = 1; din_in(2); // din_stair(0,0); din_stair(1,1); din_stair(2,0); din_stair(3,1);
    #(CLK_PERIOD)       wen = 0; din_in(3); // din_stair(0,2); din_stair(1,3); din_stair(2,2); din_stair(3,3);
    #(CLK_PERIOD * 2)   wen = 1; din_in(4); // din_stair(0,4); din_stair(1,5); din_stair(2,4); din_stair(3,5);
    #(CLK_PERIOD)       wen = 1; din_in(5); // din_same(0,1); din_same(1,8); din_same(2,1); din_same(3,8);
    #(CLK_PERIOD)       wen = 1; din_in(6); // din_same(0,10); din_same(1,11); din_same(2,10); din_same(3,11);
    #(CLK_PERIOD * 3);
    $finish();
end

endmodule
`default_nettype wire