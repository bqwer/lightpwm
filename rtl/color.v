module color (
  input  [7:0] light_intensity,

  output [7:0] red_pwm,
  output [7:0] green_pwm,
  output [7:0] blue_pwm
);

assign red_pwm = light_intensity;
assign green_pwm = 8'hFF - light_intensity;
assign blue_pwm = 8'hF0 + light_intensity;

endmodule

