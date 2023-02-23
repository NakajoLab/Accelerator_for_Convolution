module for_output import ara_pkg::*; #(
    parameter DATA_WIDTH = 32,
    parameter KERNEL_SIZE = 9,
    parameter NUM_OF_MUL = 14,
    parameter DATA_OF_SET = 128,
    parameter OUT_NUM_OF_SET = 3
)(
    input logic                                                                                 clk,
    input logic                                                                                 rst,
    input logic [OUT_NUM_OF_SET - 1:0]                                                          adder_valid, 
    input logic [OUT_NUM_OF_SET - 1:0][NUM_OF_MUL - 1:0][DATA_WIDTH - 1:0]                      din, // input from adder_tree
    input accel_op_e                                                                            op, // opration
    output logic [7:0][DATA_OF_SET - 1:0][DATA_WIDTH - 1:0]                                     res, // output
    output logic [7:0]                                                                          res_valid, // valid for output
    output logic                                                                                full_flag
    // output logic [$clog2(KERNEL_SIZE) - 1:0]                                   index_checker,
    // output logic [DATA_OF_SET - 1:0][DATA_WIDTH - 1:0]                                                 dout_checker,
    // output logic [1:0][KERNEL_SIZE - 1:0][NUM_OF_MUL - 1:0][DATA_WIDTH - 1:0]                          dout_buf_checker,
    // output logic dout_buf_flag_checker,
    // output logic valid_checker,
    // output logic flag
); 
    
    logic [2:0]                                                                                 res_index; // index of 8 output register 
    logic                                                                                       dout_valid; // valid for whether res[i] is full
    logic [DATA_OF_SET - 1:0][DATA_WIDTH - 1:0]                                                 dout; // output data at res[res_index]
    logic [1:0][KERNEL_SIZE - 1:0][NUM_OF_MUL - 1:0][DATA_WIDTH - 1:0]                          dout_buf; // buffer not to lose overflow dout data
    logic [$clog2(KERNEL_SIZE) - 1:0]                                                           index; // index to input dout_tmp in dout
    logic                                                                                       dout_buf_flag; // flag to indicate which dout_buf is used
    accel_op_e                                                                                  op_reg;
    
    always_ff @(posedge clk or posedge rst) begin
        if(rst)
            op_reg <= NONE;
        else
            op_reg <= op;
    end
    
    always_ff @(posedge clk or posedge rst) begin
        if(rst || (op == WRITE))
            full_flag <= 1'b0;
        else if(res_valid[7] && dout_valid)
            full_flag <= 1'b1;
    end
    
    // index & dout_buf_flag & dout_valid & dout_buf
    always_ff @(posedge clk or posedge rst) begin // If you change OUT_NUM_OF_SET, you must this bit width.
        if(rst || (op == WRITE)) begin
            index <= 1'b0;
            dout_buf_flag <= 1'b0;
            dout_valid <= 1'b0;
        end else if(!full_flag) begin
             if((adder_valid == 3'b111)) begin // input 3 valid set
                if(index == (KERNEL_SIZE - OUT_NUM_OF_SET)) begin // index = 6
                    index <= 2'b00;
                    dout_valid <= 1'b1;
                    dout_buf_flag <= !dout_buf_flag;
                end else if(index == (KERNEL_SIZE - OUT_NUM_OF_SET + 2'b01)) begin // index = 7
                    index <= 2'b01;
                    dout_valid <= 1'b1;
                    dout_buf_flag <= !dout_buf_flag;
                end else if(index == (KERNEL_SIZE - OUT_NUM_OF_SET + 2'b10)) begin // index = 8
                    index <= 2'b10;
                    dout_valid <= 1'b1;
                    dout_buf_flag <= !dout_buf_flag;
                end else begin // index = 0 ~ 5
                    index <= index + 2'b11;
                    dout_valid <= 1'b0;
                end
            end else if(((adder_valid == 3'b011) || (adder_valid == 3'b101) || (adder_valid == 3'b110))) begin // input 2 valid set
                if(index == (KERNEL_SIZE - OUT_NUM_OF_SET + 2'b01)) begin // index = 7
                    index <= 2'b00;
                    dout_valid <= 1'b1;
                    dout_buf_flag <= !dout_buf_flag;
                end else if(index == (KERNEL_SIZE - OUT_NUM_OF_SET + 2'b10)) begin // index = 8
                    index <= 2'b01;
                    dout_valid <= 1'b1;
                    dout_buf_flag <= !dout_buf_flag;
                end else begin // index = 0 ~ 6
                    index <= index + 2'b10;
                    dout_valid <= 1'b0;
                end
            end else if((((adder_valid == 3'b001) || (adder_valid == 3'b010) || (adder_valid == 3'b100)))) begin // input 1 valid set
                if(index == (KERNEL_SIZE - OUT_NUM_OF_SET + 2'b10)) begin // index = 8
                    index <= 2'b00;
                    dout_valid <= 1'b1;
                    dout_buf_flag <= !dout_buf_flag;
                end else begin // index = 0 ~ 7
                    index <= index + 2'b01;
                    dout_valid <= 1'b0;
                end
            end

            case(adder_valid)
                3'b111: if(index == (KERNEL_SIZE - OUT_NUM_OF_SET + 2'b01)) begin // index = 7
                                                    dout_buf[dout_buf_flag][index] <= din[0];
                                                    dout_buf[dout_buf_flag][index + 2'b01] <= din[1];
                                                    dout_buf[!dout_buf_flag][0] <= din[2];
                                                end else if(index == KERNEL_SIZE - OUT_NUM_OF_SET + 2'b10) begin // index = 8
                                                    dout_buf[dout_buf_flag][index] <= din[0];
                                                    dout_buf[!dout_buf_flag][0] <= din[1];
                                                    dout_buf[!dout_buf_flag][1] <= din[2];
                                                end else begin // index = 0 ~ 6
                                                    dout_buf[dout_buf_flag][index] <= din[0];
                                                    dout_buf[dout_buf_flag][index + 2'b01] <= din[1];
                                                    dout_buf[dout_buf_flag][index + 2'b10] <= din[2];
                                                end
                3'b110: if(index == KERNEL_SIZE - OUT_NUM_OF_SET + 2'b10) begin // index = 8
                            dout_buf[dout_buf_flag][index] <= din[1];
                            dout_buf[!dout_buf_flag][0] <= din[2];
                        end else begin
                            dout_buf[dout_buf_flag][index] <= din[1];
                            dout_buf[dout_buf_flag][index + 2'b01] <= din[2];
                        end
                3'b101: if(index == KERNEL_SIZE - OUT_NUM_OF_SET + 2'b10) begin // index = 8
                            dout_buf[dout_buf_flag][index] <= din[0];
                            dout_buf[!dout_buf_flag][0] <= din[2];
                        end else begin
                            dout_buf[dout_buf_flag][index] <= din[0];
                            dout_buf[dout_buf_flag][index + 2'b01] <= din[2];
                        end
                3'b011: if(index == KERNEL_SIZE - OUT_NUM_OF_SET + 2'b10) begin // index = 8
                            dout_buf[dout_buf_flag][index] <= din[0];
                            dout_buf[!dout_buf_flag][0] <= din[1];
                        end else begin
                            dout_buf[dout_buf_flag][index] <= din[0];
                            dout_buf[dout_buf_flag][index + 2'b01] <= din[1];
                        end
                3'b100: dout_buf[dout_buf_flag][index] <= din[2];
                3'b010: dout_buf[dout_buf_flag][index] <= din[1];
                3'b001: dout_buf[dout_buf_flag][index] <= din[0];
            endcase

        end
    end
    
    // dout
    genvar i;
    generate
        for(i = 0;i < KERNEL_SIZE;i++) begin
            always_comb begin
                if(rst) 
                    dout[((NUM_OF_MUL * (i + 1)) - 1):(NUM_OF_MUL * i)] = 1'b0;
                else if(dout_valid)
                    dout[((NUM_OF_MUL * (i + 1)) - 1):(NUM_OF_MUL * i)] = dout_buf[!dout_buf_flag][i];
                else begin
                    case (index)
                    4'b0000:
                    begin
                        dout[((NUM_OF_MUL * (i + 1)) - 1):(NUM_OF_MUL * i)] = dout_buf[!dout_buf_flag][i];
                    end
                    4'b0001:
                    begin
                        if(i < 1)
                            dout[((NUM_OF_MUL * (i + 1)) - 1):(NUM_OF_MUL * i)] = dout_buf[dout_buf_flag][i];
                        else
                            dout[((NUM_OF_MUL * (i + 1)) - 1):(NUM_OF_MUL * i)] = 1'b0;                    
                    end
                    4'b0010:
                    begin
                        if(i < 2)
                            dout[((NUM_OF_MUL * (i + 1)) - 1):(NUM_OF_MUL * i)] = dout_buf[dout_buf_flag][i];
                        else
                            dout[((NUM_OF_MUL * (i + 1)) - 1):(NUM_OF_MUL * i)] = 1'b0;                    
                    end
                    4'b0011:
                    begin
                        if(i < 3)
                            dout[((NUM_OF_MUL * (i + 1)) - 1):(NUM_OF_MUL * i)] = dout_buf[dout_buf_flag][i];
                        else
                            dout[((NUM_OF_MUL * (i + 1)) - 1):(NUM_OF_MUL * i)] = 1'b0;                    
                    end
                    4'b0100:
                    begin
                        if(i < 4)
                            dout[((NUM_OF_MUL * (i + 1)) - 1):(NUM_OF_MUL * i)] = dout_buf[dout_buf_flag][i];
                        else
                            dout[((NUM_OF_MUL * (i + 1)) - 1):(NUM_OF_MUL * i)] = 1'b0;                    
                    end
                    4'b0101:
                    begin
                        if(i < 5)
                            dout[((NUM_OF_MUL * (i + 1)) - 1):(NUM_OF_MUL * i)] = dout_buf[dout_buf_flag][i];
                        else
                            dout[((NUM_OF_MUL * (i + 1)) - 1):(NUM_OF_MUL * i)] = 1'b0;                    
                    end
                    4'b0110:
                    begin
                        if(i < 6)
                            dout[((NUM_OF_MUL * (i + 1)) - 1):(NUM_OF_MUL * i)] = dout_buf[dout_buf_flag][i];
                        else
                            dout[((NUM_OF_MUL * (i + 1)) - 1):(NUM_OF_MUL * i)] = 1'b0;                    
                    end
                    4'b0111:
                    begin
                        if(i < 7)
                            dout[((NUM_OF_MUL * (i + 1)) - 1):(NUM_OF_MUL * i)] = dout_buf[dout_buf_flag][i];
                        else
                            dout[((NUM_OF_MUL * (i + 1)) - 1):(NUM_OF_MUL * i)] = 1'b0;                    
                    end
                    4'b1000:
                    begin
                        if(i < 8)
                            dout[((NUM_OF_MUL * (i + 1)) - 1):(NUM_OF_MUL * i)] = dout_buf[dout_buf_flag][i];
                        else
                            dout[((NUM_OF_MUL * (i + 1)) - 1):(NUM_OF_MUL * i)] = 1'b0;                    
                    end
                    default:
                        dout[((NUM_OF_MUL * (i + 1)) - 1):(NUM_OF_MUL * i)] = 1'b0;
                    endcase
                end
            end
        end
    endgenerate

    assign dout[DATA_OF_SET - 1] = 1'b0;
    assign dout[DATA_OF_SET - 2] = 1'b0;
    
    // res_index
    always_ff @(posedge clk or posedge rst) begin
        if(rst || (op_reg == WRITE))
            res_index <= 1'b0;
        else if(dout_valid && res_index != 4'b0111)
            res_index <= res_index + 1'b1;
    end
    
    always_ff @(posedge clk or posedge rst) begin
        if(rst || (op_reg == WRITE)) begin
            res <= 0;
            res_valid <= 0; 
        end
        else if(!full_flag) begin 
            case(res_index)
                3'b000: 
                begin
                    res[0] <= dout;
                    if(dout_valid || index != 0)
                        res_valid[0] <= 1'b1;
                end
                3'b001: 
                begin
                    res[1] <= dout;
                    if(dout_valid || index != 0)
                        res_valid[1] <= 1'b1;
                end
                3'b010:
                begin 
                    res[2] <= dout;
                    if(dout_valid || index != 0)
                        res_valid[2] <= 1'b1; 
                end
                3'b011: 
                begin
                    res[3] <= dout;
                    if(dout_valid || index != 0)
                        res_valid[3] <= 1'b1;
                end
                3'b100: 
                begin
                    res[4] <= dout;
                    if(dout_valid || index != 0)
                        res_valid[4] <= 1'b1;
                end
                3'b101:
                begin
                    res[5] <= dout;
                    if(dout_valid || index != 0)
                        res_valid[5] <= 1'b1;
                end
                3'b110: 
                begin
                    res[6] <= dout;
                    if(dout_valid || index != 0)
                        res_valid[6] <= 1'b1;
                end
                3'b111: 
                begin
                    res[7] <= dout;
                    if(dout_valid || index != 0)
                        res_valid[7] <= 1'b1;
                end
                default:
                    res_valid <= 0;
            endcase
        end    
    end
endmodule