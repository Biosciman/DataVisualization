%% 绘制三维盒子
function box_3D( x, y, z )

% Demo
if( nargin < 1 )
  Demo
  return
end

% Faces
f = [2 3 6;3 7 6;3 4 8;3 8 7;4 5 8;4 1 5;2 6 5;2 5 1;1 3 2;1 4 3;5 6 7;5 7 8];

% Vertices
v = [-x  x  x -x -x  x  x -x;...
     -y -y  y  y -y -y  y  y;...
     -z -z -z -z  z  z  z  z]'/2;

% Default outputs
if( nargout == 0 )
	DrawVertices( v, f, 'Box' );
  clear v
end

function Demo
%% Box>>Demo
% Draw a box

x = 1;
y = 2;
z = 3;
box_3D( x, y, z );