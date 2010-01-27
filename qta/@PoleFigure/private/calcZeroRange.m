function zr = calcZeroRange(pf,S2G,varargin)
% calculate zero range
%
%% Input
%  pf  - @PoleFigure
%  S2G - @S2Grid
%
%% Output
%  zr  - logical
%
%% Options
% 
%
%% See also
% PoleFigure/calcODF

% transform in polar coordinates -> output nodes
[out_theta,out_rho] = polar(S2G);
out_theta= fft_theta(out_theta);
out_rho  = fft_rho(out_rho);
r  = [reshape(out_rho,1,[]);reshape(out_theta,1,[])];

% kernel used for calculation
k = kernel('de la Vallee Poussin','halfwidth',...
  get_option(varargin,'zr_halfwidth',2*getResolution(getr(pf))),varargin{:});

% legendre coefficents
Al = getA(k); Al(2:2:end) = 0;
Al = Al(1:min(400,length(Al)));

% in - nodes to become r
[in_theta,in_rho] = polar(pf.r);
in_theta = fft_theta(in_theta);
in_rho   = fft_rho(in_rho);
gh = [reshape(in_rho,1,[]);reshape(in_theta,1,[])];
  
% normalization
c = ones(size(pf.data));
w = call_extern('odf2pf','EXTERN',gh,r,c,Al);
mw = RK(k,idquaternion,xvector,xvector,1,symmetry,symmetry);
%w = max(RK(k,idquaternion,xvector,xvector,1,symmetry,symmetry)*0.25,w);
%plot(S2G,'data',min(w,mw))
  
% c - coefficients
delta = get_option(varargin,'zr_delta',0.01,'double');
bg = get_option(varargin,'zr_bg',delta * max(pf.data(:)));
c = (get_option(varargin,'zr_factor',10)*(pf.data > bg)-1);
%plot(pf.r,'data',c)

f = call_extern('odf2pf','EXTERN',gh,r,c,Al);
zr = reshape(w < 0.1*mw | f./w > -0.1,size(S2G));
% plot(S2G,'data',min(f,1))
% plot(S2G,'data',zr)

