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

% kernel used for calculation
psi = S2DeLaValleePoussin('halfwidth',...
  get_option(varargin,'zr_halfwidth',2*pf.r.resolution));

% normalization
w = calcDensity(pf.r,S2G,'kernel',psi,'noNormalization');

mw = psi.eval(1);
%w = max(RK(k,quaternion.id,xvector,xvector,1,symmetry,symmetry)*0.25,w);
%plot(S2G,min(w,mw))
  
% c - coefficients
delta = get_option(varargin,'zr_delta',0.01,'double');
bg = get_option(varargin,'zr_bg',delta * max(pf.intensities(:)));
c = (get_option(varargin,'zr_factor',10)*(pf.intensities > bg)-1);
%plot(pf.r,c,'upper')

f = calcDensity(pf.r,S2G,'weights',c,'kernel',psi,'noNormalization');

zr = reshape(w < 0.1*mw | f./w > -0.1,size(S2G));
% plot(S2G,f./w,'upper')
% plot(S2G,zr,'upper')

