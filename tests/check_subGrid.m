function check_subGrid(cs,ss)
% check SO3Grid/subGrid
%
% compare subGrid function with the maxAngle option to SO3Grid
%

res = 2.5*degree;

radius = fliplr(linspace(res,120,40)*degree);

q = equispacedSO3Grid(cs,ss,'resolution',res);

m = length(q);
center = axis2quat(xvector+yvector,0*degree);

progress(0,length(radius));
for i = 1:length(radius)  
  
  S3G = equispacedSO3Grid(cs,ss,'center',center,...
    'maxAngle',radius(i),'resolution',res);
  f(i) = length(S3G) / m; %#ok<AGROW>
  q = subGrid(q,center,radius(i));
  g(i) = length(q) / m; %#ok<AGROW>
  progress(i,length(radius));
  
end

plot(radius/degree,[f',g'])

return

x = SO3Grid(1000,crystalSymmetry('cubic'));
dist(x,quaternion.id,'epsilon',20*degree);

q = SO3Grid(res,cs,ss);
q = subGrid(q,quaternion.id,50*degree);
q = subGrid(q,quaternion.id,20*degree);

%

cs = crystalSymmetry('m-3m');
ss = specimenSymmetry('mmm');

center = axis2quat(xvector,25*degree);
S3G = SO3Grid(2*degree,cs,ss);
q1 = subGrid(S3G,center,20*degree,'exact')
q2 = subGrid(S3G,center,20*degree)

%

d1 = subGrid(S3G,center,20*degree,'exact')
d2 = subGrid(S3G,center,20*degree)

%
