function zr = calcZeroRange(pf,S2G,varargin)
% calculate zero range
%
% Input
%  pf  - @PoleFigure
%  S2G - @S2Grid
%
% Output
%  zr  - logical
%
% Options
% 
%
% See also
% PoleFigure/calcODF

% transform in polar coordinates -> output nodes
r  = [fft_rho(S2G.rho(:)),fft_theta(S2G.theta(:))].';

% kernel used for calculation
k = deLaValeePoussinKernel('halfwidth',...
  get_option(varargin,'zr_halfwidth',2*pf.r.resolution));

% legendre coefficents
Al = k.A; Al(2:2:end) = 0;
Al = Al(1:min(400,length(Al)));

% in - nodes to become r
gh = [fft_rho(pf.r.rho(:)),fft_theta(pf.r.theta(:))].';

% normalization
c = ones(size(pf.intensities));
w = call_extern('odf2pf','EXTERN',gh,r,c,Al);
mw = k.RK(1);
%w = max(RK(k,idquaternion,xvector,xvector,1,symmetry,symmetry)*0.25,w);
%plot(S2G,min(w,mw))
  
% c - coefficients
delta = get_option(varargin,'zr_delta',0.01,'double');
bg = get_option(varargin,'zr_bg',delta * max(pf.intensities(:)));
c = (get_option(varargin,'zr_factor',10)*(pf.intensities > bg)-1);
%plot(pf.r,c,'upper')

f = call_extern('odf2pf','EXTERN',gh,r,c,Al);
zr = reshape(w < 0.1*mw | f./w > -0.1,size(S2G));
% plot(S2G,f./w,'upper')
% plot(S2G,zr,'upper')

