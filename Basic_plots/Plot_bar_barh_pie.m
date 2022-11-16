% 使用 NewFigure 函数创建一个图形窗口
figure('Name','Plot Types');
x = linspace(0,10,10);
y = rand(1,10);

% 使用subplot以减少图形数目
subplot(4,1,1) % 二维线图(4,1,1);4行，1列，此子图在第1个位置
plot(x,y); 
subplot(4,1,2);
bar(x,y); % 二维垂直条形图
subplot(4,1,3);
barh(x,y); % 二维水平条形图
ax4 = subplot(4,1,4);
pie(y) % 饼图
colormap(ax4,'default') % default可以改为gray