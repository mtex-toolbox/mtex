function ori = discreteSample(odf,npoints,varargin)
% evaluate an odf at orientation g
%

% take random polar angles
M = 1000000;                   % discretisation parameter
t = linspace(-1,1,M);
c = cumsum(odf.psi.RK(t)) / M; % cumulative distribution function

[~,~,t] = histcounts(rand(npoints,1),[c,inf]);
theta = acos((t-0.5) ./ M);
  
% take random azimuthal angles
rho   = 2*pi*rand(npoints,1);

% take random position on the sphere
angle = 2*pi*rand(npoints,1);

q0 = hr2quat(odf.h,odf.r);

ori =  orientation(axis2quat(odf.r,rho) .* axis2quat(orth(odf.r),theta) ...
  .* axis2quat(odf.r,angle) .* q0, odf.CS, odf.SS);
