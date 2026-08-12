function tP = minus(tP,v)
% shift triple points in x/y direction
%
% Syntax
%
%   % shift in x direction
%   tP = tP - vector3d(100,200,0)
%
% Input
%  tP - @triplePointList
%  v  - @vector3d, coordinates of the shift
%
% Output
%  tP - @triplePointList

tP = tP + (-v);
