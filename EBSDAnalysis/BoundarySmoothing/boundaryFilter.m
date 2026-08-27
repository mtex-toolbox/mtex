classdef boundaryFilter < handle
% abstract class for smoothing grain boundaries
%
% Description
% A boundary filter decides *how* <grain2d.smoothBoundary.html
% |smoothBoundary|> turns a polygonal grain boundary into a smooth one. It is
% handed the vertex coordinates together with the adjacency of the boundary
% network and returns the moved coordinates. Everything else - removing the
% pixel staircase, resampling, deciding which vertices are allowed to move -
% happens in smoothBoundary and is the same for every filter.
%
% The filters fall into two groups. <laplaceFilter.html
% |laplaceFilter|> and <taubinFilter.html |taubinFilter|> apply a
% local averaging step a fixed number of times, so how much they smooth depends
% on the vertex spacing. <curvatureFilter.html
% |curvatureFilter|> and <huberFilter.html |huberFilter|> instead
% define the smooth boundary as the solution of a minimization problem, which
% is stated in terms of a length and therefore does not change when the same
% sample is measured on a finer grid.
%
% Syntax
%
%   grains = smoothBoundary(grains,taubinFilter)
%
%   F = curvatureFilter;
%   F.smoothingLength = 3;
%   grains = smoothBoundary(grains,F)
%
% See also
% grain2d/smoothBoundary laplaceFilter taubinFilter curvatureFilter huberFilter

methods (Abstract = true)

  % V       - nV × 3 vertex coordinates
  % A_V     - vertex adjacency, degree on the diagonal, as smoothBoundary
  %           builds it from the vertex - segment incidence matrix
  % isFixed - vertices that may not move, e.g. the junctions
  % h       - the spacing the vertices are sampled at
  V = smooth(F,V,A_V,isFixed,h)

end

methods (Static = true)

  function L = laplacian(A_V)
    % the normalized Laplacian D^-1 A - I of the boundary network
    %
    % A_V comes out of the vertex - segment incidence matrix and therefore
    % carries the degree of a vertex on its diagonal, which has to come off
    % before the rows are normalized. A constant is in the null space, so the
    % out of plane coordinate is left alone.

    nV = size(A_V,1);

    A = A_V - diag(diag(A_V));

    deg = full(sum(A,2));
    deg(deg == 0) = inf;

    L = spdiags(1./deg,0,nV,nV) * A - speye(nV);

  end

  function V = solveDirichlet(M,V,isFixed)
    % solve M*V = V0 for the vertices that are allowed to move
    %
    % The pinned vertices are eliminated rather than penalized, so they stay
    % exactly where they are and their influence enters the right hand side.

    free = ~isFixed;
    if ~any(free), return; end

    V(free,:) = M(free,free) \ (V(free,:) - M(free,~free)*V(~free,:));

  end

end

end
