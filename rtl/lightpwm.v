`timescale 1ns/1ps
module lightpwm(
  // system
  input clk,

  // sensor
  output ncs,
  output sck,
  input  sdo,
  
  
  // rgb-led
  output led_r,
  output led_g,
  output led_b

  `ifdef SIM
  ,output [3:0] dbg_led,
  ,output [7:0] dbg_data
  ,input        dbg_sw,
  `endif
);

wire [7:0] sensor_data;
sensor my_sensor (
  .clk(clk),
  .ncs(ncs),
  .sck(sck),
  .sdo(sdo),
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

`ifdef SIM
assign dbg_data = sensor_data;
assign dbg_led = dbg_sw? sensor_data[7:4] :
                         sensor_data[3:0];
`endif

endmodule

