function varargout = max(varargin)
% global, local and pointwise maxima of functions on SO(3)
%
% Syntax
%   [v,pos] = max(SO3F) % the position where the maximum is atained
%
%   [v,pos] = max(SO3F,'numLocal',5) % the 5 largest local maxima
%
%   SO3F = max(SO3F, c) % maximum of a spherical functions and a constant
%   SO3F = max(SO3F1, SO3F2) % maximum of two spherical functions
%   SO3F = max(SO3F1, SO3F2, 'bandwidth', bw) % specify the new bandwidth
%
%   % compute the maximum of a multivariate function along dim
%   SO3F = max(SO3Fmulti,[],dim)
%
% Input
%  SO3F, SO3F1, SO3F2 - @SO3Fun
%  SO3Fmulti          - a multivariate @SO3Fun
%  c                  - double
%
% Output
%  v - double
%  pos - @rotation / @orientation
%
% Options
%  kmax          - number of iterations
%  numLocal      - number of peaks to return
%  startingNodes - @rotation / @orientation
%  tolerance     - minimum distance between two peaks
%  resolution    - minimum step size 
%  maxStepSize   - maximm step size
%

varargin{1} = -varargin{1};
if nargin>1 && ( ~isempty(varargin{2}) && isa(varargin{2},'double') || isa(varargin{2},'SO3Fun' ))
  varargin{2} = -varargin{2};
end

[varargout{1:nargout}] = min(varargin{:});

varargout{1} = - varargout{1};