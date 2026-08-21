classdef huberFilter < boundaryFilter
% smooth grain boundaries but keep genuine corners sharp
%
% Description
% Same variational idea as <curvatureFilter.curvatureFilter.html
% |curvatureFilter|>, but the curvature is penalized by a Huber function
% instead of a square
%
%   |V - V0|^2 + alpha * sum rho(|L V|)
%
% with |rho| quadratic below a threshold and linear above it. Quadratic means
% least squares, which spreads a large deviation over many vertices and so
% rounds a corner off. Linear - an l^1 penalty - is minimized by concentrating
% the deviation in as few vertices as possible, which leaves a corner standing.
%
% So the filter smooths gentle undulations exactly like curvatureFilter, while
% a boundary that is genuinely faceted keeps its facets and its corners. The
% threshold says how sharp a turn has to be to count as a corner rather than
% as noise.
%
% The Huber problem is solved by iteratively reweighted least squares: the
% l^1 part is replaced by a quadratic with weight |threshold/|L V||, the
% resulting linear system is solved, and the weights are recomputed. This is
% an iteration, but it runs until it stops moving - |iterMax| is a safety
% limit, not a tuning knob.
%
% |threshold| is the turning angle *at a single vertex of the result*, not the
% total angle of the corner. The smoothing spreads a corner over roughly
% |smoothingLength/h| vertices, and the reweighting then sharpens it back, so
% the total angle that survives comes out several times larger than the
% threshold. On a hexagon smoothed with |smoothingLength = 8*h| the 60 degree
% corners come back as
%
%  threshold    30    15     8     4     2   degree
%  corner       22    28    49    68    80   degree
%
% A boundary with no corner at all is unaffected: a circle of radius |R| turns
% by |h/R| per vertex, far below any sensible threshold, so the filter returns
% exactly what curvatureFilter would.
%
% Syntax
%
%   grains = smoothBoundary(grains,huberFilter)
%
%   F = huberFilter;
%   F.smoothingLength = 3;
%   F.threshold = 3*degree;
%   grains = smoothBoundary(grains,F)
%
% Class Properties
%  smoothingLength - wavelength damped to half amplitude, in map units
%                    (default: 4 times the vertex spacing)
%  threshold       - per vertex turning angle above which a vertex counts as
%                    a corner and is preserved (default: 5 degree)
%  alpha           - the regularization weight itself; overrides smoothingLength
%  iterMax         - safety limit on the reweighting (default: 50)
%  tol             - stop once no vertex moves further than this, relative to
%                    the vertex spacing (default: 1e-4)
%
% See also
% grain2d/smoothBoundary boundaryFilter curvatureFilter taubinFilter

properties
  smoothingLength = []    % wavelength damped to half amplitude
  threshold = 5*degree    % per vertex turning angle that counts as a corner
  alpha = []              % regularization weight, overrides smoothingLength
  iterMax = 50            % safety limit on the reweighting
  tol = 1e-4              % stopping criterion, relative to the vertex spacing
end

methods

  function F = huberFilter(varargin)

    if nargin > 0 && isnumeric(varargin{1}) && ~isempty(varargin{1})
      F.smoothingLength = varargin{1};
    end

    F.smoothingLength = get_option(varargin,'smoothingLength',F.smoothingLength);
    F.threshold = get_option(varargin,'threshold',F.threshold);
    F.alpha = get_option(varargin,'alpha',F.alpha);
    F.iterMax = get_option(varargin,'iterMax',F.iterMax);
    F.tol = get_option(varargin,'tol',F.tol);

  end

  function V = smooth(F,V,A_V,isFixed,h)

    alpha = F.weight(h); %#ok<PROPLC>
    if alpha <= 0, return; end %#ok<PROPLC>

    L = boundaryFilter.laplacian(A_V);
    nV = size(L,1);

    isFixed = isFixed | ~isfinite(sum(V,2));

    % a vertex turning by theta sits about h*theta/2 off the line, as |L V| measures
    delta = h * F.threshold / 2;

    w = ones(nV,1);
    V0 = V;

    for k = 1:F.iterMax

      M = speye(nV) + alpha * (L.' * spdiags(w,0,nV,nV) * L); %#ok<PROPLC>

      Vnew = boundaryFilter.solveDirichlet(M,V0,isFixed);

      step = max(sqrt(sum((Vnew - V).^2,2)));
      V = Vnew;
      if k > 1 && step < F.tol * h, break; end

      % Huber: quadratic below the threshold, linear above it
      r = sqrt(sum((L*V).^2,2));
      w = min(1, delta ./ max(r,eps));

    end

  end

  function alpha = weight(F,h)
    % the regularization weight, from smoothingLength if it is not set directly

    if ~isempty(F.alpha)
      alpha = F.alpha;
      return
    end

    lambda = F.smoothingLength;
    if isempty(lambda), lambda = 4*h; end

    % see curvatureFilter/weight
    alpha = 1 / (4 * sin(pi*h/max(lambda,2*h))^4);

  end

end

end
