module adder_tree#(
    parameter WIDTH = 32,
    parameter KERNEL_SIZE = 9
)(
    input logic clk,
    input logic rst,
    input logic [KERNEL_SIZE - 1:0][WIDTH - 1:0] din,
    input logic mul_valid,
    output logic adder_valid,
    output logic [WIDTH - 1:0] dout
);

    logic [KERNEL_SIZE - 1:0][WIDTH - 1:0] input_pipeline_reg;
    logic [6:0][WIDTH - 1:0] midway_adder_wire;
    logic mul_valid_reg;
    logic [WIDTH - 1:0] dout_tmp; 

    adder #(
        .WIDTH(WIDTH)
    ) adder0(
        .a(     input_pipeline_reg[0]),
        .b(     input_pipeline_reg[1]),
        .y(     midway_adder_wire[3]));
    
    adder #(
        .WIDTH(WIDTH)
    ) adder1(
        .a(     input_pipeline_reg[2]),
        .b(     input_pipeline_reg[3]),
        .y(     midway_adder_wire[4]));

    adder #(
        .WIDTH(WIDTH)
    ) addder2(
        .a(     input_pipeline_reg[4]),
        .b(     input_pipeline_reg[5]),
        .y(     midway_adder_wire[5]));

    adder #(
        .WIDTH(WIDTH)
    ) addder3(
        .a(     input_pipeline_reg[6]),
        .b(     input_pipeline_reg[7]),
        .y(     midway_adder_wire[6]));

    adder #(
        .WIDTH(WIDTH)
    ) addder4(
        .a(     midway_adder_wire[3]),
        .b(     midway_adder_wire[4]),
        .y(     midway_adder_wire[1]));

    adder #(
        .WIDTH(WIDTH)
    ) addder5(
        .a(     midway_adder_wire[5]),
        .b(     midway_adder_wire[6]),
        .y(     midway_adder_wire[2]));

    adder #(
        .WIDTH(WIDTH)
    ) addder6(
        .a(     midway_adder_wire[1]),
        .b(     midway_adder_wire[2]),
        .y(     midway_adder_wire[0]));

    adder #(
        .WIDTH(WIDTH)
    ) addder7(
        .a(     midway_adder_wire[0]),
        .b(     input_pipeline_reg[8]),
        .y(     dout_tmp));
    
    assign dout = mul_valid_reg ? dout_tmp : 1'b0;
    assign adder_valid = mul_valid_reg;
    
    always_ff @(posedge clk or posedge rst) begin
        if(rst) begin
            input_pipeline_reg <= 0;
            mul_valid_reg <= 0;
        end else begin
            input_pipeline_reg <= din;
            mul_valid_reg <= mul_valid;
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