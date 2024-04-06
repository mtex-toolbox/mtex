function [v,x] = min(fun,varargin)
% global, local and pointwise maxima of periodic functions
%
% Syntax
%   [v,pos] = min(sF) % the position where the minimum is atained
%
%   [v,pos] = min(sF,'numLocal',5) % the 5 largest local minima
%
%   sF = min(sF, c) % minimum of a spherical functions and a constant
%   sF = min(sF1, sF2) % minimum of two spherical functions
%   sF = min(sF1, sF2, 'bandwidth', bw) % specify the new bandwidth
%
%   % compute the minimum of a multivariate function along dim
%   sF = min(sFmulti,[],dim)
%
% Input
%  sF, sF1, sF2 - @S1Fun
%  sFmulti - a multivariate @S1Fun
%  c       - double
%
% Output
%  v   - double
%  pos - double
%
% Options
%  kmax          - number of iterations
%  numLocal      - number of peaks to return
%  startingNodes - double
%  tolerance     - minimum distance between two peaks
%  resolution    - minimum step size 
%  maxStepSize   - maximm step size
%

% pointwise minimum of two functions
if ( nargin > 1 ) && ( isa(varargin{1}, 'S1Fun') )
  f = @(v) min(fun.eval(v), varargin{1}.eval(v));
  v = S1FunHarmonic.quadrature(f);

% pointwise minimum of function and constant
elseif ( nargin > 1 ) && ~isempty(varargin{1}) && ( isa(varargin{1}, 'double') )
  f = @(v) min(fun.eval(v), varargin{1});
  v = S1FunHarmonic.quadrature(f);
  
elseif isscalar(fun)

  [v, x] = steepestDescent(fun, varargin{:});
  
else
  s = size(fun);
  if nargin < 2
    d = find(s ~= 1); % first non-singelton dimension
  else
    d = varargin{2};
  end
  f = @(v) min(fun.eval(v), [], d(1)+1);
  v = S1FunHarmonic.quadrature(f);

end

end
