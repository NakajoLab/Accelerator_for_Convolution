module top#(
    parameter DATA_WIDTH = 4,
    parameter BUFFER_SIZE = 4,
    parameter KERNEL_SIZE = 9,
    parameter NUM_OF_MUL = 14,
    parameter DATA_OF_SET = 36,
    parameter IN_NUM_OF_SET = 4,
    parameter OUT_NUM_OF_SET = 4
)(
    input logic clk,
    input logic rst,
    input logic wen,
    input logic [IN_NUM_OF_SET - 1:0][DATA_OF_SET - 1:0][DATA_WIDTH - 1:0] din,
    input logic [KERNEL_SIZE - 1:0][DATA_WIDTH - 1:0] kernel,
    output logic [DATA_OF_SET - 1:0][DATA_WIDTH - 1:0] dout,
    output logic dout_valid
);

    logic full_flag;
    logic [OUT_NUM_OF_SET - 1:0] buffer_valid;
    logic [OUT_NUM_OF_SET - 1:0] mul_valid;
    logic [OUT_NUM_OF_SET - 1:0] adder_valid;
    logic [KERNEL_SIZE - 1:0] index;
    logic [OUT_NUM_OF_SET - 2:0] dout_tmp_over_valid;
    logic dout_buf_flag;
    
    logic [OUT_NUM_OF_SET - 1:0][DATA_OF_SET - 1:0][DATA_WIDTH - 1:0] dout_buffer;
    logic [OUT_NUM_OF_SET - 1:0][NUM_OF_MUL - 1:0][KERNEL_SIZE - 1:0][DATA_WIDTH - 1:0] dout_mul_unit;
    logic [OUT_NUM_OF_SET - 1:0][NUM_OF_MUL - 1:0][DATA_WIDTH - 1:0] dout_adder_tree;
    logic [(NUM_OF_MUL * OUT_NUM_OF_SET) - 1:0][DATA_WIDTH - 1:0] dout_tmp;
    logic [1:0][KERNEL_SIZE - 1:0][NUM_OF_MUL - 1:0][DATA_WIDTH - 1:0] dout_buf;
    logic [OUT_NUM_OF_SET - 2:0][NUM_OF_MUL - 1:0][DATA_WIDTH - 1:0] dout_tmp_over; 
    
    buffer #(
                                    .DATA_WIDTH(DATA_WIDTH),
                                    .BUFFER_SIZE(BUFFER_SIZE),
                                    .DATA_OF_SET(DATA_OF_SET),
                                    .IN_NUM_OF_SET(IN_NUM_OF_SET),
                                    .OUT_NUM_OF_SET(OUT_NUM_OF_SET)
    ) buffer_first(        
                                    .clk(clk),
                                    .rst(rst),
                                    .wen(wen),
                                    .din(din),
                                    .full_flag(full_flag),
                                    .dout(dout_buffer),
                                    .valid(buffer_valid)
    );

    genvar i, j;
    generate
        for(i = 0;i < OUT_NUM_OF_SET;i++) begin
            for(j = 0;j < NUM_OF_MUL;j++) begin
                hadamard_product_unit #(
                                    .WIDTH(DATA_WIDTH),
                                    .SIZE(KERNEL_SIZE)
                ) mul_i(
                                    .kernel(kernel),
                                    .patch(dout_buffer[i][(9 * j + 8):j]),
                                    .dout(dout_mul_unit[i][j]),
                                    .buffer_valid(buffer_valid[i]),
                                    .mul_valid(mul_valid[i])
                );

                adder_tree #(
                                    .WIDTH(DATA_WIDTH),
                                    .KERNEL_SIZE(KERNEL_SIZE)
                ) adder_tree_i (
                                    .clk(clk),
                                    .rst(rst),
                                    .din(dout_mul_unit[i][j]),
                                    .dout(dout_adder_tree[i][j]),
                                    .mul_valid(mul_valid[i]),
                                    .adder_valid(adder_valid[i])
                );
                
                assign dout_tmp[j + NUM_OF_MUL * i] = dout_adder_tree[i][j];
                
            end
        end
        
    endgenerate
    
    for_output #(
                                    .DATA_WIDTH(DATA_WIDTH),
                                    .KERNEL_SIZE(KERNEL_SIZE),
                                    .NUM_OF_MUL(NUM_OF_MUL),
                                    .DATA_OF_SET(DATA_OF_SET),
                                    .OUT_NUM_OF_SET(OUT_NUM_OF_SET)                              
    ) out(
                                    .clk(clk),
                                    .rst(rst),
                                    .adder_valid(adder_valid),
                                    .dout_tmp(dout_tmp),
                                    .dout(dout),
                                    .dout_valid(dout_valid)
    );
    
endmodule