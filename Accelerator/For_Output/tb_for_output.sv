module tb_for_output();
localparam DATA_WIDTH = 32;
localparam KERNEL_SIZE = 9;
localparam NUM_OF_MUL = 14;
localparam DATA_OF_SET = 128;
localparam OUT_NUM_OF_SET = 3;

logic clk;
logic rst;
logic [OUT_NUM_OF_SET - 1:0] adder_valid;
logic [(NUM_OF_MUL * OUT_NUM_OF_SET) - 1:0][DATA_WIDTH - 1:0] dout_tmp;
logic [DATA_OF_SET - 1:0][DATA_WIDTH - 1:0] dout;
logic dout_valid;

localparam CLK_PERIOD = 2;
initial begin
    clk <= 1;
    forever #(CLK_PERIOD/2) clk=~clk;
end

initial begin
    $dumpfile("tb_for_output.vcd");
    $dumpvars(0, tb_for_output);
end

for_output #(
                .DATA_WIDTH(DATA_WIDTH),
                .KERNEL_SIZE(KERNEL_SIZE),
                .NUM_OF_MUL(NUM_OF_MUL),
                .DATA_OF_SET(DATA_OF_SET),
                .OUT_NUM_OF_SET(OUT_NUM_OF_SET)
) dut(
                .clk(clk),
                .rst(rst),
                .adder_valid(adder_valid),
                .dout_tmp(dout_tmp),
                .dout(dout),
                .dout_valid(dout_valid)
);

task in_dout_tmp(logic [DATA_WIDTH - 1:0] data);
begin 
    integer i, j;
    for(i = 0;i < (OUT_NUM_OF_SET * NUM_OF_MUL);i++) begin
        dout_tmp[i] = data;
    end
end
endtask 

task in_1_2_1_3();
begin
    #(CLK_PERIOD * 2) in_dout_tmp(1); adder_valid = 3'b001; 
    #(CLK_PERIOD) in_dout_tmp(2); adder_valid = 3'b011;
    #(CLK_PERIOD) in_dout_tmp(3); adder_valid = 3'b100;
    #(CLK_PERIOD) in_dout_tmp(4); adder_valid = 3'b111;
    #(CLK_PERIOD) in_dout_tmp(5);
    #(CLK_PERIOD) in_dout_tmp(6);
    #(CLK_PERIOD) in_dout_tmp(7);
    #(CLK_PERIOD) in_dout_tmp(8);
end
endtask

task in_1_1_1_3();
begin
    #(CLK_PERIOD * 2) in_dout_tmp(1); adder_valid = 3'b001; 
    #(CLK_PERIOD) in_dout_tmp(2); adder_valid = 3'b010;
    #(CLK_PERIOD) in_dout_tmp(3); adder_valid = 3'b100;
    #(CLK_PERIOD) in_dout_tmp(4); adder_valid = 3'b111;
    #(CLK_PERIOD) in_dout_tmp(5);
    #(CLK_PERIOD) in_dout_tmp(6);
    #(CLK_PERIOD) in_dout_tmp(7);
    #(CLK_PERIOD) in_dout_tmp(8);
end
endtask

task in_2_2_1_3();
begin
    #(CLK_PERIOD * 2) in_dout_tmp(1); adder_valid = 3'b011; 
    #(CLK_PERIOD) in_dout_tmp(2); adder_valid = 3'b110;
    #(CLK_PERIOD) in_dout_tmp(3); adder_valid = 3'b100;
    #(CLK_PERIOD) in_dout_tmp(4); adder_valid = 3'b111;
    #(CLK_PERIOD) in_dout_tmp(5);
    #(CLK_PERIOD) in_dout_tmp(6);
    #(CLK_PERIOD) in_dout_tmp(7);
    #(CLK_PERIOD) in_dout_tmp(8);
end
endtask


task in_2_1_3_1();
begin
    #(CLK_PERIOD * 2) in_dout_tmp(1); adder_valid = 3'b101; 
    #(CLK_PERIOD) in_dout_tmp(2); adder_valid = 3'b010;
    #(CLK_PERIOD) in_dout_tmp(3); adder_valid = 3'b111;
    #(CLK_PERIOD) in_dout_tmp(4); adder_valid = 3'b100;
    #(CLK_PERIOD) in_dout_tmp(5);
    #(CLK_PERIOD) in_dout_tmp(6);
    #(CLK_PERIOD) in_dout_tmp(7);
    #(CLK_PERIOD) in_dout_tmp(8);
end
endtask

initial begin
rst = 0; dout_tmp = 0;
#(CLK_PERIOD) rst = 1;
#(CLK_PERIOD) rst = 0;
#(CLK_PERIOD * 2) in_dout_tmp(1); adder_valid = 3'b101; 
#(CLK_PERIOD) in_dout_tmp(2); adder_valid = 3'b010;
#(CLK_PERIOD) in_dout_tmp(3); adder_valid = 3'b111;
#(CLK_PERIOD) in_dout_tmp(4); adder_valid = 3'b100;
#(CLK_PERIOD) in_dout_tmp(5);
#(CLK_PERIOD) in_dout_tmp(6);
#(CLK_PERIOD) in_dout_tmp(7);
#(CLK_PERIOD) in_dout_tmp(8);
#(CLK_PERIOD * 10);
$finish();
end

endmodule 