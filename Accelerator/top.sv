module top import ara_pkg::*; #(
    parameter DATA_WIDTH = 32,
    parameter BUFFER_SIZE = 32,
    parameter KERNEL_SIZE = 9,
    parameter NUM_OF_MUL = 14,
    parameter DATA_OF_SET = 128,
    parameter IN_NUM_OF_SET = 16,
    parameter OUT_NUM_OF_SET = 3
)(
    input logic                                                                         clk,
    input logic                                                                         rst,
    input logic [IN_NUM_OF_SET - 1:0][DATA_OF_SET - 1:0][DATA_WIDTH - 1:0]              din,
    input logic [KERNEL_SIZE - 1:0][DATA_WIDTH - 1:0]                                   kernel,
    input accel_op_e                                                                    op,
    output logic [7:0][DATA_OF_SET - 1:0][DATA_WIDTH - 1:0]                             dout,
    output logic                                                                        dout_valid
);

    logic                                                                               wen;
    logic                                                                               full_flag;
    logic [OUT_NUM_OF_SET - 1:0]                                                        buffer_valid;
    logic [OUT_NUM_OF_SET - 1:0]                                                        mul_valid;
    logic [OUT_NUM_OF_SET - 1:0]                                                        adder_valid;
    logic [KERNEL_SIZE - 1:0]                                                           index;
    logic [OUT_NUM_OF_SET - 2:0]                                                        dout_tmp_over_valid;
    logic                                                                               dout_buf_flag;
    
    logic [OUT_NUM_OF_SET - 1:0][DATA_OF_SET - 1:0][DATA_WIDTH - 1:0]                   dout_buffer;
    logic [OUT_NUM_OF_SET - 1:0][NUM_OF_MUL - 1:0][KERNEL_SIZE - 1:0][DATA_WIDTH - 1:0] dout_mul_unit;
    logic [OUT_NUM_OF_SET - 1:0][NUM_OF_MUL - 1:0][DATA_WIDTH - 1:0]                    dout_adder_tree;
    // logic [(NUM_OF_MUL * OUT_NUM_OF_SET) - 1:0][DATA_WIDTH - 1:0]                       dout_tmp;
    // logic [1:0][KERNEL_SIZE - 1:0][NUM_OF_MUL - 1:0][DATA_WIDTH - 1:0]                  dout_buf;
    // logic [OUT_NUM_OF_SET - 2:0][NUM_OF_MUL - 1:0][DATA_WIDTH - 1:0]                    dout_tmp_over;
    logic [7:0][DATA_OF_SET - 1:0][DATA_WIDTH - 1:0]                                    res;
    logic [7:0]                                                                         res_valid;
    accel_op_e                                                                          op_reg;
    // accel_op_e                                                                          op_tmp;
    logic                                                                               full_flag_for_output;

    // logic [$clog2(KERNEL_SIZE) - 1:0]                                   index_checker;
    // logic [DATA_OF_SET - 1:0][DATA_WIDTH - 1:0]                                                 dout_checker;
    // logic [1:0][KERNEL_SIZE - 1:0][NUM_OF_MUL - 1:0][DATA_WIDTH - 1:0]                          dout_buf_checker;
    // logic valid_checker;
    // logic dout_buf_flag_checker;
    // logic flag;
    logic [5:0] cnt;
    
    always_ff @(posedge clk or posedge rst) begin
        if(rst) begin
            op_reg <= NONE;
        // end else if(op != NONE)
        //     op_tmp <= op;
        end else begin
            op_reg <= op;
        end
        if(rst || cnt == 6'b100000 || ((op == READ) && (op_reg == READ))) begin
            cnt <= 6'b0;
        end else if((op == READ) && (op_reg != READ))
            cnt <= cnt + 6'b1;
    end

    assign wen = ((op == READ) && (op_reg != READ) && (cnt == 6'b0));
    // assign dout_valid = ((op == WRITE) && (op_reg != WRITE) && (op_tmp != WRITE));
    assign dout_valid = ((op == WRITE) && (op_reg != WRITE));
    
    // always_ff @(posedge clk) begin
    //     // $display("op = %d, op_reg = %d, cnt = %d", op, op_reg, cnt);
        // if(wen) begin
        //     $display("input");
        //     for(integer r = 0;r < IN_NUM_OF_SET;r++) begin
        //         for(integer n = 0;n < DATA_OF_SET;n++) begin
        //             $write("[%d]%d,", n, din[r][n]);
        //         end
        //         $display("");
        //     end
        // end
        // // if(dout_valid) begin
        //     $display("output");
        //     for(integer l = 0;l < DATA_OF_SET;l++) begin
        //         $write("[%d]%d", l ,dout[0][l]);
        //     end
        //     $display("");
        // end
        // if(|buffer_valid) begin
        //     $display("buffer %x", buffer_valid);
        //     for(integer m = 0;m < OUT_NUM_OF_SET;m++) begin
        //         $write("[%d]%d %d %d", m, dout_buffer[m][0], dout_buffer[m][1], dout_buffer[m][2]);
        //     end
        //     $display("");
        // end

        // if(|buffer_valid) begin
        //     $display("buffer %x %x", buffer_valid, empty_flag_tmp_checker);
        //     for(integer e = 0;e < NUM_OF_MUL;e++) begin
        //         $write("[%d]%d", e, dout_buffer[0][(9 * e + 8):9 * e]);
            
        //     end
        // end

        // if(|mul_valid) begin
        //     $display("mul_unit");
        //     // for(integer h = 0;h < OUT_NUM_OF_SET;h++) begin
        //         for(integer b = 0;b < NUM_OF_MUL;b++) begin
        //             for(integer c = 0;c < KERNEL_SIZE;c++) begin
        //                 $write("[%d, %d] %d", b, c, dout_mul_unit[0][b][c]);
        //             end
        //             $display("");
        //         end
        //     // end
        //     $display("");
        // end

        // if(|adder_valid) begin
        //     $display("adder_unit %x", adder_valid);
        //     for(integer x = 0;x < OUT_NUM_OF_SET;x++) begin
        //         for(integer f = 0;f < NUM_OF_MUL;f++) begin
        //             $write("[%d][%d]%d", x, f, dout_adder_tree[x][f]);
        //             $display("");
        //         end
        //         $display("");
        //     end
        // end

        // if(|res_valid) begin
        //     $display("for_output(res[0], res[1], dout) index =%d, res_valid=%x", index_checker, res_valid);
        //     for(integer s = 0;s < DATA_OF_SET;s++) begin
        //         $write("[%d]%d %d %d", s, res[0][s], res[1][s], dout_checker[s]);
        //         $display("");
        //     end
        //     $display("");
        // end

        // if(|res_valid) begin
        //     $display("for_output(dout_buf) buf_flag = %d valid = %d flag = %d", dout_buf_flag_checker, valid_checker, flag);
        //     for(integer o = 0;o < KERNEL_SIZE;o++) begin
        //         for(integer t = 0;t < NUM_OF_MUL;t++) begin
        //             $write("[%d %d] %d %d", o, t, dout_buf_checker[0][o][t], dout_buf_checker[1][o][t]);
        //             $display("");
        //         end
        //     end
        // end

        // if(|adder_valid) begin
        //     $display("adder_unit");
        //     for(integer s = 0;s < OUT_NUM_OF_SET;s++) begin
        //         $write("[%d]%d %d %d", s, dout_adder_tree[s][0], dout_adder_tree[s][1], dout_adder_tree[s][2]);
        //     end
        //     $display("");
        // end

    // end

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
                                    .patch(dout_buffer[i][(9 * j + 8):9 * j]),
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
                
            end
        end
        
        for(i = 0;i < 8;i++) begin
            assign dout[i] = res_valid[i] ? res[i] : 1'b0;
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
                                    .din(dout_adder_tree),
                                    .op(op),
                                    .res(res),
                                    .res_valid(res_valid),
                                    .full_flag(full_flag_for_output)
    );
    
endmodule