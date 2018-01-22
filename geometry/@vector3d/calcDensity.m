function sF = calcDensity(v,varargin)
% calculate a density function out of (weighted) unit vectors
%
% Syntax
%
%   sF = calcDensity(v)
%   sF = calcDensity(v,'weights',w)
%   sF = calcDensity(v,'halfwidth',delta)
%   sF = calcDensity(v,'kernel',psi)
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
%  sF  - @S2Fun
%   f  - function values
%
% Options
%  halfwidth - halfwidth of a kernel
%  kernel    - specify a kernel
%  weights   - vector of weights, with same length as v
%

% determine kernel function
hw = get_option(varargin,'halfwidth',10*degree);
psi = get_option(varargin,'kernel',deLaValeePoussinKernel('halfwidth',hw));

if getMTEXpref('extern',false)

  % legendre coefficents
  if check_option(varargin,'antipodal') || v.antipodal
    Al = psi.A; Al(2:2:end) = 0;
  end
  Al = Al(1:min(400,length(Al)));

  % out - nodes to become r
  r  = [fft_rho(varargin{1}.rho(:)),fft_theta(varargin{1}.theta(:))].';

  % in - nodes to become gh
  gh = [fft_rho(v.rho(:)),fft_theta(v.theta(:))].';

  % normalization
  c = get_option(varargin,'weights',ones(length(v),1));
  
  % normalize
  if ~check_option(varargin,'noNormalization')
    c = c ./ sum(c(:));
  end
  
  sF = call_extern('odf2pf','EXTERN',gh,r,c,Al);
  
else
  
  sF = 4*pi * S2FunHarmonic.quadrature(v,ones(size(v)),varargin{:});

  % normalize
  if ~check_option(varargin,'noNormalization')
    sF = sF ./ sF.fhat(1);
  end

  %
  sF = conv(sF,psi);

  % if required compute function values
  if nargin > 1 && isa(varargin{1},'vector3d')
    sF = sF.eval(varargin{1});
  end
end