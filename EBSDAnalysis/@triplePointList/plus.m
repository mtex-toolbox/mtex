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

% V is a vector3d - it used to be an n x 2 double, which is what the old
% [v.x,v.y] / repmat route here was written for. Against a vector3d that
% route implicitly expands the coordinate arrays into n x 2 and silently
% returns a nonsensical object instead of a translation.
if ~isa(v,'vector3d')
  error('MTEX:shift:invalidShift',...
    'Triple points can only be shifted by a vector3d.');
end

tP.V = tP.V + v;
