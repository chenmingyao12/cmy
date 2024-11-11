module rgbgray(

input wire  I_rst_n,
input wire  I_pix_clk,
input wire  I_vs,
input wire  I_hs,
input wire  I_de,
input wire [7:0]  I_data_r,
input wire [7:0]  I_data_g,
input wire [7:0]  I_data_b,

output  wire  [7:0]   led_array,
output  wire  [15:0]  led_num
);

reg     [10:0]   cnt_h;
reg     [10:0]   cnt_v;
wire     [2:0]   data_valid;
wire     [10:0]   pix_x;
wire     [10:0]   pix_y;
reg     [9:0]     led_that;
    reg         [2:0]   valid_r   ;//rgb数据有效标志打拍
    reg         [7:0]  r_u       ;//灰度转换运算寄存
    reg         [7:0]  g_u       ;//灰度转换运算寄存
    reg         [7:0]  b_u       ;//灰度转换运算寄存
    reg         [14:0]  u_out     ;//运算和寄存
    reg         [7:0]  u_max     ;//分区最大
    reg [7:0] led_ate [0:359];
parameter H_SYNC  = 10'd100,
          H_BACK  = 10'd80,
          H_VALID = 10'd1280,
          H_TOTAL = 10'd1520;

parameter V_SYNC  = 10'd99,
          V_BACK  = 10'd19,
          V_VALID = 10'd800,
          V_TOTAL = 10'd938;

parameter rgb_num = 10'd53;
integer i;
reg [9:0] num;
//行计数器计数
always @(posedge I_pix_clk or negedge I_rst_n)
  begin
    if(!I_rst_n)
        cnt_h <= 11'd0;
        else if(cnt_h == H_TOTAL - 1'b1)
         cnt_h <= 11'd0;
        else 
            cnt_h <= cnt_h +1'b1;
end
//场计数器计数
always @(posedge I_pix_clk or negedge I_rst_n)
 begin
   if(!I_rst_n)
    cnt_v <= 11'd0;
    else if((cnt_h == H_TOTAL - 1'b1)&&(cnt_v == V_TOTAL - 1'b1))
    cnt_v <= 11'b0;
    else if(cnt_h == H_TOTAL - 1'b1)
    cnt_v <= cnt_v +1'b1;
end
//数组发送计数
always @(posedge I_pix_clk or negedge I_rst_n)
  begin
    if(!I_rst_n)
        led_that <= 10'd0;
        else if(cnt_h == 359)
         led_that <= 10'd0;
        else 
            led_that <= led_that +1'b1;
end
//有效图像信号
assign  data_valid = ((cnt_h >= (H_SYNC+H_BACK))
                        &&(cnt_h <= (H_SYNC+H_BACK+H_VALID-1'b1))
                        &&(cnt_v >= (V_SYNC+V_BACK))
                        &&(cnt_v <= (V_SYNC+V_BACK+V_VALID-1'b1)))
                        ? 1'b1 : 1'b0;
//图像坐标
assign  pix_x = (data_valid == 1'b1) ? (cnt_h - (H_SYNC+H_BACK) ) : 10'b0;
assign  pix_y = (data_valid == 1'b1) ? (cnt_v - (V_SYNC +V_BACK)) : 10'b0;

always @(posedge I_pix_clk or negedge I_rst_n)
begin
   if(!I_rst_n)begin
            r_u <= 15'b0; 
            g_u <= 15'b0; 
            b_u <= 15'b0;
    end
    else if(data_valid == 1'b1)begin 
            r_u <= I_data_r*7'd38; 
            g_u <= I_data_g*7'd75; 
            b_u <= I_data_b*7'd15;
          end
end

//always @(posedge I_pix_clk or negedge I_rst_n)
//begin
//    if(pix_x<53&&pix_y<53&&pix_x>0&&pix_y>0)
//        num <= 10'd1;
//    else if(pix_x>53&&pix_x<106&&pix_y<53)
//        num <= 10'd2;
//    else if(pix_x>106&&pix_x<159&&pix_y<53)
//        num <= 10'd3;
//    else if(pix_y>53&&pix_y<106&&pix_x<53)
//        num <= 10'd25;
//    else if(pix_x>53&&pix_x<106&&pix_y<53)
//        num <= 10'd2;
//end

always @(posedge I_pix_clk or negedge I_rst_n)
begin
    if(!I_rst_n)begin
            u_out <= 14'b0;
            u_max <= 7'b0;
        end 
        else if(data_valid == 1'b1)begin 
            u_out <= r_u + g_u + b_u;
            u_max <= u_out[7 +: 8];
            num <= pix_x/53 + (pix_y/53)*24;
        end             
end
 always @(posedge I_pix_clk) begin
    if(!I_rst_n)begin
        for (i = 0; i < 359; i = i+1) begin 
            led_ate[i] = 7'b0;
        end
        end
       else if (led_ate[num] < u_out[7 +: 8]) begin
            led_ate[num] <= u_out[7 +: 8];
        end 
    end

assign led_num = pix_x;
//assign led_array = led_ate[led_that];
assign led_array = 50;
//assign led_num = 16'd10;
endmodule