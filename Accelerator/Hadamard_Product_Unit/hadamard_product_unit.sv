module hadamard_product_unit#(
    parameter WIDTH = 32,
    parameter SIZE = 9
)(
    input logic [SIZE - 1:0][WIDTH - 1:0]               kernel,
    input logic [SIZE - 1:0][WIDTH - 1:0]               patch,
    input logic                                         buffer_valid,
    output logic                                        mul_valid,
    output logic [SIZE - 1:0][WIDTH - 1:0]              dout
);

    genvar i;
    generate
        for(i = 0; i < SIZE; i++) begin
            multiple_unit #(
                .WIDTH(WIDTH)
            ) i_multiple(
                .a(kernel[i]),
                .b(patch[i]),
                .y(dout[i])
            );
        end
    endgenerate
    
    assign mul_valid = buffer_valid;
    
endmodule

module multiple_unit#(
    parameter WIDTH = 32
)(
    input logic [WIDTH - 1:0] a,
    input logic [WIDTH - 1:0] b,
    output logic [WIDTH - 1:0] y
);
    assign y = a * b;
endmodule