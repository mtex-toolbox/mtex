function varargout = min(varargin)
% global, local and pointwise minima of functions on SO(3)
%
% Syntax
%   % global minimum
%   [v,pos] = min(SO3F)
%
%   % local minima
%   [v,pos] = max(SO3F,'numLocal',5) % the 5 smallest local minima
%
%   % pointwise minima
%   SO3F = min(SO3F, c) % pointwise minimum of a SOFun and the constant c
%   SO3F = min(SO3F1, SO3F2) % pointwise minimum of two SOFun
%   SO3F = min(SO3F1, SO3F2, 'bandwidth', bw) % specify the new bandwidth
%
%   % pointwise minima of a multivariate function along dim
%   SO3F = min(SO3Fmulti,[],dim)
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
%  numLocal      - number of local minima to return
%  startingNodes - @rotation / @orientation
%  tolerance     - minimum distance between two peaks
%  resolution    - minimum step size 
%  maxStepSize   - maximm step size
%

varargin{1} = -varargin{1};
if nargin>1 && ( ~isempty(varargin{2}) && isa(varargin{2},'double') || isa(varargin{2},'SO3Fun' ))
  varargin{2} = -varargin{2};
end

[varargout{1:nargout}] = max(varargin{:});

varargout{1} = -varargout{1};