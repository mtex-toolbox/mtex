function sF = calcDensity(v,out,varargin)
% calculate a density function out of (weighted) unit vectors
%
% Syntax
%
%   sF = calcDensity(v)
%   sF = calcDensity(v,[],'weights',w)
%   sF = calcDensity(v,[],'halfwidth',delta)
%   sF = calcDensity(v,[],'kernel',psi)
%    f = calcDensity(v,S2G)
%
% Input
%  v   - sampling points for density estimation @vector3d
%  S2G - @vector3d
%  w   - weights, default is all one
%  delta - halfwidth of the kernel, default is 10 degree
%  psi - @kernel function, default is de la Vallee Poussin
%
% Output
%  sF  - @sphFun
%  S2G - @vector3d
%
% Options
%  halfwidth - halfwidth of a kernel
%  kernel    - specify a kernel
%  weights   - vector of weights, with same length as v
%

if nargin == 1 || isempty(out)
  out = equispacedS2Grid('points',10000);
  generateFun = true;
else
  generateFun = false;
end

% parse some input 
if isempty(v)
  sF = zeros(size(out));
  return
end

hw = get_option(varargin,'halfwidth',10*degree);
psi = get_option(varargin,'kernel',deLaValeePoussinKernel('halfwidth',hw));
c = get_option(varargin,'weights',ones(length(v),1));
c = c./sum(c);

% evaluate density
in_theta = fft_theta(v.theta);
in_rho   = fft_rho(v.rho);
out_theta= fft_theta(out.theta);
out_rho  = fft_rho(out.rho);

gh = [in_rho(:),in_theta(:)].';
r = [out_rho(:),out_theta(:)].';
	
% extract legendre coefficents
Al = psi.A;
if check_option(varargin,'antipodal') || v.antipodal || ...
    out.antipodal
  Al(2:2:end) = 0;
end
bw = get_option(varargin,'bandwidth',length(Al));
Al = Al(1:min(bw,length(Al)));
  
sF = call_extern('odf2pf','EXTERN',gh,r,c,Al);

% TODO: generate sphFunHarmonic
if generateFun, sF = sphFunTri(reshape(out,[],1),sF); end