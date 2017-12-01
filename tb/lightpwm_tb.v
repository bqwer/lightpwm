`timescale 1ns/1ps
module lightpwm_tb();

`define SIM

reg clk;
wire sck, ncs, sdo;
wire led_r,led_g,led_b;
lightpwm uut (
  .clk   (clk),
  .ncs   (ncs),
  .sdo   (sdo),
  .sck   (sck),
  .led_r (led_r),
  .led_g (led_g),
  .led_b (led_b)
);

initial begin
  $dumpfile("lightpwm.vcd");
  $dumpvars;
  #10000
  $finish;
end

initial begin
  clk = 0;
  forever #1 clk <= ~clk;
end

reg sck_q = 1'b1;
reg [15:0] sens_data;
assign sdo = sens_data[15];
always @(posedge clk) begin
  if (ncs) begin
    sens_data = $urandom;
    sens_data[15:12] = 4'b0000;
    sens_data[3:0]   = 4'b0000;
  end
  else begin
    sck_q <= sck;
    if (sck_q & ~sck)
      sens_data <= sens_data << 1;
  end
end

endmodule
