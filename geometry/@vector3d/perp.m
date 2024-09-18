function N = perp(v, varargin)
% compute an vector best orthogonal to a list of directions
%
% Syntax
%   N = perp(v)
%   N = perp(v, 'robust') % ignore outliers
%
% Input
%  v - @vector3d
%
% Output
%  N - antipodal @vector3d
%

if any(isnan(v)), v = v.subSet(~v.isnan); end

[N,~] = eig(v);
N = N.subSet(1);

if check_option(varargin,'robust')
  delta = pi/2-angle(N,v);
  id = delta < quantile(delta,0.8)*(1+1e-5);
  
  if any(id), N = perp(v.subSet(id)); end   
end
