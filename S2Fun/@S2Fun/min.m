function [v,f] = min(sF, varargin)
% global, local and pointwise minima of spherical functions
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
%  sF, sF1, sF2 - @S2Fun
%  sFmulti - a multivariate @S2Fun
%  c       - double
%
% Output
%  v - double
%  pos - @vector3d
%
% Options
%  kmax          - number of iterations
%  numLocal      - number of peaks to return
%  startingNodes - @vector3d
%  tolerance     - minimum distance between two peaks
%  resolution    - minimum step size 
%  maxStepSize   - maximm step size
%

% pointwise minimum of spherical harmonics
if ( nargin > 1 ) && ( isa(varargin{1}, 'S2Fun') )
  f = @(v) min(sF.eval(v), varargin{1}.eval(v));
  v = S2FunHarmonic.quadrature(f);

% pointwise minimum of spherical harmonics
elseif ( nargin > 1 ) && ~isempty(varargin{1}) && ( isa(varargin{1}, 'double') )
  f = @(v) min(sF.eval(v), varargin{1});
  v = S2FunHarmonic.quadrature(f);
  
elseif length(sF) == 1
  [v, f] = steepestDescent(sF, varargin{:});
  
else
  s = size(sF);
  if nargin < 2
    d = find(s ~= 1); % first non-singelton dimension
  else
    d = varargin{2};
  end
  f = @(v) min(sF.eval(v), [], d(1)+1);
  v = S2FunHarmonic.quadrature(f);

end

end
