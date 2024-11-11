  module ramflag_1(
    input clk,   // 25Mclk
    input rst_n,
    input [15:0] led,
    input [10:0] ate,
    output  sdbpflag_wire,
    output  [15:0] wtdina_wire,
    output  [9:0] wtaddr_wire
);
reg [11:0] cnt;  //用于延迟1250个dclk 等待配置寄存器时间。
reg [30:0] cnt1; //用于周期性发送sdbpflag信号，可以设置cnt1长度修改发送sdbpflag信号时间间隔
reg [9:0] cnt2;  // 用于每帧暂存时间
reg [13:0]  cnt3;  // 每一轮addr自加+1 当addr=cnt3时点亮对应位置的灯珠
reg flag= 'd0; //标志配置寄存器结束，可以发送sdbp数据了;
reg sdbpflag;
reg [15:0]wtdina;
reg [9:0]wtaddr;
reg [7:0]led_array [0:359];
wire [15:0] data;
assign sdbpflag_wire = sdbpflag;
assign wtdina_wire = wtdina;
assign wtaddr_wire = wtaddr;
//cnt记满后视为配置寄存器完毕
always @(posedge clk or negedge rst_n)   
 begin
    if(!rst_n)
        begin
            flag <= 0;
            cnt <= 0;
            
        end
    else if(cnt < 2500)
    begin
        flag <= 0;
        cnt <= cnt + 1;
    end
    else if(cnt == 2500)
    begin
        flag <= 1;
    end
end

//cnt1用来计数sdbpflag的周期
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        cnt1 <= 0;
    else if(cnt1 >= 420_000)begin
        cnt1 <= 0;
    end
    else
        cnt1 <= cnt1 + 1;
end
//cnt2用来计数流水灯状态下每颗灯点亮的持续时间
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        begin
            cnt2 <= 0;
        end
    else if(cnt1 == 0 && flag)
            begin 
//  cnt2是一颗灯保持亮的速率
                if(cnt2 == 19)
                    begin
                        cnt2 <= 0;
                    end
                else 
                    begin
                        cnt2 <= cnt2 + 1;
                    end
            end
end
//cnt3用来计数点亮灯珠的位置
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)begin
        cnt3 <= 0;
    end
    else if(cnt1 == 1 && cnt2 == 0 && flag)begin
        if(cnt3 >= 359)begin
            cnt3 <= 0;
        end
        else begin
            cnt3 <= cnt3 + 1;
        end
    end
end
//以下always块作用为控制输出信号
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        sdbpflag <= 0;
    else if(cnt1 == 1 && flag)begin
        sdbpflag <= 1;
    end
    else if(cnt1 == 30 && flag)begin
        sdbpflag <= 0;  
    end
end
always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)begin
        wtaddr <= 0;
    end
    else if(cnt1 == 3) begin
        wtaddr <= 0;
    end 
    else if (cnt1 > 4 && cnt1 <=4+360 && flag)begin//cnt1:5-364 wtaddr:1-360
        wtaddr <= wtaddr + 1;
    end
    else if(cnt1 > 4+360) begin
        wtaddr <= 0; 

    end
end

//分区背光
//always @(posedge clk or negedge rst_n)
//begin
//    if(!rst_n)
//        wtdina <= 0;
//    else if(flag)begin
//        wtaddr <= ate;
//        wtdina <= 16'hfff;
//       end
//    else    
//            wtdina <= 0;
//end
//流水灯 换显示形式时把此always块注释掉
//always@(posedge clk or negedge rst_n)
//  begin
//      if(!rst_n)
//          wtdina <= 0;
//      else if(wtaddr==cnt3&&flag)
//              wtdina <= 16'hfff;
//      else
//          wtdina <= 0;
//  end
//全亮 换显示形式时把此always块注释掉
 always@(posedge clk or negedge rst_n)
 begin
     if(!rst_n)begin
         wtdina <= 0;
     end
     else if(cnt1>3&&cnt1<=364&&flag)begin
         //wtdina <= 16'hFFFF ; 
          wtdina <= led;
     end
     else
         wtdina <= 0;
 end
// 1/3全亮度 1/3一半亮度 1/3暗 换显示形式时把此always块注释掉
// always@(posedge clk or negedge rst_n)begin 
//     if(!rst_n)begin
//         wtdina <= 0;    
//     end 
//     else if(wtaddr%24==0 || (wtaddr-1)%24==0 || (wtaddr-2)%24==0 || (wtaddr-3)%24==0 || (wtaddr-4)%24==0 || (wtaddr-5)%24==0 ||(wtaddr-6)%24==0 || (wtaddr-7)%24==0)
//         wtdina <= 16'hffff;
//         else if((wtaddr-8)%24==0 || (wtaddr-9)%24==0 || (wtaddr-10)%24==0 || (wtaddr-11)%24==0||(wtaddr-12)%24==0 || (wtaddr-13)%24==0 || (wtaddr-14)%24==0 || (wtaddr-15)%24==0)
//             wtdina <= 16'h0100;
//     else
//     wtdina <= 0;
// end 
//亮固定某一个灯珠 换显示形式时把此always块注释掉
// always@(posedge clk or negedge rst_n)begin 
// if(!rst_n)begin
//         wtdina <= 0;
//     end 
// else if(wtaddr == 23)begin//wtaddr == x代表第x+1颗灯
//         wtdina <= 16'hffff;
//     end 
// else begin
//         wtdina <= 0;
//     end
// end 


endmodule