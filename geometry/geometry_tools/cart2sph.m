function [theta,rho,r] = cart2sph(x,y,z)
% cartesian to spherical coordinates
%
%% Description
% transforms cartesian coordiantes to spherical coordinates
%
%% Input
%  x,y,z - cartesian coordinates (double)
%
%% Output
%  theta, tho, radius - spherical coordinates in radians
%
%% See also
% vector3d/polar vector3d/vector3d

if nargout == 2
    rho = atan2(y,x);
    theta = real(acos(z));
else
    r = sqrt(x.^2 + y.^2 + z.^2);
    rho = atan2(y,x);
    theta = real(acos(z./r));
end
