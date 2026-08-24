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

% allV is a vector3d, an n × 2 double would expand its coordinate arrays
if ~isa(v,'vector3d')
  error('MTEX:shift:invalidShift',...
    'Grain boundaries can only be shifted by a vector3d.');
end

gB.allV = gB.allV + v;
