module filter (
  input        clk,
  input  [7:0] sensor_data,
  output [7:0] mean_data
);

reg [15:0] filter;
assign mean_data = filter[15:9];
always @(posedge clk) begin
  if      (sensor_data > mean_data) filter <= filter + 1'b1;
  else if (sensor_data < mean_data) filter <= filter - 1'b1;
end

endmodule
