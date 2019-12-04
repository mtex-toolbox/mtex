function x = calcAxisDistribution(odf,varargin)
% compute the axis distribution of an ODF or MDF
%
% Syntax
%
%   value = calcAxisDistribution(odf)
%   adf = calcAxisDistribution(odf, a)
%
% Input
%  odf - @ODF orientation or misorientation distribution function
%  a   - @vector3d rotational axis
%
% Output
%  afd - @S2Fun axis distribution function
%  value - value of axis distribution function for rotational axis a
%
% See also
% symmetry/calcAxisDistribution

[oR,dcs,nSym] = fundamentalRegion(odf.CS,odf.SS,varargin{:});

if nargin == 1 || ~isa(varargin{1},'vector3d')
  adf = @(h) calcAxisDistribution(odf,h,varargin{:});
  x = S2FunHarmonicSym.quadrature(adf,dcs,'bandwidth',64,varargin{:});
  return
end

h = varargin{1};

maxOmega = oR.maxAngle(project2FundamentalRegion(h,dcs));
res = get_option(varargin,'resolution',2.5*degree);
nOmega = round(max(maxOmega(:))/res);

% define a grid for quadrature
omega = linspace(0,1,nOmega);
omega = maxOmega(:) * omega(:).'; 
h = repmat(h(:),1,nOmega);
S3G = orientation.byAxisAngle(h,omega,odf.CS,odf.SS);

% quadrature weights
weights = sin(omega./2).^2 ./ nOmega;

% eval ODF
f = eval(odf,S3G,varargin{:}); 

% sum along axes
x = 2*nSym / pi * sum(f .* weights,2) .* maxOmega(:);
