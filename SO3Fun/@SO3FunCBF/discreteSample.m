function ori = discreteSample(SO3F,npoints,varargin)
% evaluate an odf at orientation g
%

% take random polar angles
M = 1000000;                   % discretisation parameter
t = linspace(-1,1,M);
c = cumsum(SO3F.psi.eval(t)) / M; % cumulative distribution function

[~,t] = histc(rand(npoints,1),c);
theta = acos(t ./ M);
  
% take random azimuthal angles
rho   = 2*pi*rand(npoints,1);

% take random position on the sphere
angle = 2*pi*rand(npoints,1);

q0 = hr2quat(SO3F.h,SO3F.r);

ori =  orientation(axis2quat(SO3F.r,rho) .* axis2quat(orth(SO3F.r),theta) ...
  .* axis2quat(SO3F.r,angle) .* q0, SO3F.CS, SO3F.SS);

% random symmetry elements
ori = ori .* SO3F.CS.rot(randi(SO3F.CS.numSym,length(ori),1));
if SO3F.SS.numSym>1
  ori = SO3F.SS.rot(randi(SO3F.SS.numSym,length(ori),1)) .* ori;
end