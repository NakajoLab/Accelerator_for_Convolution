module buffer#(
    parameter DATA_WIDTH = 32,
    parameter BUFFER_SIZE = 8,
    parameter KERNEL_SIZE = 9,
    parameter NUM_OF_MUL = 16,
    parameter DATA_OF_SET = 128,
    parameter INPUTNUM_OF_SET = 1,
    parameter OUTPUTNUM_OF_SET = 1
)(
    input logic clk,
    input logic rst,
    input logic wen,
    input logic [INPUTNUM_OF_SET - 1:0][DATA_OF_SET - 1:0][DATA_WIDTH - 1:0] din,
    output logic full_flag,
    output logic [INPUTNUM_OF_SET - 1:0][DATA_OF_SET - 3:0][DATA_WIDTH - 1:0] dout
);
    logic [INPUTNUM_OF_SET - 1:0][BUFFER_SIZE - 1:0][DATA_OF_SET - 1:0][DATA_WIDTH - 1:0] buffer;
    logic [INPUTNUM_OF_SET - 1:0] full_flag_reg;
    logic [INPUTNUM_OF_SET - 1:0][BUFFER_SIZE - 1:0] wptr, rptr;
    logic carry_wptr;
    logic carry_rptr;
    logic next_wptr;
    logic next_rptr;
    logic [INPUTNUM_OF_SET - 1:0] dout_ctrl; // どこからdoutにoutputさせるか

    // Output Assignment

    assign full_flag = |full_flag_reg;

    genvar i;
    generate
    for(i = 0;i < OUTPUTNUM_OF_SET;i++) begin
        assign dout[i] = buffer[dout_ctrl + i][rptr];
    end
    endgenerate

    always_ff @(posedge clk or posedge rst) begin
        if(rst)
            dout_ctrl <= 0;
        else 
            dout_ctrl <= dout_ctrl + OUTPUTNUM_OF_SET;
    end

    integer j;
    // Input
    always_ff @(posedge clk) begin
        for(j=0;j<INPUTNUM_OF_SET;j++) begin
            buffer[j][wptr[j]] <= din[j];
        end
    end

    // Write Pointer & Read Pointer
    always_ff @(posedge clk or posedge rst) begin
        for(j=0;j<INPUTNUM_OF_SET;j++) begin
            if(rst) begin
                wptr <= 0;
                rptr <= ~0;
            end
            else if(wen && !full_flag_reg[j])
                wptr <= wptr + 1;
            else if(!empty_flag_reg)
                rptr <= rptr + 1;
        end
    end

    // Full Flag
    always_ff @(posedge clk or posedge rst) begin
        if(rst)
            full_flag_reg <= 0;
        else begin
            // 次のクロックでwptrがrptrを超える場合
            if(()               
                full_flag_reg <= 1;
            else if(full_flag_reg && ) // 解消されたらフラグ戻す
                full_flag_reg <= 0;
        end
    end

    // Almost Empty Flag
    assign almost_empty_flag = ((rptr == (wptr - 1)) || ((rptr == ~0) && (wptr == 1)) || ((rptr == ~0 - 1) && wptr == 0))? 1 : 0;
    // Empty Flag
    always_ff @(posedge clk or posedge rst) begin
        if(rst)
            empty_flag_reg <= 1;
        else begin
            if(almost_empty_flag && !wen && ren)
                empty_flag_reg <= 1;
            else if(empty_flag_reg && wen)
                empty_flag_reg <= 0;
        end
    end
endmodule