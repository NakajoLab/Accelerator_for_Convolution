module for_output#(
    parameter DATA_WIDTH = 4,
    parameter KERNEL_SIZE = 9,
    parameter NUM_OF_MUL = 14,
    parameter DATA_OF_SET = 128,
    parameter OUT_NUM_OF_SET = 3
)(
    input logic clk,
    input logic rst,
    input logic [OUT_NUM_OF_SET - 1:0] adder_valid, 
    input logic [(NUM_OF_MUL * OUT_NUM_OF_SET) - 1:0][DATA_WIDTH - 1:0] dout_tmp,
    output logic [DATA_OF_SET - 1:0][DATA_WIDTH - 1:0] dout,
    output logic dout_valid
);

    logic [$clog2(KERNEL_SIZE) - 1:0] index;
    logic [1:0][KERNEL_SIZE - 1:0][NUM_OF_MUL - 1:0][DATA_WIDTH - 1:0] dout_buf;
    logic [OUT_NUM_OF_SET - 2:0][NUM_OF_MUL - 1:0][DATA_WIDTH - 1:0] dout_tmp_over; 
    logic [OUT_NUM_OF_SET - 2:0] dout_tmp_over_valid;
    logic dout_buf_flag;

    // index & dout_buf_flag & dout_valid
    always_ff @(posedge clk or posedge rst) begin // If you change OUT_NUM_OF_SET, you must this bit width.
        if(rst) begin
            index <= 1'b0;
            dout_buf_flag <= 1'b0;
            dout_valid <= 1'b0;
        end else if(adder_valid == ($pow(2, OUT_NUM_OF_SET) - 1)) begin
            if(index == (KERNEL_SIZE - OUT_NUM_OF_SET)) begin
                index <= 2'b00;
                dout_valid <= 1'b1;
                dout_buf_flag <= ~dout_buf_flag;
            end else if(index == (KERNEL_SIZE - OUT_NUM_OF_SET + 2'b01)) begin
                index <= 2'b01;
                dout_valid <= 1'b1;
                dout_buf_flag <= ~dout_buf_flag;
            end else if(index == (KERNEL_SIZE - OUT_NUM_OF_SET + 2'b10)) begin
                index <= 2'b10;
                dout_valid <= 1'b1;
                dout_buf_flag <= ~dout_buf_flag;
            end else begin
                index <= index + 2'b11;
                dout_valid <= 1'b0;
            end 
        end else if((adder_valid == 3'b011) || (adder_valid == 3'b101) || (adder_valid == 3'b110)) begin
            if(index == (KERNEL_SIZE - OUT_NUM_OF_SET + 2'b01)) begin
                index <= 2'b00;
                dout_valid <= 1'b1;
                dout_buf_flag <= ~dout_buf_flag;
            end else if(index == (KERNEL_SIZE - OUT_NUM_OF_SET + 2'b10)) begin
                index <= 2'b01;
                dout_valid <= 1'b1;
                dout_buf_flag <= ~dout_buf_flag;
            end else begin
                index <= index + 2'b10;
                dout_valid <= 1'b0;
            end
        end else if((adder_valid == 3'b001) || (adder_valid == 3'b010) || (adder_valid == 3'b100)) begin
            if(index == (KERNEL_SIZE - OUT_NUM_OF_SET + 2'b10)) begin
                index <= 2'b00;
                dout_valid <= 1'b1;
                dout_buf_flag <= ~dout_buf_flag;
            end else begin
                index <= index + 2'b01;
                dout_valid <= 1'b0;
            end
        end
    end

    // dout_buf
    always_ff @(posedge clk or posedge rst) begin
        case(adder_valid)
            ($pow(2, OUT_NUM_OF_SET) - 1):  if(index == KERNEL_SIZE - OUT_NUM_OF_SET + 2'b01) begin // index = 7
                                                dout_buf[dout_buf_flag][index] <= dout_tmp[NUM_OF_MUL - 1:0];
                                                dout_buf[dout_buf_flag][index + 2'b01] <= dout_tmp[NUM_OF_MUL * 2 - 1:NUM_OF_MUL];
                                                dout_buf[~dout_buf_flag][0] <= dout_tmp_over[0];
                                            end else if(index == KERNEL_SIZE - OUT_NUM_OF_SET + 2'b10) begin // index = 8
                                                dout_buf[dout_buf_flag][index] <= dout_tmp[NUM_OF_MUL - 1:0];
                                                dout_buf[~dout_buf_flag][0] <= dout_tmp_over[0];
                                                dout_buf[~dout_buf_flag][1] <= dout_tmp_over[1];
                                            end else begin
                                                dout_buf[dout_buf_flag][index] <= dout_tmp[NUM_OF_MUL - 1:0];
                                                dout_buf[dout_buf_flag][index + 2'b01] <= dout_tmp[NUM_OF_MUL * 2 - 1:NUM_OF_MUL];
                                                dout_buf[dout_buf_flag][index + 2'b10] <= dout_tmp[NUM_OF_MUL * 3 - 1:NUM_OF_MUL * 2];
                                            end
            3'b110: if(index == KERNEL_SIZE - OUT_NUM_OF_SET + 2'b10) begin // index = 8
                        dout_buf[dout_buf_flag][index] <= dout_tmp[NUM_OF_MUL * 2 - 1:NUM_OF_MUL];
                        dout_buf[~dout_buf_flag][0] <= dout_tmp_over[0];
                    end else begin
                        dout_buf[dout_buf_flag][index] <= dout_tmp[NUM_OF_MUL * 2 - 1:NUM_OF_MUL];
                        dout_buf[dout_buf_flag][index + 2'b01] <= dout_tmp[NUM_OF_MUL * 3 - 1:NUM_OF_MUL * 2];
                    end
            3'b101: if(index == KERNEL_SIZE - OUT_NUM_OF_SET + 2'b10) begin // index = 8
                        dout_buf[dout_buf_flag][index] <= dout_tmp[NUM_OF_MUL - 1:0];
                        dout_buf[~dout_buf_flag][0] <= dout_tmp_over[0];
                    end else begin
                        dout_buf[dout_buf_flag][index] <= dout_tmp[NUM_OF_MUL - 1:0];
                        dout_buf[dout_buf_flag][index + 2'b01] <= dout_tmp[NUM_OF_MUL * 3 - 1:NUM_OF_MUL * 2];
                    end
            3'b011: if(index == KERNEL_SIZE - OUT_NUM_OF_SET + 2'b10) begin // index = 8
                        dout_buf[dout_buf_flag][index] <= dout_tmp[NUM_OF_MUL - 1:0];
                        dout_buf[~dout_buf_flag][0] <= dout_tmp_over[0];
                    end else begin
                        dout_buf[dout_buf_flag][index] <= dout_tmp[NUM_OF_MUL - 1:0];
                        dout_buf[dout_buf_flag][index + 2'b01] <= dout_tmp[NUM_OF_MUL * 2 - 1:NUM_OF_MUL];
                    end
            3'b100: dout_buf[dout_buf_flag][index] <= dout_tmp[NUM_OF_MUL * 3 - 1:NUM_OF_MUL * 2];
            3'b010: dout_buf[dout_buf_flag][index] <= dout_tmp[NUM_OF_MUL * 2 - 1:NUM_OF_MUL];
            3'b001: dout_buf[dout_buf_flag][index] <= dout_tmp[NUM_OF_MUL - 1:0];
        
        endcase 
    end
    
    assign dout_tmp_over_valid[0] = ((adder_valid == ($pow(2, OUT_NUM_OF_SET) - 1)) ||
                                    (adder_valid == 3'b110) || 
                                    (adder_valid == 3'b101) || 
                                    (adder_valid == 3'b011)) && (index + 2'b10 > KERNEL_SIZE);
    assign dout_tmp_over_valid[1] = (adder_valid == ($pow(2, OUT_NUM_OF_SET) - 1)) && (index + 2'b10 == KERNEL_SIZE + 1);
    
    assign dout_tmp_over[0] = ((adder_valid == ($pow(2, OUT_NUM_OF_SET) - 1) && (index + 2'b11 == KERNEL_SIZE + 1)) ||
                                (adder_valid == 3'b110) || 
                                (adder_valid == 3'b101)) ? dout_tmp[NUM_OF_MUL * 3 - 1:NUM_OF_MUL * 2] : 
                              ((adder_valid == ($pow(2, OUT_NUM_OF_SET) - 1) && (index + 2'b10 == KERNEL_SIZE + 1)) ||
                                (adder_valid == 3'b011)) ? dout_tmp[NUM_OF_MUL * 2 - 1:NUM_OF_MUL] : 1'b0;
    
    assign dout_tmp_over[1] = (adder_valid == ($pow(2, OUT_NUM_OF_SET) - 1) && (index + 2'b10 == KERNEL_SIZE + 1)) ? dout_tmp[NUM_OF_MUL * 3 - 1:NUM_OF_MUL * 2] : 1'b0;

    // dout
    genvar i;
    generate
        for(i = 0;i < KERNEL_SIZE;i++) begin
            assign dout[((NUM_OF_MUL * (i + 1)) - 1):NUM_OF_MUL * i] = dout_valid ? dout_buf[~dout_buf_flag][i] : 1'b0;
        end
    endgenerate

    assign dout[DATA_OF_SET - 1] = 1'b0;
    assign dout[DATA_OF_SET - 2] = 1'b0;  
endmodule