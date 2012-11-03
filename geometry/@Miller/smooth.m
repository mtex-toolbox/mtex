function varargout = smooth(m,varargin)
% plot Miller indece
%
%% Input
%  m  - Miller
%
%% Options
%
%% See also
% vector3d/smooth

% get axis hande
[ax,m,varargin] = getAxHandle(m,varargin{:});

% define plotting grid
[minTheta,maxTheta,minRho,maxRho] = get(m,'bounds',varargin{:}); %#ok<ASGLU>
out = S2Grid('PLOT','MAXTHETA',maxTheta,'MAXRHO',maxRho,'MINRHO',minRho,...
  'RESTRICT2MINMAX',varargin{:});

% symmetrise data
x = symmetrise(m,'skipAntipodal');

% perform kernel density estimation
kde = kernelDensityEstimation(x,out,varargin{:});

% use vector3d/smooth for output
[varargout{1:nargout}] = smooth(ax{:},out,kde,varargin{:});
