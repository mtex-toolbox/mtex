function [grains,F] = smoothBoundary(grains,iter,varargin)
% turn the pixel staircase of a grain boundary into a smooth curve
%
% Syntax
%
%   grains = smoothBoundary(grains)
%   grains = smoothBoundary(grains,iter)
%   grains = smoothBoundary(grains,iter,'noSimplify','noRefine')
%   grains = smoothBoundary(grains,iter,'simplify',epsilon,'refine',delta)
%
%   grains = smoothBoundary(grains,taubinFilter)
%   grains = smoothBoundary(grains,curvatureFilter('smoothingLength',3))
%
% Description
% EBSD data is measured on a regular grid, so a grain boundary comes out of
% calcGrains as a staircase of pixel edges - every segment runs along one of
% the grid axes, whatever direction the boundary actually has. This is
% repaired in three steps
%
% # <grain2d.simplifyBoundary.html |simplifyBoundary|> drops every vertex
% whose removal moves the boundary by less than |epsilon|. A staircase is
% never further than |d/sqrt(2)| from the straight line it approximates, |d|
% being the pixel spacing, so that is the tolerance which removes the grid and
% nothing else
% # <grain2d.refineBoundary.html |refineBoundary|> resamples what is left at
% equal arc length |delta|, which gives the smoothing evenly spaced degrees of
% freedom that are no longer tied to the grid
% # the smoothing itself, by default a constrained Laplacian applied |iter|
% times
%
% Which algorithm performs the last step is decided by a
% <boundaryFilter.html |boundaryFilter|>
%
% * <laplaceFilter.html |laplaceFilter|> - the default, repeated
% local averaging. Shrinks, and its knob is an iteration count rather than a
% length
% * <taubinFilter.html |taubinFilter|> - follows every smoothing
% pass by a slightly larger unshrinking pass, so the area is given back
% * <curvatureFilter.html |curvatureFilter|> - one sparse
% solve instead of an iteration, stated as a smoothing *length* and therefore
% independent both of the iteration count and of the step size of the map
% * <huberFilter.html |huberFilter|> - the same, but with an
% l^1/l^2 penalty that keeps a genuinely faceted boundary faceted
%
% Both tolerances are derived from the median segment length *before* the
% first step - afterwards the median is the length of the straightened runs,
% not the pixel spacing.
%
% Neither of the first two steps is cosmetic. Simplifying alone leaves a curve
% as a handful of long chords, and smoothing those cuts the corners off the
% polygon they form - a circle of 15 pixel radius loses 14% of its area over
% 25 iterations, against 0.4% for the full three steps. Smoothing alone leaves
% the boundary directions of a straight boundary scattered around the grid
% axes.
%
% Junctions - triple points, quadruple points, and the vertices where the
% inner boundary ends on the outer one - stay exactly where they are
% throughout, unless |moveTriplePoints| is given. When grains were segmented
% using alphaShapes, all grains next to holes have outer boundary.
%
% Note that the first two steps change the number of boundary segments, and a
% resampled segment no longer runs between a specific pair of pixels. Where
% |gB.ebsdId| is analysed per segment, switch them off with |'noSimplify'| and
% |'noRefine'|.
%
% Input
%  grains - @grain2d
%  iter   - number of smoothing iterations (default: 1)
%  F      - @boundaryFilter, the smoothing algorithm to use
%
% Output
%  grains - @grain2d
%  F      - @boundaryFilter that was used
%
% Options
%  simplify          - Douglas-Peucker tolerance (default: d/sqrt(2))
%  refine            - resampling length (default: d)
%  noSimplify        - do not simplify the boundary first
%  noRefine          - do not resample the boundary
%  moveTriplePoints  - do not exclude triple/quadruple points from smoothing
%  moveOuterBoundary - do not exclude outer boundary from smoothing
%
% The remaining options configure the default laplaceFilter and have no
% meaning for the other filters
%
%  second_order, S2  - second order smoothing
%  rate              - default smoothing kernel
%  gauss             - Gaussian smoothing kernel
%  exp               - exponential smoothing kernel
%  umbrella          - umbrella smoothing kernel
%
% See also
% grain2d/simplifyBoundary grain2d/refineBoundary grain2d/reduceBoundary
% boundaryFilter laplaceFilter taubinFilter curvatureFilter huberFilter

% an option may take the place of iter, as in smoothBoundary(grains,'noRefine').
% This has to happen before the tilt branch below, which passes iter on
if nargin > 1 && ~isnumeric(iter)
  varargin = [{iter},varargin];
  iter = [];
end
if nargin < 2 || isempty(iter), iter = 1; end

% smoothing happens in the xy plane - test the angle, an exact comparison never holds
if angle(grains.N,zvector,'antipodal') > 1e-10

  [grains,rot] = rotate2Plane(grains);
  [grains,F] = smoothBoundary(grains,iter,varargin{:});
  grains = inv(rot) * grains; %#ok<MINV>
  return

end

% the pixel spacing - has to be read before simplifyBoundary changes what the
% median segment length means
d0 = median(grains.boundary.segLength);

if isfinite(d0) && d0 > 0

  if ~check_option(varargin,'noSimplify')
    grains = simplifyBoundary(grains,get_option(varargin,'simplify',d0/sqrt(2)));
  end

  if ~check_option(varargin,'noRefine')
    grains = refineBoundary(grains,get_option(varargin,'refine',d0));
  end

end

% compute incidence matrix vertices - faces
I_VF = [grains.boundary.I_VF,grains.innerBoundary.I_VF];

% compute vertices adjacency matrix
A_V = I_VF * I_VF';

% do not move a vertex where other than two segments meet, a loose end included
if check_option(varargin,'moveTriplePoints')
  ignore = false(size(A_V,1),1);
else
  vDegree = full(diag(A_V));
  ignore = vDegree ~= 2 & vDegree > 0;
end

% ignore outer boundary
if ~check_option(varargin,'moveOuterBoundary')
  ignore(grains.boundary.F(any(grains.boundary.grainId==0,2),:)) = true;
end

% a vertex no segment uses has nothing to be smoothed against
ignore = ignore | full(diag(A_V)) == 0;

% which algorithm does the smoothing - the iteration count and the kernel
% options are how a laplaceFilter used to be spelled out
F = getClass(varargin,'boundaryFilter',[]);
if isempty(F), F = laplaceFilter(iter,varargin{:}); end

% the spacing the vertices are sampled at, which is what turns a smoothing
% length into a regularization weight
h = median(grains.boundary.segLength);

V = grains.allV.xyz;

V = F.smooth(V,A_V,ignore,h);

grains.allV = vector3d.byXYZ(V,grains.how2plot);
