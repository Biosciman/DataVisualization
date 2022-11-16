%% 定制二维图
% MATLAB默认是从1开始的
% class()看数据类型

%% Description
% w is optional the defaults are:
%
%  .name      = 'Tree';
%  .width     = 400;
%  .fontName  = 'Times';
%  .fontSize  = 10;
%  .linewidth = 1;
%  .linecolor = 'r';
%

%% Inputs
%   n        {:}    Nodes
%                   .parent	   (1,1) Parent
%                   .name      (1,1) Number of observation
%                   .scan       (1,1) Row number
%   w        (.)    Diagram data structure
%                   .name      (1,:) Tree name
%                   .width     (1,1) Circle width
%                   .fontName  (1,:) Font name
%                   .fontSize  (1,1) Font size
%   update   (1,1)  If entered and true update an existing plot

function TreeDiagram( n, w, update )

persistent figHandle  % persistant为定义持久变量，声明它们的函数为局部变量

% Demo
if( nargin < 1 ) % nargin为函数输入参数数目
  Demo % Demo函数在后面
  return;
end

% Defaults
if( nargin < 2 )
  w = []; % 定义w为struct
end
if( nargin < 3 )
  update = false;
end

if( isempty(w) )
  w.name      = 'Tree';
  w.width     = 1200;
  w.fontName  = 'Times';
  w.fontSize  = 10;
  w.linewidth = 1;
  w.linecolor = 'r';
end


% Find scan range
%----------------
m = length(n); % n为cell格式

scanMin = 1e9;
scanMax = 0;

for k = 1:m
  scanMin = min([scanMin n{k}.scan]); % cell格式，将n{k}.scan传入scanMin
  scanMax = max([scanMax n{k}.scan]);
end

nScans = scanMax - scanMin + 1; % 计算一共多少行

scan = scanMin:scanMax; % scan为double类型

scanID = cell(nScans,1); % cell格式

% Determine which nodes go with which scans
%------------------------------------------
for k = 1:nScans
  for j = 1:m
    if( n{j}.scan == scan(k) )
      scanID{k} = [scanID{k} j]; % cell格式，将j传入scanID{k}，确定每个n在哪一行
    end
  end
end


% Determine the maximum number of circles at the last scan
width = 3*length(scanID{nScans})*w.width;


% Draw the tree
if( ~update ) % ~为计算逻辑 NOT
  figHandle = figure('Name',w.name);
else
  clf(figHandle) % clf为清除当前图像窗口
end

figure(figHandle);
set(figHandle,'color',[1 1 1]); % 修改图片参数，颜色
dY = width/(nScans+2);
y  = (nScans+2)*dY;
set(gca,'ylim',[0 (nScans+1)*dY]);% 修改图片参数，宽度
set(gca,'xlim',[0 width]);% 修改图片参数，长度
for k = 1:nScans
  
  % determine the correct label
  % sprintf将数据格式化为字符串或字符向量，返回结果文本。
  % %d为格式化输出，k为数字传入%d
	label = sprintf('Scan %d',k); 
  
  % 调整字体大小
  text(0,y,label,'fontname',w.fontName,'fontsize',w.fontSize);
  x = 4*w.width;
  for j = 1:length(scanID{k})
    node            = scanID{k}(j);
    [xC,yCT,yCB]    = DrawNode( x, y, n{node}.name, w ); % 调用DrawNode函数
    n{node}.xC      = xC;
    n{node}.yCT     = yCT;
    n{node}.yCB     = yCB;
    x               = x + 3*w.width;
  end
  y = y - dY;
end

% Connect the nodes
for k = 1:m
  if( ~isempty(n{k}.parent) )
    ConnectNode( n{k}, n{n{k}.parent},w ); % 调用ConnectNode函数
  end
end

axis off
axis image

%% TreeDiagram>>DrawNode
% Draw a node.This is a circle with a number in the middle.
function [xC,yCT,yCB] = DrawNode( x0, y0, k, w )

n = 20;
a = linspace(0,2*pi*(1-1/n),n); % linspace生成线性间距向量，从0等2*pi*(1-1/n)的n个等距向量

x = w.width*cos(a)/2 + x0;
y = w.width*sin(a)/2 + y0;
patch(x,y,'w'); % 使用x和y的元素作为每个顶点的坐标，以绘制一个或多个填充多边形区域
text(x0,y0,sprintf('%d',k),'fontname',w.fontName,'fontsize',w.fontSize,'horizontalalignment','center');

xC  = x0;
yCT = y0 + w.width/2;
yCB = y0 - w.width/2;

%% TreeDiagram>>ConnectNode
% Connect a node to its parent
function ConnectNode( n, nP, w )

x = [n.xC nP.xC];
y = [n.yCT nP.yCB];

% 画直线
line(x,y,'linewidth',w.linewidth,'color',w.linecolor);

function Demo
%% TreeDiagram>Demo
% Draws a multi-level tree

k = 1;
%---------------
scan        = 1;
d.parent	= [];
d.name     = 1;
d.scan      = scan;
n{k}        = d; k = k + 1;

%---------------
scan        = 2;

d.parent    = 1;
d.name     = 1;
d.scan      = scan;
n{k}        = d; k = k + 1;

d.parent    = 1;
d.name     = 2;
d.scan      = scan;
n{k}        = d; k = k + 1;

d.parent    = [];
d.name     = 3;
d.scan      = scan;
n{k}        = d; k = k + 1;

%---------------
scan        = 3;

d.parent    = 2;
d.name     = 1;
d.scan      = scan;
n{k}        = d; k = k + 1;

d.parent    = 2;
d.name     = 4;
d.scan      = scan;
n{k}        = d; k = k + 1;

d.parent    = 3;
d.name     = 2;
d.scan      = scan;
n{k}        = d; k = k + 1;

d.parent    = 3;
d.name     = 5;
d.scan      = scan;
n{k}        = d; k = k + 1;

d.parent    = 4;
d.name     = 6;
d.scan      = scan;
n{k}        = d; k = k + 1;

d.parent    = 4;
d.name     = 7;
d.scan      = scan;
n{k}        = d; k = k + 1;


%---------------
scan        = 4;

d.parent    = 5;
d.name     = 1;
d.scan      = scan;
n{k}        = d; k = k + 1;

d.parent    = 6;
d.name     = 8;
d.scan      = scan;
n{k}        = d; k = k + 1;

d.parent    = 6;
d.name     = 4;
d.scan      = scan;
n{k}        = d; k = k + 1;

d.parent    = 7;
d.name     = 2;
d.scan      = scan;
n{k}        = d; k = k + 1;

d.parent    = 7;
d.name     = 9;
d.scan      = scan;
n{k}        = d; k = k + 1;

d.parent    = 9;
d.name     = 10;
d.scan      = scan;
n{k}        = d; k = k + 1;

d.parent    = 10;
d.name     = 11;
d.scan      = scan;
n{k}        = d; k = k + 1;

d.parent    = 10;
d.name     = 12;
d.scan      = scan;
n{k}        = d;

% Call the function with the demo data
TreeDiagram( n )