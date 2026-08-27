function [rhoMin,rhoMax] = rhoIntervals(sR,theta,rhoWindow)
% all intervals of the azimuth angle that belong to the spherical region
%
% Syntax
%
%   [rhoMin,rhoMax] = rhoIntervals(sR,theta)
%   [rhoMin,rhoMax] = rhoIntervals(sR,theta,rhoWindow)
%
% Input
%  sR        - @sphericalRegion
%  theta     - polar angles
%  rhoWindow - [rhoMin,rhoMax] the azimuth angles are searched in
%
% Output
%  rhoMin - nInt × numel(theta), padded with NaN
%  rhoMax - nInt × numel(theta), padded with NaN
%
% Description
% This is the counterpart of <sphericalRegion.thetaIntervals.html
% thetaIntervals> with the roles of the two angles exchanged. Which of the
% two decomposes a region into fewer strips depends on its shape - a sector
% that is cut open at its corners in azimuth direction has a single
% interval per polar angle and vice versa.
%
% See also
% sphericalRegion/thetaIntervals

if nargin < 3 || isempty(rhoWindow), rhoWindow = [0,2*pi]; end

% antipodal should not increase the spherical region
sR.antipodal = false;

theta = reshape(theta,1,[]);

% on the circle of latitude theta the bounding circle i is crossed where
%
%   A cos(rho) + B sin(rho) = alpha - Nz cos(theta),  A = Nx sin(theta), B = Ny sin(theta)
A = sR.N.x(:) * sin(theta);
B = sR.N.y(:) * sin(theta);

psi = atan2(B,A);
c = (sR.alpha(:) - sR.N.z(:) * cos(theta)) ./ hypot(A,B);
c(~(abs(c) <= 1)) = NaN; % the circle misses this latitude, or A = B = 0

ac = acos(c);
breaks = [psi + ac; psi - ac];

% both branches repeat with a period of 2*pi
breaks = [breaks;breaks + 2*pi;breaks - 2*pi];

[rhoMin,rhoMax] = intervalsFromBreaks(sR,breaks,rhoWindow(1),rhoWindow(2),theta,...
  @(rho,theta) vector3d.byPolar(theta,rho));

end
