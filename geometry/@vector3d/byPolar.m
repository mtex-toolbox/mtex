function v = byPolar(polarAngle,azimuthAngle,varargin)
% define vector3d by polar angles
%
% Syntax
%   v = vector3d.byPolar(polarAngle,azimuthAngle)
%
% Input
%  polarAngle   - angle to the north pole in radiant
%  azimuthAngle - angle to the x axis when projected into the x/y plane in radiant
%
% Output
%  v - @vector3d
%
% Flags
%  antipodal - include antipodal symmetry
%
  
x = sin(polarAngle) .* cos(azimuthAngle);
y = sin(polarAngle) .* sin(azimuthAngle);
z = cos(polarAngle) .* ones(size(azimuthAngle));

v = vector3d(x,y,z,varargin{:});
v.isNormalized = true;

end
