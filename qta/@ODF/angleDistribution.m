function [x,omega] = angleDistribution(odf,varargin)
% 
%
%
%% Input
%  odf - @ODF
%  omega - list of angles
%
%% Flags
%  EVEN       - calculate even portion only
%  FOURIER    - use NFSOFT based algorithm
%
%% Output
%  x   - values of the axis distribution
%
%% See also

% get resolution
res = get_option(varargin,'resolution',2.5*degree);

% define a grid for quadrature
S3G = SO3Grid(res,odf(1).CS,odf(1).SS);
angles = angle(S3G);

% get omega
omega = 0:2*res:max(angles);
omega = get_option(varargin,'omega',omega);

% bin rotational angles
[n,bin] = histc(angles,omega);

% evaluate ODF
f = eval(odf,S3G,varargin{:});

% sort to bins
x = zeros(size(omega));
for i=1:length(omega)
  x(i) = sum(f(bin==i))./numel(S3G)*length(omega);
end
