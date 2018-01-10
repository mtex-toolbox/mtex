function [f,v] = steepestDescent(sF, varargin)
% calculates the minimum of a spherical harminc
% Syntax
%   [v,pos] = steepestDescent(sF) % the position where the minimum is atained
%
%   [v,pos] = steepestDescent(sF,'numLocal',5) % the 5 largest local minima
%
%   % with all options
%   [v,pos] = steepestDescent(sF, 'startingnodes')
%
% Output
%  v - double
%  pos - @vector3d
%
% Options
%  STARTINGNODES  -  starting nodes of type @vector3d
%  

% parameters{{{
tau   = get_option(varargin, 'tau', 1e-8); % tolerance
kmax   = get_option(varargin, 'kmax', 10); % maximal iterations
mu     = get_option(varargin, 'mu', 0.4); % in (0, 0.5) for Armijo condition
tauLS   = get_option(varargin, 'tauLS', 0.5); % in (0, 1) alpha(k+1) = tauLS*alpha(k)
kmaxLS   = get_option(varargin, 'kmaxLS', 6); % maximal iterations for line search
v = get_option(varargin, 'startingnodes', equispacedS2Grid('points', 2^9));
v = v(:);
v = v(v.theta > 0.01 & v.theta < pi-0.01);
%}}}

for k = 0:kmax
  d = -sF.grad(v);
  normd = norm(d);
  alpha = ones(size(v));
% step length by linesearch{{{
  f0 = sF.eval(v);
  vd = diag(cos(normd))*v+diag(sin(normd)./normd)*d;
  g = dot(sF.grad(vd), d);
  for kLS = 1:kmaxLS
    valphad = diag(cos(alpha.*normd))*v+diag(sin(alpha.*normd)./normd)*d;
    f = sF.eval(valphad);
    allgood = true;
    for ii = 1:length(v)
      if f(ii)-f0(ii) > mu*alpha(ii)*g(ii)
        alpha(ii) = tauLS*alpha(ii);
        allgood = false;
      end
    end
    if allgood == true, break; end
  end
  %}}}
  v = diag(cos(alpha.*normd))*v+diag(sin(alpha.*normd)./normd)*d;
  v = unique(v, 'tolerance', 0.01);
  if  1/length(v)*sum(norm(g)) < tau, break; end
end

[f, I] = sort(f);
if check_option(varargin, 'numLocal')
  n = get_option(varargin, 'numLocal');
  n = min(length(v), n);
  f = f(1:n);
  v = v(I(1:n));
else
  n = sum(f-f(1) < 1e-5);
  f = f(1);
end
v = v(I(1:n));

end
