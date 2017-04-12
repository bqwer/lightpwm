`timescale 1ns/1ps
module color (
  input  [7:0] light_intensity,

  output [7:0] red_pwm,
  output [7:0] green_pwm,
  output [7:0] blue_pwm
);

assign red_pwm = 8'h80 - light_intensity >> 2;
assign green_pwm = light_intensity;
assign blue_pwm = light_intensity >> 1;

endmodule

