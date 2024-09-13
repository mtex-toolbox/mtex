function ebsd = transform2PolarRefernceFrame(ebsd,center,varargin)
% transform orientations within an EBSD map into a polar coordinate system
%
% Syntax
%
%   ebsdPolar = transform2PolarRefernceFrame(ebsd,center)
%
% Input
%  ebsd   - @EBSD
%  center - (x,y) coordinates / @vector3d
%
% Output
%
%  ebsdPolar - @EBSD
%
% See also
%

center = vector3d(center);

% compute signed angle of each map position to X with respect to center
% position
v = ebsd.pos - center;
omega = angle(v,xvector,ebsd.N);

% maybe we need to replace omega by -omega
rot = rotation.byAxisAngle(ebsd.N,omega);

ebsd.rotations = rot .* ebsd.rotations;
ebsd.prop.r    = norm(v);
ebsd.prop.phi  = atan2(v.y,y.x);

end