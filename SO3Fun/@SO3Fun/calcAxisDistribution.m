function x = calcAxisDistribution(S3F,varargin)
% axis distribution function
%
% Syntax
%
%   value = calcAxisDistribution(odf, a)
%   adf = calcAxisDistribution(odf)
%
% Input
%  S3F - orientation or misorientation distribution function, @SO3Fun
%  a   - rotational axis, @vector3d
%
% Output
%  afd   - axis distribution function, @S2Fun
%  value - value of axis distribution function for rotational axis a
%
% See also
% symmetry/calcAxisDistribution

[oR,dcs,nSym] = fundamentalRegion(S3F.CS,S3F.SS,varargin{:});

if nargin == 1 || ~isa(varargin{1},'vector3d')
  adf = @(h) calcAxisDistribution(S3F,h,varargin{:});
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
S3G = orientation.byAxisAngle(h,omega,S3F.CS,S3F.SS);

% quadrature weights
weights = sin(omega./2).^2 ./ nOmega;

% eval ODF
f = eval(S3F,S3G,varargin{:}); 

% sum along axes
x = 2*nSym / pi * sum(f .* weights,2) .* maxOmega(:);
