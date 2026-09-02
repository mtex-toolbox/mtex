function [p,wFinal] = robustLsq(A,b,w,varargin)
% weighted least squares, reweighted against outliers with Tukey's bisquare
%
% The one solver behind every fitted spatialTransform. Each class supplies
% the design matrix for its own basis and nothing else changes: a
% displacement measured on a featureless tile correlates weakly, gets a
% small prior weight, and is outvoted rather than dragging the fit.
%
% Syntax
%
%   p = robustLsq(A,b)
%   p = robustLsq(A,b,w)
%   p = robustLsq(A,b,w,'iterMax',50)
%
% Input
%  A - n × m design matrix
%  b - n × k right hand sides, one column per fitted coordinate
%  w - n × 1 prior weights, [] for none
%
% Output
%  p      - m × k coefficients
%  wFinal - n × 1 weights of the last iteration, prior times bisquare
%
% Options
%  iterMax - default 50
%
% See also
% spatialTransform

% the bisquare tuning constant, 95% efficiency
tune = 4.685;
iterMax = get_option(varargin,'iterMax',50);

w = w(:);

sw = sqrt(w);
p = (A .* sw) \ (b .* sw);

if check_option(varargin,'noRobust'), wFinal = w; return; end

% leverage, so a point that pulls the fit towards itself is not thereby
% judged a good fit - the standard robustfit correction
[Q,~] = qr(A .* sw,0);
h = min(sum(Q.^2,2),1 - eps);
adj = 1 ./ sqrt(1 - h);

wFinal = w;

for iter = 1:iterMax

  r = (b - A*p) .* adj;

  % one scale for the whole fit, from the median absolute deviation
  s = median(abs(r - median(r,1)),1) / 0.6745;
  s(s < eps) = eps;

  u = r ./ (tune .* s);
  bi = (abs(u) < 1) .* (1 - u.^2).^2;

  % several right hand sides share one weight per point, so take the least
  % favourable - a point that is an outlier in y must not keep full say
  wFinal = w .* min(bi,[],2);

  sw = sqrt(wFinal);
  pNew = (A .* sw) \ (b .* sw);

  if norm(pNew - p,'fro') <= 1e-8 * max(1,norm(p,'fro')), p = pNew; break; end
  p = pNew;

end

end
