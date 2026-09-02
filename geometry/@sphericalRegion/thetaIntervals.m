function [thetaMin,thetaMax] = thetaIntervals(sR,rho)
% all intervals of the polar angle that belong to the spherical region
%
% Syntax
%
%   [thetaMin,thetaMax] = thetaIntervals(sR,rho)
%
% Input
%  sR  - @sphericalRegion
%  rho - azimuth angles
%
% Output
%  thetaMin - nInt × numel(rho), padded with NaN
%  thetaMax - nInt × numel(rho), padded with NaN
%
% Description
% In contrast to |thetaRange|, which returns only the hull
% [min(theta),max(theta)], this returns every connected component. Since a
% spherical region is bounded by small circles, the polar angles belonging
% to a fixed azimuth angle need not form a single interval - the axis
% sectors of a misorientation fundamental region close to the maximum angle
% are cut open at the corners of the sector, e.g. for the point group 23.
%
% See also
% plotS2Grid sphericalRegion/thetaRange

% antipodal should not increase the spherical region
sR.antipodal = false;

rho = reshape(rho,1,[]);

% along the meridian rho the bounding circle i is crossed where
%
%   a sin(theta) + Nz cos(theta) = alpha,   a = Nx cos(rho) + Ny sin(rho)
a = sR.N.x(:) * cos(rho) + sR.N.y(:) * sin(rho);
b = repmat(sR.N.z(:),1,numel(rho));

phi = atan2(b,a);
c = sR.alpha(:) ./ hypot(a,b);
c(abs(c) > 1) = NaN;  % the circle misses this meridian

as = asin(c);
breaks = [as - phi; pi - as - phi];

% both branches repeat with a period of 2*pi
breaks = [breaks;breaks + 2*pi;breaks - 2*pi];

[thetaMin,thetaMax] = intervalsFromBreaks(sR,breaks,rho);

end
