module test(input logic a,
            input logic b,
            input logic clk,
            input logic rst,
            output logic y);

    always @(posedge clk or posedge rst) begin
        if(rst) begin
            y <= 1'b0;
        end else begin
            y <= a + b;
        end
    end
endmodule