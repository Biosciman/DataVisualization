% PlotSet用于生成二维图
% command + T 取消注释代码

fprintf('Hello world!\n')

x = linspace(1,1000);
y = [sin(0.01*x);cos(0.01*x);cos(0.03*x)];

subplot(4,1,1); % 创建子图，4行，1列，此子图在第一个位置
plot(x,y); % 二维线图
subplot(4,1,2); 
bar(x,y); % 条形图
subplot(4,1,3);
barh(x,y); % 条形图，与上一张横纵坐标相反
ax4 = subplot(4,1,4);
pie(y) % 饼图
colormap(ax4,'default')
get(gca) % 返回图片属性，一个巨大的列表
set(gca,'YminorGrid','on','YGrid','on') % set更改图片属性
