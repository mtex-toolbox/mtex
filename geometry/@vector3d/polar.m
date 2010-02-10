function [theta,rho,r] = polar(v)
% cartesian to spherical coordinates
%% Input
%  v - @vector3d
%% Output
%  theta, rho, radius

if isa(v,'vector3d')
    if nargout == 3
        r = sqrt(v.x.^2 + v.y.^2 + v.z.^2);
        rho = atan2(v.y,v.x);
        theta = acos(v.z./r);
    elseif nargout >= 1
        r = sqrt(v.x.^2 + v.y.^2 + v.z.^2);
        rho =  atan2(v.y,v.x);
        theta = acos(v.z./r);
    else
        hr = sqrt(v.x.^2 + v.y.^2 + v.z.^2);
        hrho =  atan2(v.y,v.x);
        htheta = acos(v.z./hr);
        disp(['polar angle = ',xnum2str(reshape(htheta,1,[])/degree),mtexdegchar]);
        disp(['azimuth     = ',xnum2str(reshape(hrho,1,[])/degree),mtexdegchar]);
    end
else
    error('argument should be of type vector3d');
end
