module pwm (
  input       clk,
  input [7:0] pulse_width,
  output      pulse);

reg [7:0] main_count;

pulse_max = (pulse_width == 8'hFF);
pulse_min = (pulse_width == 8'h00);
wire period_ok = !(pulse_max || pulse_min);
reg  pulse_reg;

always @(posedge clk) begin
  if (period_ok) main_count <= main_count + 1'b1;

  if   (main_count == pulse_width) pulse_reg <= 1'b0;
  else (main_count == 8'hFF)       pulse_reg <= 1'b1;
end

assign pulse = period_ok? pulse_reg :
               pulse_max? 1'b1 :
               pulse_min? 1'b0;  

endmodule

