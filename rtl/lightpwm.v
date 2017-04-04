module lightpwm(
  // system
  input clk,

  // sensor
  output sensor_ncs,
  output sensor_scl,
  input  sensor_sda,
  
  // rgb-led
  output led_r,
  output led_g,
  output led_b
);

wire [7:0] sensor_data;
sensor my_sensor (
  .clk(clk),
  .ncs(ncs),
  .scl(scl),
  .sda(sda),
  .data(sensor_data)
);

wire [7:0] light_intensity;
filter my_filter(
.clk         (clk),
.sensor_data (sensor_data),
.mean_data   (light_intensity)
);

wire [7:0] red_intensity;
wire [7:0] green_intensity;
wire [7:0] blue_intensity;
color my_color(
  .light_intensity (light_intensity),
  .red_pwm         (red_intensity),
  .green_pwm       (green_intensity),
  .blue_pwm        (blue_intensity)
);

pwm red_pwm(
  .clk(clk),
  .pulse_width(red_intensity),
  .pulse(led_r)
);

pwm green_pwm(
  .clk(clk),
  .pulse_width(green_intensity),
  .pulse(led_g)
);

pwm blue_pwm(
  .clk(clk),
  .pulse_width(blue_intensity),
  .pulse(led_b)
);

endmodule

