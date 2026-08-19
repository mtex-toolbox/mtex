function gB = plus(gB,v)
% shift grain boundaries in x/y direction
%
% Syntax
%
%   % shift in x direction
%   gB = gB + vector3d(100,200,0)
%
% Input
%  gB - @grainBoundary
%  v  - @vector3d, coordinates of the shift
%
% Output
%  gB - @grainBoundary

if isa(v,'grainBoundary'), [v,gB] = deal(gB,v); end

% allV is a vector3d - it used to be an n x 2 double, which is what the old
% [v.x,v.y] / repmat route here was written for. Against a vector3d that
% route implicitly expands the coordinate arrays into n x 2 and silently
% returns a nonsensical object instead of a translation.
if ~isa(v,'vector3d')
  error('MTEX:shift:invalidShift',...
    'Grain boundaries can only be shifted by a vector3d.');
end

gB.allV = gB.allV + v;
