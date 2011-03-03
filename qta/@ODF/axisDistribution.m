function x = axisDistribution(odf,h,varargin)
% 
%
%
%% Input
%  odf - @ODF
%  h   - @vector3d
%
%% Flags
%  EVEN       - calculate even portion only
%  FOURIER    - use NFSOFT based algorithm
%
%% Output
%  x   - values of the axis distribution
%
%% See also
% ODF/angleDistribution 

% angle discretisation
omega = linspace(-pi,pi,100);
weight = sin(omega./2).^2 ./ length(omega);

% define a grid for quadrature
h = repmat(h(:),1,length(omega));
omega = repmat(omega,size(h,1),1);
S3G = orientation('axis',h,'angle',omega,odf(1).CS,odf(1).SS);

f = eval(odf,S3G,varargin{:});

x = 2 * f * weight(:);
