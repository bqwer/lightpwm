module lightpwm_tb();

reg clk;
reg sdo;
wire sck;
wire led_r,led_g,led_b;
lightpwm uut (
  .clk   (clk),
  .cs    (cs),
  .sdo   (sdo),
  .sck   (sck),
  .led_r (led_r),
  .led_g (led_g),
  .led_b (led_b)
);

endmodule
