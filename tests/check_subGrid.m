function check_subGrid(cs,ss)
% check SO3Grid/subGrid
%
% compare subGrid function with the max_angle option to SO3Grid
%

res = 2.5*degree;

radius = fliplr(linspace(res,120,40)*degree);

q = SO3Grid(res,cs,ss);

m = numel(q);
center = axis2quat(xvector+yvector,0*degree);

progress(0,length(radius));
for i = 1:length(radius)  
  
  f(i) = numel(...
    SO3Grid(res,cs,ss,'center',center,'max_angle',radius(i))) / m; %#ok<AGROW>
  q = subGrid(q,center,radius(i));
  g(i) = numel(q) / m; %#ok<AGROW>
  progress(i,length(radius));
  
end

plot(radius/degree,[f',g'])

return

x = SO3Grid(1000,symmetry('cubic'));
dist(x,idquaternion,'epsilon',20*degree);

q = SO3Grid(res,cs,ss);
q = subGrid(q,idquaternion,50*degree);
q = subGrid(q,idquaternion,20*degree);

%%

cs = symmetry('m-3m');
ss = symmetry('mmm');

center = axis2quat(xvector,25*degree);
S3G = SO3Grid(2*degree,cs,ss);
q1 = subGrid(S3G,center,20*degree,'exact')
q2 = subGrid(S3G,center,20*degree)

%%

d1 = subGrid(S3G,center,20*degree,'exact')
d2 = subGrid(S3G,center,20*degree)

%%
