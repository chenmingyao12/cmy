module graw2(
input   I_rst_n,
input   I_de,
input   clk,  
input   [7:0] I_data_r,
input   [7:0] I_data_g,
input   [7:0] I_data_b,
input   pix_clk,
input   clock_word,
input   reset_sync,

output   reg [9:0] data,
output   reg [15:0] gray
);
reg     [10:0]   cnt_h;
reg     [10:0]   cnt_v;
reg     [9:0]    num;
reg     [15:0]    gray_array [0:359];
reg         [14:0]  r_u       ;//灰度转换运算寄存
reg         [14:0]  g_u       ;//灰度转换运算寄存
reg         [14:0]  b_u       ;//灰度转换运算寄存
reg         [15:0]  u_out     ;
reg         [15:0]  u_max     ;
//灰度转化储存
always@(posedge pix_clk or posedge reset_sync )
begin
                if(reset_sync == 1'b1) 
                    begin
                        r_u <= 15'b0;
                        g_u <= 15'b0;
                        b_u <= 15'b0;
                    end 
                else if(clock_word && I_de == 1'b1)
                    begin   
                r_u <= I_data_r*7'd35; 
                g_u <= I_data_g*7'd75; 
                b_u <= I_data_b*7'd15;
                    end
                else
                    begin
                        r_u <= 15'b0;
                        g_u <= 15'b0;
                        b_u <= 15'b0;
                    end 
            
end

//像素行列计数
always@(posedge pix_clk or posedge reset_sync  )
begin
          
                if(reset_sync == 1'b1) 
                    begin
                        cnt_h <= 10'b0;
                        cnt_v <= 10'b0;
                    end 
                else if(clock_word && I_de == 1'b1)
                    begin   
                        cnt_h <= cnt_h + 1;
                        if(cnt_h == 10'd1279)
                            begin
                                cnt_v <= cnt_v+1;
                            end
                    end
                else if(I_de == 1'b0)
                    begin
                        cnt_h <= 10'b0;
                        if(cnt_v == 10'd799)
                        begin
                            cnt_v <= 10'b0;
                        end
                    end 
        
end

//数组存储灰度数据
integer i;
always@(posedge pix_clk or posedge reset_sync  )
begin
        
    if(reset_sync == 1'b1) 
        begin
                        num <= 10'b0;
                        u_out <= 16'b0;
                        u_max <= 16'b0;
                        for(i=0;i<360;i = i+1)
                          begin
                            gray_array[i] <= 7'b0;
                            end
                    end 
                else if(clock_word && I_de == 1'b1)
                    begin   
                        u_out <= r_u+g_u+b_u;
                        num <= cnt_h/53 + (cnt_v/53)*24;

                           if(gray_array[num] < u_out)
                            gray_array [num] <= u_out;
                            //else gray_array [num] <= gray_array[num];
                    end
                
            
end

//数组数据输出计数
reg [10:0]  num1;
always @(posedge clk or negedge I_rst_n)
begin
    if(!I_rst_n )
      begin
        num1 <= 0;
        end
    else begin
           data = num1;
        gray = gray_array [num1];
        if(num1 >= 359)
            begin
            num1 <= 0;
            end
        else num1 <= num1 +1;
    end
end

//assign data = num1;
//assign gray = cnt_h;
//assign gray = gray_array [num1];

endmodule