classdef taubinFilter < boundaryFilter
% shrinkage free smoothing of grain boundaries
%
% Description
% A Laplacian is a low pass filter with gain |1-lambda*k|, which is smaller
% than one everywhere except at |k = 0|. Iterating it therefore shrinks every
% convex region, without bound - a grain smoothed long enough disappears.
%
% Taubin's fix is to follow each smoothing pass by a slightly larger
% *unshrinking* pass with a negative step |mu|, so that the gain over the pair
% is |(1-lambda*k)(1-mu*k)|. With |mu| chosen a little below |-lambda| this
% product is approximately one over the low frequencies, i.e. the shape is
% smoothed while the area is given back.
%
% This is approximate, not exact - the areas do move, just not systematically
% in one direction.
%
% Reference: G. Taubin, A signal processing approach to fair surface design,
% SIGGRAPH 1995.
%
% Syntax
%
%   grains = smoothBoundary(grains,taubinFilter)
%
%   F = taubinFilter;
%   F.iter = 10;
%   grains = smoothBoundary(grains,F)
%
% Class Properties
%  iter   - number of shrink/unshrink pairs (default: 5)
%  lambda - the smoothing step (default: 0.5)
%  mu     - the unshrinking step, negative and slightly larger in modulus
%           than lambda (default: -0.53)
%
% See also
% grain2d/smoothBoundary boundaryFilter laplaceFilter curvatureFilter

properties
  iter = 5        % number of shrink/unshrink pairs
  lambda = 0.5    % the smoothing step
  mu = -0.53      % the unshrinking step
end

methods

  function F = taubinFilter(varargin)

    if nargin > 0 && isnumeric(varargin{1}) && ~isempty(varargin{1})
      F.iter = varargin{1};
    end

    F.lambda = get_option(varargin,'lambda',F.lambda);
    F.mu = get_option(varargin,'mu',F.mu);

  end

  function V = smooth(F,V,A_V,isFixed,~)

    if F.mu >= 0
      error('taubinFilter: mu has to be negative, it is the unshrinking step');
    end

    L = boundaryFilter.laplacian(A_V);

    move = ~all(~isfinite(V) | V == 0,2) & ~isFixed;

    for k = 1:F.iter
      V = step(V,L,move,F.lambda);
      V = step(V,L,move,F.mu);
    end

  end

end

end

% -------------------------------------------------------------------------
function V = step(V,L,move,rate)

dV = L * V;
dV(~isfinite(dV)) = 0;

V(move,:) = V(move,:) + rate * dV(move,:);

end
