%% check SO3Grid/subGrid
%
% compare subGrid function with the max_angle option to SO3Grid
%

cs = symmetry('cubic');
ss = symmetry('tricline')

res = 10*degree;

radius = fliplr(linspace(res,120,20)*degree);

q = SO3Grid(res,cs,ss);

m = GridLength(q);

for i = 1:length(radius)
  f(i) = GridLength(SO3Grid(res,cs,ss,'max_angle',radius(i))) / m;
  %f2(i) = GridLength(subGrid(SO3Grid(res,cs,ss),idquaternion,radius(i))) / m;
  q = subGrid(q,idquaternion,radius(i));
  g(i) = GridLength(q) / m;

end
plot([f',g'])

x = SO3Grid(1000,symmetry('cubic'));
dist(x,idquaternion,'epsilon',20*degree);

q = SO3Grid(res,cs,ss);
q = subGrid(q,idquaternion,50*degree);
q = subGrid(q,idquaternion,20*degree);
