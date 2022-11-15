module tb_test();
    logic clk, rst;
    logic a, b;
    wire y;
    test dut(.a(a), .b(b), .clk(clk), .rst(rst), .y(y));

    initial begin
    $dumpfile("tb_test.vcd");
    $dumpvars(0, tb_test);
    end

    always begin
        #1 clk <= ~clk;
    end

    initial begin
        a = 0; b = 0; rst = 1; clk = 0; #10;
        rst = 0; #10;
        a = 1; #10;
        b = 1; #10;
        $display("%d", y);
        $finish(2);
    end
endmodule