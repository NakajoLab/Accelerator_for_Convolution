module adder_tree#(
    parameter WIDTH = 32
)(
    input clk,
    input rst,
    input logic [8:0][WIDTH - 1:0] indata,
    output logic [WIDTH - 1:0] res);

    logic [8:0][WIDTH - 1:0] input_pipeline_reg;
    logic [6:0][WIDTH - 1:0] midway_adder_wire;

    adder adder1(
        .a(     input_pipeline_reg[0]),
        .b(     input_pipeline_reg[1]),
        .y(     midway_adder_wire[3]));
    
    adder adder2(
        .a(     input_pipeline_reg[2]),
        .b(     input_pipeline_reg[3]),
        .y(     midway_adder_wire[4]));

    adder addder3(
        .a(     input_pipeline_reg[4]),
        .b(     input_pipeline_reg[5]),
        .y(     midway_adder_wire[5]));

    adder addder4(
        .a(     input_pipeline_reg[6]),
        .b(     input_pipeline_reg[7]),
        .y(     midway_adder_wire[6]));

    adder addder5(
        .a(     midway_adder_wire[3]),
        .b(     midway_adder_wire[4]),
        .y(     midway_adder_wire[1]));

    adder addder6(
        .a(     midway_adder_wire[5]),
        .b(     midway_adder_wire[6]),
        .y(     midway_adder_wire[2]));

    adder addder7(
        .a(     midway_adder_wire[1]),
        .b(     midway_adder_wire[2]),
        .y(     midway_adder_wire[0]));

    adder addder8(
        .a(     midway_adder_wire[0]),
        .b(     input_pipeline_reg[8]),
        .y(     res));
    
    always_ff @(posedge clk or posedge rst) begin
        if(rst) begin
            input_pipeline_reg <= 0;
        end else begin
            input_pipeline_reg <= indata;
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