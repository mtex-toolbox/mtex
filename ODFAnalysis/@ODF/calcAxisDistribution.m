function x = calcAxisDistribution(odf,h,varargin)
% compute the axis distribution of an ODF or MDF
%
% Input
%  odf - @ODF
%  h   - @vector3d
%
% Options
%  smallesAngle - use axis corresponding to the smalles angle
%  largestAngle - use axis corresponding to the largest angle
%  allAngles    - use all axes
%
% Output
%  x   - values of the axis distribution
%
% See also

[oR,dcs,nSym] = fundamentalRegion(odf.CS,odf.SS,varargin{:});
maxOmega = oR.maxAngle(project2FundamentalRegion(h,dcs));
res = get_option(varargin,'resolution',2.5*degree);
nOmega = round(max(maxOmega(:))/res);

% define a grid for quadrature
omega = linspace(0,1,nOmega);
omega = maxOmega(:) * omega(:).'; 
h = repmat(h(:),1,nOmega);
S3G = orientation('axis',h,'angle',omega,odf.CS,odf.SS);

% quadrature weights
weights = sin(omega./2).^2 ./ nOmega;

% eval ODF
f = eval(odf,S3G,varargin{:}); %#ok<EVLC>

% sum along axes
x = 2*nSym / pi * sum(f .* weights,2) .* maxOmega(:);
