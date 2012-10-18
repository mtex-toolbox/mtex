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

o = extract_option(m,'antipodal');

% define plotting grid
[maxtheta,maxrho,minrho] = getFundamentalRegionPF(m.CS,o{:},varargin{:});
out = S2Grid('PLOT','MAXTHETA',maxtheta,'MAXRHO',maxrho,'MINRHO',minrho,...
  'RESTRICT2MINMAX',o{:},varargin{:});

% symmetrise data
x = symmetrise(m,'skipAntipodal');

% perform kernel density estimation
kde = kernelDensityEstimation(x,out,varargin{:});

% use vector3d/smooth for output
[varargout{1:nargout}] = smooth(ax{:},out,kde,varargin{:});
