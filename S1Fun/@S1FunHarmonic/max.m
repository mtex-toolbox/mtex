function varargout = max(varargin)
% global, local and pointwise maxima of periodic functions
%
% Syntax
%   [v,pos] = max(fun) % the position where the maximum is atained
%
%   [v,pos] = max(fun,'numLocal',5) % the 5 largest local maxima
%
%   fun = max(fun, c) % maximum of a spherical functions and a constant
%   fun = max(fun1, fun2) % maximum of two spherical functions
%   fun = max(fun1, fun2, 'bandwidth', bw) % specify the new bandwidth
%
%   % compute the maximum of a multivariate function along dim
%   fun = max(funmulti,[],dim)
%
% Input
%  fun, fun1, fun2 - @S1Fun
%  funmulti - a multivariate @S1Fun
%  c        - double
%
% Output
%  v - double
%  pos - @double
%
% Options
%  kmax          - number of iterations
%  numLocal      - number of peaks to return
%  startingNodes - @vector3d
%  tolerance     - minimum distance between two peaks
%  resolution    - minimum step size 
%  maxStepSize   - maximm step size
%

varargin{1} = -varargin{1};
if nargin>1 && ( ~isempty(varargin{2}) && isa(varargin{2},'double') || isa(varargin{2},'S1Fun' ))
  varargin{2} = -varargin{2};
end

[varargout{1:nargout}] = min(varargin{:});

varargout{1} = - varargout{1};

end