module adder_tree#(
    parameter WIDTH = 32,
    parameter INPUT_NUM = 8,
    parameter STAGE_NUM = $clog2(INPUT_NUM) 
)(
    input clk,
    input rst,
    input logic [INPUT_NUM - 1:0][WIDTH - 1:0] indata,
    output logic [WIDTH - 1:0] res);

    logic [(2 ** STAGE_NUM) - 1:0][WIDTH - 1:0] data;
    genvar 
    generate
        for() begin: add
            // always_ff @(posedge clk) begin
            //     data[]
            // end
        end
    endgenerate
endmodule