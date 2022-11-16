module sample#(
    parameter WIDTH = 32,
    parameter INPUT_NUM = 4
)(  
    input logic [INPUT_NUM - 1:0][WIDTH - 1:0]  in,
    input logic                                 clk,
    input logic                                 rst,
    output logic [WIDTH - 1:0]                  out);
    
    logic [INPUT_NUM - 3:0][WIDTH - 1:0] wire_add;

    adder_tmp adder1(.a(in[0]), .b(in[1]), .y(wire_add[0]));
    adder_tmp adder2(.a(in[2]), .b(in[3]), .y(wire_add[1]));

    adder_tmp adder3(.a(wire_add[0]), .b(wire_add[1]), .y(out));

endmodule


module adder_tmp#(
    parameter WIDTH = 32
)(
    input logic [WIDTH - 1:0] a,
    input logic [WIDTH - 1:0] b,
    output logic [WIDTH - 1:0] y);

    assign y = a + b;
endmodule