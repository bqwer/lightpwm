module lightpwm(
  // system
  input clk,

  // sensor
  output sensor_ncs,
  output sensor_scl,
  input  sensor_sda,
  
  // rgb-led
  output led0_r,
  output led0_g,
  output led0_b
);

wire [7:0] sensor_data;
sensor my_sensor (
  .clk(clk),
  .ncs(ncs),
  .scl(scl),
  .sda(sda),
  .data(sensor_data)
);

filter my_filter(
.clk         (clk),
.sensor_data (sensor_data),
.mean_data   (light_intensity)
);

wire [7:0] light_intensity;
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
  .pulse(led0_r)
);

pwm red_pwm(
  .clk(clk),
  .pulse_width(green_intensity),
  .pulse(led0_g)
);

pwm red_pwm(
  .clk(clk),
  .pulse_width(blue_intensity),
  .pulse(led0_b)
);

endmodule

