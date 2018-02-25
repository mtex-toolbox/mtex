function v =  eval(sVF,nodes)
%
% Syntax
%   v = eval(sFV,nodes)
%
% Input
%  sFV - @S2VectorField
%  nodes - interpolation nodes @vector3d
%
% Output
%  v - @vector3d
%

% compute bariocentric coordinates for interpolation
bario = calcBario(sVF.tri,nodes);

% interpolate in the space of symmetric 3x3 matrixes
[x,y,z] = double(sVF.values);
m = [x(:).*x(:),x(:).*y(:),y(:).*y(:),x(:).*z(:),y(:).*z(:),z(:).*z(:)];
M = bario * m;

% go back to vectors by computing the eigen vectors of the interpolated 3x3
% matrices
[v,~] =  eig3(M(:,1),M(:,2),M(:,4),M(:,3),M(:,5),M(:,6));

% take only the largest eigenvector
v = v(3,:).';

end
