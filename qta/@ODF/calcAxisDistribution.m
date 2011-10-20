function x = calcAxisDistribution(odf,h,varargin)
% compute the axis distribution of an ODF or MDF
%
%
%% Input
%  odf - @ODF
%  h   - @vector3d
%
%% Flags
%  EVEN       - calculate even portion only
%  FOURIER    - use NFSOFT based algorithm (not yet implemented)
%
%% Output
%  x   - values of the axis distribution
%
%% See also

res = get_option(varargin,'resolution',2.5*degree);

% angle discretisation
omega = -pi:res:pi;
weight = sin(omega./2).^2 ./ length(omega);

% define a grid for quadrature
h = repmat(h(:),1,length(omega));
omega = repmat(omega,size(h,1),1);
S3G = orientation('axis',h,'angle',omega,odf(1).CS,odf(1).SS);

f = eval(odf,S3G,varargin{:}); %#ok<EVLC>

x = 2 * f * weight(:);
