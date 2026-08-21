function tP = plus(tP,v)
% shift triple points in x/y direction
%
% Syntax
%
%   % shift in x direction
%   tP = tP + vector3d(100,200,0)
%
% Input
%  tP - @triplePointList
%  v  - @vector3d, coordinates of the shift
%
% Output
%  tP - @triplePointList

if isa(v,'triplePointList'), [v,tP] = deal(tP,v); end

% V is a vector3d, an n x 2 double would expand its coordinate arrays
if ~isa(v,'vector3d')
  error('MTEX:shift:invalidShift',...
    'Triple points can only be shifted by a vector3d.');
end

tP.V = tP.V + v;
