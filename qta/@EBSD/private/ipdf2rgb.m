function c = ipdf2rgb(h,cs,varargin)
% converts orientations to rgb values

% convert the polar coordinates
[theta,rho] = polar(h);
rho = mod(rho,2*pi);

% compute colors
[e1,maxtheta,maxrho] = getFundamentalRegion(cs,symmetry,varargin{:});
%maxrho = max(rho(:));
%maxtheta = max(theta(:));
d(:,:,1) = mod(rho,2*pi) ./ maxrho;
d(:,:,2) = min(pi/2,theta) ./min(maxtheta,pi/2);
d(:,:,3) = 1 - max(0,2*theta./pi-1);
c = hsv2rgb(d);
