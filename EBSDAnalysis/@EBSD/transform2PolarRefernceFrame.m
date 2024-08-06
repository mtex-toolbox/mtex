function ebsd = transform2PolarRefernceFrame(ebsd,center,varargin)
% transform orientations within an EBSD map into a polar coordinate system
%
% Syntax
%
%   ebsdPolar = transform2PolarRefernceFrame(ebsd,center)
%
% Input
%  ebsd   - @EBSD
%  center - (x,y) coordinates 
%
% Output
%
%  ebsdPolar - @EBSD
%
% See also
%

if nargin == 1
  center = [mean(ebsd.prop.x(:)),mean(ebsd.prop.y(:))];
end

% compute signed angle of each map position to X with respect to center
% position
v = vector3d(ebsd.prop.x - center(1), ebsd.prop.y - center(2),0);
omega = angle(v,xvector,zvector);

% maybe we need to replace omega by -omega
rot = rotation.byAxisAngle(zvector,omega);

ebsd.rotations = rot .* ebsd.rotations;
ebsd.prop.r    = norm(v);
ebsd.prop.phi  = atan2(v.y,v.y);

end