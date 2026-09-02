function x = calcAxisDistribution(S3F,varargin)
% axis distribution function
%
% Syntax
%
%   value = calcAxisDistribution(odf, a)
%   adf = calcAxisDistribution(odf)
%
%   % only rotations by 20 to 40 degree
%   adf = calcAxisDistribution(odf,'minAngle',20*degree,'maxAngle',40*degree)
%
% Input
%  S3F - orientation or misorientation distribution function, @SO3Fun
%  a   - rotational axis, @vector3d
%
% Output
%  afd   - axis distribution function, @S2Fun
%  value - value of axis distribution function for rotational axis a
%
% Options
%  minAngle   - ignore rotations by less than this angle
%  maxAngle   - ignore rotations by more than this angle
%  resolution - step of the angle quadrature, 2.5 degree by default
%
% Description
% By default the rotation angle is integrated over the full range the
% fundamental region allows for the axis in question. |minAngle| and
% |maxAngle| restrict that range, which is what the axis angle sections
% show: the distribution of the axes of those rotations whose angle falls
% into a given window. An axis for which the window lies entirely outside
% the fundamental region contributes zero.
%
% The quadrature keeps its step, not its number of points, so a narrow
% window is integrated with correspondingly few of them - lower
% |resolution| if the values it returns matter to better than a percent.
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

[omegaMin,omegaMax] = angleWindow(oR,project2FundamentalRegion(h,dcs),varargin{:});
omegaMin = omegaMin(:); width = omegaMax(:) - omegaMin;

res = get_option(varargin,'resolution',2.5*degree);
nOmega = max(2,round(max(width(:))/res));

% define a grid for quadrature
omega = linspace(0,1,nOmega);
omega = omegaMin + width * omega(:).';
h = repmat(h(:),1,nOmega);
S3G = orientation.byAxisAngle(h,omega,S3F.CS,S3F.SS);

% quadrature weights
weights = sin(omega./2).^2 ./ nOmega;

% eval ODF
f = eval(S3F,S3G,varargin{:});

% sum along axes
x = 2*nSym / pi * sum(f .* weights,2) .* width;
