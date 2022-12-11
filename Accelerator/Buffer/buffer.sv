module buffer#(
    parameter DATA_WIDTH = 4,
    parameter BUFFER_SIZE = 4,
    parameter DATA_OF_SET = 4,
    parameter IN_NUM_OF_SET = 4,
    parameter OUT_NUM_OF_SET = 3
)(
    input logic clk,
    input logic rst,
    input logic wen,
    input logic [IN_NUM_OF_SET - 1:0][DATA_OF_SET - 1:0][DATA_WIDTH - 1:0] din,
    output logic full_flag,
    output logic [OUT_NUM_OF_SET - 1:0][DATA_OF_SET - 1:0][DATA_WIDTH - 1:0] dout,
    output logic [OUT_NUM_OF_SET - 1:0] valid
);

    logic [IN_NUM_OF_SET - 1:0] full_flag_tmp;
    logic [IN_NUM_OF_SET - 1:0] empty_flag_tmp;
    logic [IN_NUM_OF_SET - 1:0][DATA_OF_SET - 1:0][DATA_WIDTH - 1:0] dout_tmp;
    logic [IN_NUM_OF_SET - 1:0] ren;
    logic [$clog2(IN_NUM_OF_SET) - 1:0] index;
    logic [$clog2(IN_NUM_OF_SET) - 1:0] index_reg;
    logic [$clog2(IN_NUM_OF_SET) - 1:0] index_after;

    assign full_flag = |full_flag_tmp;
    assign index_after = index + OUT_NUM_OF_SET;

    genvar i;
    generate
        for(i = 0;i < IN_NUM_OF_SET;i++) begin
            ring_buffer #(
                .DATA_WIDTH(DATA_WIDTH),
                .BUFFER_SIZE(BUFFER_SIZE),
                .DATA_OF_SET(DATA_OF_SET)
            ) i_buffer(
                                .clk(clk),
                                .rst(rst),
                                .wen(wen),
                                .ren(ren[i]),
                                .din(din[i]),
                                .full_flag(full_flag_tmp[i]),
                                .empty_flag(empty_flag_tmp[i]),
                                .dout(dout_tmp[i])
            );
            
            assign ren[i] = empty_flag_tmp[i] ? 1'b0 :
                              (index >= index_after) ? 
                              ((i >= index) || (i < index_after)) :  
                              ((i >= index) && (i < index_after));
        end

        for(i = 0;i < OUT_NUM_OF_SET;i++) begin
            assign dout[i] = dout_tmp[(IN_NUM_OF_SET - 1) & (index_reg + i)];
        end                                 
    endgenerate

    // Index for Output
    always_ff @(posedge clk or posedge rst) begin
        if(rst || |empty_flag_tmp) begin
            index <= 0;
            index_reg <= 0;
        end else begin
            index <= index + OUT_NUM_OF_SET;
            index_reg <= index;
        end
    end
    
    integer n;
    
    // Valid
    integer j;
    always_ff @(posedge clk or posedge rst) begin
        for(j = 0;j < OUT_NUM_OF_SET;j++) begin
            if(rst)
                valid[j] <= 1'b0;
            else
                valid[j] <= ren[(IN_NUM_OF_SET - 1) & (index + j)];
        end
    end
    
endmodule