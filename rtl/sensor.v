module sensor #(
  parameter MAX_SCL=24
) (
  input            clk,
  output           ncs,
  output           sck,
  input            sdo,
  output reg [7:0] data
);

reg [4:0] bods;
reg [1:0] state;
localparam start = 2'b01;
localparam main  = 2'b10;
localparam quiet = 2'b11;

always @(posedge clk) begin
  case(state)
    start: if ((sck == MAX_SCL) && sck) state <= main;
    main: begin
      if (bods == 5'd16) state <= quiet;
      else               state <= main;
    end
    quiet: begin
      if (bods == 5'd2) state <= start;
      else              state <= quiet;
    end
    default: state <= start;
  endcase
end

reg [7:0] sck_div;
always @(posedge clk) begin
  if (sck_div == MAX_SCL) sck_div <= 8'h00;
  else                    sck_div <= sck_div + 1'b1;
end

reg sck_source;
initial sck_source = 1'b0;
always @(posedge clk) begin
  if (sck_div == MAX_SCL)
    sck_source <= ~sck_source;
end
assign sck = (state == quiet)? 1'b1 : sck_source;

always @(posedge clk) begin
  if ((bods == 5'd16) | (state == start))
    bods <= 5'd0;
  else if (~sck_source && (sck_div == MAX_SCL))
    bods <= bods + 1'b1;
end

reg [15:0] receive;
always @(posedge clk) begin
  if ((state == main) && (sck_div == MAX_SCL) && (~sck))
    receive <= {receive[14:0],sdo}; 
end

always @(posedge clk) begin
  if(state==start) data <= receive[12:5];
end

assign ncs = (state == quiet);

endmodule
