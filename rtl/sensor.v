module my_sensor #(
  parameter MAX_SCL=24
) (
  input        clk,
  output reg   ncs,
  output reg   scl,
  input        sda,
  output [7:0] data
)

reg [4:0] bods;
reg [1:0] state;
localparam start = 2'b01;
localparam main  = 2'b10;
localparam quiet = 2'b11;

always @(posedge clk) begin
  case (state) begin
    start: state <= main;
    main: begin
      if (bods == 5'd16) state <= quiet;
      else               state <= main;
    end
    quiet: begin
      if (bods == 5'd3) state <= start;
      else              state <= quiet;
    end
    default: state <= start;
  endcase
end

reg [7:0] scl_div;
always @(posedge clk) begin
  if (scl_div == MAX_SCL) scl_div <= 8'h00;
  else                    scl_div <= scl_div + 1'b1;
end

always @(posedge clk) begin
  if (rst)                scl <= 1'b0;
  if (scl_div == MAX_SCL) scl <= ~scl;
end

always @(posedge clk) begin
  if ((bods == 5'd16) | (state == start))
    bods <= 5'd0;
  else if (~scl && (scl_div == MAX_SCL))
    bods <= bods + 1'b1;
end

endmodule
