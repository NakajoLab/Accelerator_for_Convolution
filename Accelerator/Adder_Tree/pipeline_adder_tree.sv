module pipeline_adder_tree#(
    parameter WIDTH = 32,
    parameter INPUT_NUM = 8,
    parameter STAGE_NUM = $clog2(INPUT_NUM) 
)(
    input clk,
    input rst,
    input logic [INPUT_NUM - 1:0][WIDTH - 1:0] indata,
    output logic [WIDTH - 1:0] res);

    logic [INPUT_NUM - 3:0][WIDTH - 1:0] pipeline_reg_adder_tree;
    
    genvar i;
    generate
        for(i = 0; i < INPUT_NUM; i = i + 2) begin: input_add
                adder i_input(
                    .a(     indata[i][WIDTH - 1:0]), 
                    .b(     indata[i+1][WIDTH - 1:0]),
                    .clk(   clk),
                    .rst(   rst), 
                    .y(     pipeline_reg_adder_tree[(-2 * (1 - 2 ** (STAGE_NUM - 2))) + i][WIDTH - 1:0]));
        end

        for(i = 1; i <= (-2 * (1 - 2 ** (STAGE_NUM - 2))); i++) begin: midway_add
                adder i_sum(
                    .a(     pipeline_reg_adder_tree[i*2][WIDTH - 1:0]), 
                    .b(     pipeline_reg_adder_tree[(i*2)+1][WIDTH - 1:0]), 
                    .clk(   clk),
                    .rst(   rst),
                    .y(     pipeline_reg_adder_tree[i - 1][WIDTH - 1:0]));
        end
    endgenerate

    assign res = data[1][WIDTH - 1:0] + data[0][WIDTH - 1:0];
endmodule


module adder_tmp#(
    parameter WIDTH = 32
)(
    input logic [WIDTH - 1:0] a,
    input logic [WIDTH - 1:0] b,
    output logic [WIDTH - 1:0] y);

    assign y = a + b;
endmodule