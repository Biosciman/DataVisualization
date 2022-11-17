%% 绘制三维盒子

% 第一个function要与文件名相同
function box_3D( x, y, z )
disp('Running: box_3D')
% Demo
if( nargin < 1 )
  Demo
  return; % return满足if条件后不再向下执行的语句
end

% 构建面的结构，然后根据顶点的坐标进行缩放
% Faces
% 盒子6面，每面2个三角，共12个三角，8个顶点
f = [2 3 6;3 7 6;3 4 8;3 8 7;4 5 8;4 1 5;2 6 5;2 5 1;1 3 2;1 4 3;5 6 7;5 7 8];

% Vertices
v = [-x  x  x -x -x  x  x -x;...
     -y -y  y  y -y -y  y  y;...
     -z -z -z -z  z  z  z  z]'/2;

% Default outputs
% nargout函数输出参数数目
if( nargout == 0 )
	DrawVertices( v, f, 'Box' );
  clear v
end


function DrawVertices( v, f, name )
disp('Running: DrawVertices')
if( nargin < 3 )
  name = 'Vertices';
end

figure('Name',name)
% patch接受参数对以指定面和边缘的着色以及许多其他特征。
% 一个patch块只能指定一种颜色。如果想要一个不同颜色的盒子，那么需要用到多个图形块。
% f为面顶点，v为要连接的顶点，[0.8 0.1 0.2]为颜色
patch('vertices',v,'faces',f,'facecolor',[0.8 0.1 0.2]);
% axis设置坐标轴范围和纵横比
% axis tight 将坐标轴显示的框调整到显示数据最紧凑的情况
% axis equal 等比例显示x，y坐标轴
% axis image能够同时实现紧凑以及xy比例一致两个功能。
axis image
xlabel('x')
ylabel('y')
zlabel('z')
% view为相机视线
view(3)
% grid显示或隐藏坐标区网格线
grid on
% rotate3d使用鼠标旋转三维视图
rotate3d on

function Demo
disp('Running: Demo')
%% Box>>Demo
% Draw a box
% 长宽高是1、2、3
x = 1;
y = 2;
z = 3;

% Call the function with the demo data
box_3D( x, y, z );




