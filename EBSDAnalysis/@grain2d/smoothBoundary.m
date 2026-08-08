function grains = smoothBoundary(grains,iter,varargin)
% turn the pixel staircase of a grain boundary into a smooth curve
%
% Syntax
%
%   grains = smoothBoundary(grains)
%   grains = smoothBoundary(grains,iter)
%   grains = smoothBoundary(grains,iter,'noSimplify','noRefine')
%   grains = smoothBoundary(grains,iter,'simplify',epsilon,'refine',delta)
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
% # constrained Laplacian smoothing, |iter| times
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
%
% Output
%  grains - @grain2d
%
% Options
%  simplify          - Douglas-Peucker tolerance (default: d/sqrt(2))
%  refine            - resampling length (default: d)
%  noSimplify        - do not simplify the boundary first
%  noRefine          - do not resample the boundary
%  moveTriplePoints  - do not exclude triple/quadruple points from smoothing
%  moveOuterBoundary - do not exclude outer boundary from smoothing
%  second_order, S2  - second order smoothing
%  rate              - default smoothing kernel
%  gauss             - Gaussian smoothing kernel
%  exp               - exponential smoothing kernel
%  umbrella          - umbrella smoothing kernel
%
% See also
% grain2d/simplifyBoundary grain2d/refineBoundary grain2d/reduceBoundary

% an option may take the place of iter, as in smoothBoundary(grains,'noRefine').
% This has to happen before the tilt branch below, which passes iter on
if nargin > 1 && ~isnumeric(iter)
  varargin = [{iter},varargin];
  iter = [];
end
if nargin < 2 || isempty(iter), iter = 1; end

% smoothing happens in the xy plane, so tilt the grains into it first. Test the
% angle rather than dot(N,zvector) == 1 - rotate2Plane leaves the latter at
% 1+2e-16, which never satisfies an exact comparison and recurses forever
if angle(grains.N,zvector,'antipodal') > 1e-10

  [grains,rot] = rotate2Plane(grains);
  grains = smoothBoundary(grains,iter,varargin{:});
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
t = size(A_V,1);

% Do not move the junctions - the vertices where anything other than two
% segments meet, counting the inner boundary too. diag(A_V) is that count.
% The test used to be > 2, which missed the loose ends where a single
% segment terminates; those are chain ends as well and have to stay put.
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

if check_option(varargin,{'second order','second_order','S','S2'})
  A_V = logical(A_V + A_V*A_V);
  A_V = A_V - diag(diag(A_V));
end

weight = get_flag(varargin,{'gauss','expotential','exp','umbrella','rate'},'rate');
lambda = get_option(varargin,weight,.5);

V = grains.allV.xyz;
isNotZero = ~all(~isfinite(V) | V == 0,2) & ~ignore;

for l=1:iter
  if ~strcmpi(weight,'rate')
    [i,j] = find(A_V);
    d = sqrt(sum((V(i,:)-V(j,:)).^2,2)); % distance
    switch weight
      case 'umbrella'
        w = 1./(d);
        w(d==0) = 1;
      case 'gauss'
        w = exp(-(d./lambda).^2);
      case {'expotential','exp'}
        w = lambda*exp(-lambda*d);
    end

    A_V = sparse(i,j,w,t,t);
  end

  % take the mean over the neighbors
  Vt = A_V * V;

  m = sum(A_V,2);

  dV = V(isNotZero,:)-bsxfun(@rdivide,Vt(isNotZero,:),m(isNotZero,:));

  isZero = any(~isfinite(dV),2);
  dV(isZero,:) = 0;

  V(isNotZero,:) = V(isNotZero,:) - lambda*dV;

end

grains.allV = vector3d.byXYZ(V,grains.how2plot);
