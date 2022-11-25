module buffer#(
    parameter DATA_WIDTH = 32,
    parameter BUFFER_DEPTH = ,
    parameter NUM_OF_MUL = ,
    parameter DATA_OF_SET = 128,
    parameter NUM_OF_SET = 1,
)(
    input logic clk,
    input logic rst,
    input logic wen,
    input logic ren,
    input logic [DATA_OF_SET - 1:0][DATA_WIDTH - 1:0] indata,
    output logic full_flag,
    output logic empty_flag,
    output logic [NUM_OF_MUL - 1:0][DATA_WIDTH - 1:0] outdata
);

    logic [(BUFFER_DEPTH * NUM_OF_MUL) - 1:0] wp, rp;


    // Reset
    always_ff @(posedge clk or posedge rst) begin
        if(rst) begin

        end
    end
endmodule