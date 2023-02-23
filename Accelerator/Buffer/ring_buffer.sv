module ring_buffer#(
    parameter DATA_WIDTH = 4,
    parameter BUFFER_SIZE = 4,
    parameter DATA_OF_SET = 4
)(
    input logic                                                     clk,
    input logic                                                     rst,
    input logic                                                     wen,
    input logic                                                     ren,
    input logic [DATA_OF_SET - 1:0][DATA_WIDTH - 1:0]               din,
    output logic                                                    full_flag,
    output logic                                                    empty_flag,
    output logic [DATA_OF_SET - 1:0][DATA_WIDTH - 1:0]              dout
);

    logic [BUFFER_SIZE - 1:0][DATA_OF_SET - 1:0][DATA_WIDTH - 1:0]  buffer;
    logic [$clog2(BUFFER_SIZE) - 1:0]                               wptr, rptr;


    // Output Assignment
    assign dout = buffer[rptr];

    // Full Flag & Empty Flag
    assign full_flag = (rptr == wptr);
    assign empty_flag = (rptr == (wptr - 1'b1));

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
            if(wen && !full_flag) begin
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

endmodule