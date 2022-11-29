module ring_buffer#(
    parameter DATA_WIDTH = 32,
    parameter BUFFER_SIZE = 8,
    parameter DATA_OF_SET = 128
)(
    input logic clk,
    input logic rst,
    input logic wen,
    input logic ren,
    input logic [DATA_OF_SET - 1:0][DATA_WIDTH - 1:0] din,
    output logic full_flag,
    output logic empty_flag,
    output logic [DATA_OF_SET - 1:0][DATA_WIDTH - 1:0] dout,
    output logic [BUFFER_SIZE - 1:0] wptr_check, rptr_check
);
    logic [BUFFER_SIZE - 1:0][DATA_OF_SET - 1:0][DATA_WIDTH - 1:0] buffer;
    logic [BUFFER_SIZE - 1:0] wptr, rptr;
    logic full_flag_reg;
    logic empty_flag_reg;

    // Output Assignment
    assign dout = buffer[rptr];

    assign full_flag = full_flag_reg;
    assign empty_flag = empty_flag_reg;

    // Input
    always_ff @(posedge clk) begin
        if(wen && !full_flag)
            buffer[wptr] <= din;
    end

    // Write Pointer & Read Pointer
    always_ff @(posedge clk or posedge rst) begin
        if(rst) begin
            wptr <= 0;
            rptr <= ~0;
        end else begin
            // Write Pointer
            if(wen && !full_flag_reg) begin
                if(wptr == ~0)
                    wptr <= 0;
                else 
                    wptr <= wptr + 1;
            end
            // Read Pointer
            if(ren && !empty_flag) begin
                if(rptr == ~0)
                    rptr <= 0;
                else
                    rptr <= rptr + 1;
            end
        end
    end

    // Full Flag & Empty Flag
    always_ff @(posedge clk or posedge rst) begin
        if(rst) begin
            full_flag_reg <= 0;
            empty_flag <= 0;
        end else begin
            // Full Flag 
            if((wptr == rptr) && wen && !ren)
                full_flag_reg <= 1;
            else if(full_flag_reg && ren)
                full_flag_reg <= 0;
            // Empty Flag
            if((rptr == wptr - 1) && !wen && ren)
                empty_flag_reg <= 1;
            else if(empty_flag_reg && wen)
                empty_flag_reg <= 0;
        end
    end
    assign wptr_check = wptr;
    assign rptr_check = rptr;
endmodule
