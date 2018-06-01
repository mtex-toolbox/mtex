function [v,f] = min(sF, varargin)
% calculates the minimum of a spherical harminc or the pointwise minimum of two spherical harmonics
%
% Syntax
%   [v,pos] = min(sF) % the position where the minimum is atained
%
%   [v,pos] = min(sF,'numLocal',5) % the 5 largest local minima
%
%   % with all options
%   [v,pos] = min(sF, 'startingnodes', NODES, 'lambda', LAMBDA, 'tau', TAU, 'mu', MU, 'kmax', KMAX, 'tauLS', TAULS, 'kmaxLS', KMAXLS)
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
%  bw             - minimal degree of the spherical harmonic for pointwise minimum of two @S2FunHarmonic
%  STARTINGNODES  -  starting nodes of type @vector3d
%  LAMBDA         -  regularization parameter
%  TAU            -  tolerance
%  MU             -  in (0, 0.5) for Armijo condition
%  KMAX           -  maximal iterations
%  TAULS          -  in (0, 1) alpha(k+1) = tauLS*alpha(k)
%  KMAXLS         -  maximal iterations for line search
%  tolerance      -  tolerance for nearby nodes to be ignored
%  

% pointwise minimum of spherical harmonics
if ( nargin > 1 ) && ( isa(varargin{1}, 'S2FunHarmonic') )
  f = @(v) min(sF.eval(v), varargin{1}.eval(v));
  bw = get_option(varargin, 'bandwidth', max(100, min(500, sF.bandwidth+varargin{1}.bandwidth)));
  v = S2FunHarmonic.quadrature(f, 'bandwidth', bw);

% pointwise minimum of spherical harmonics
elseif ( nargin > 1 ) && ~isempty(varargin{1}) && ( isa(varargin{1}, 'double') )
  f = @(v) min(sF.eval(v), varargin{1});
  bw = get_option(varargin, 'bandwidth', max(100, min(500, 2*sF.bandwidth)));
  v = S2FunHarmonic.quadrature(f, 'bandwidth', bw);
  
elseif length(sF) == 1
  [v, f] = steepestDescent(sF, varargin{:});
%  [v, f] = simultaniousCG(sF, varargin{:});
  
else
  s = size(sF);
  if nargin < 2
    d = find(s ~= 1); % first non-singelton dimension
  else
    d = varargin{2};
  end
  f = @(v) min(sF.eval(v), [], d(1)+1);
  bw = get_option(varargin, 'bandwidth', max(100, min(500, 2*sF.bandwidth)));
  v = S2FunHarmonic.quadrature(f, 'bandwidth', bw);

end

end
