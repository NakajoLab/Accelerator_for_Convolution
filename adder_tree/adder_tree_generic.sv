module adder_tree_generic#(
    parameter WIDTH = 32,
    parameter INPUT_NUM = 4,
    parameter STAGE_NUM = $clog2(INPUT_NUM) 
)(
    input clk,
    input rst,
    input logic [INPUT_NUM - 1:0][WIDTH - 1:0] indata,
    output logic [WIDTH - 1:0] res);

    logic [INPUT_NUM - 1:0][WIDTH - 1:0] input_pipeline_reg;
    logic [(-2 * (1 - 2 ** (STAGE_NUM - 1))) - 1:0] midway_res_wire;

    genvar i;
    generate
        for(i = 0; i < INPUT_NUM - 1; i = i + 2) begin: input_adder // input & midway_node addition 
            adder i_input_sum(
                .a(     input_pipeline_reg[i * 2]),
                .b(     input_pipeline_reg[(i * 2) + 1]),
                .y(     midway_res_wire[(i * 2) + (-2 * (1 - 2 ** (STAGE_NUM - 2)))])
            );
        end

        for(i = 1; i <= (INPUT_NUM / 2) - 2; i++) begin: midway_add // midway_node & midway_node addition
            adder i_midway_sum(
                .a(     midway_res_wire[(i * 2) + 1]),
                .b(     midway_res_wire[(i * 2)]),
                .y(     midway_res_wire[i - 1])
            );
        end
    endgenerate

    adder adder_res(
                .a(     midway_res_wire[0]),
                .b(     midway_res_wire[1]),
                .y(     res);
    )

    always_ff @(posedge clk or posedge rst) begin
        if(rst) begin
            input_pipleline_reg <= 0;
        end else begin
            input_pipleline_reg <= indata;
        end
    end

endmodule


module adder#(
    parameter WIDTH = 32
)(
    input logic [WIDTH - 1:0] a,
    input logic [WIDTH - 1:0] b,
    output logic [WIDTH - 1:0] y);

    assign y = a + b;
endmodule