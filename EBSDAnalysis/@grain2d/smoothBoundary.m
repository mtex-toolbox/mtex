function [grains,F] = smoothBoundary(grains,iter,varargin)
% turn the pixel staircase of a grain boundary into a smooth curve
%
% Syntax
%
%   grains = smoothBoundary(grains)
%   grains = smoothBoundary(grains,iter)
%   grains = smoothBoundary(grains,iter,'noSimplify')
%   grains = smoothBoundary(grains,iter,'simplify',epsilon)
%
%   grains = smoothBoundary(grains,taubinFilter(40))
%   grains = smoothBoundary(grains,curvatureFilter('smoothingLength',3))
%
% Description
% EBSD data is measured on a regular grid, so a grain boundary comes out of
% calcGrains as a staircase of pixel edges - every segment runs along one of
% the grid axes, whatever direction the boundary actually has. This is
% repaired in two steps
%
% # the vertices are smoothed, by default by |iter| pairs of
% <taubinFilter.html |taubinFilter|> steps. After every step each vertex of a
% pixel edge is moved back into its cell - the square of the four pixel
% centres around it, the triangle of three on a hexagonal grid - shrunk by
% |d/20|, |d| being the pixel spacing. So the boundary passes every pixel it
% was measured next to on the side it was measured on, and a triple point
% stays within half a step of where it was. A loose end stays put, and so
% does the whole boundary of a grain of fewer than 14 vertices - it has no
% shape below the pixel scale to smooth, only area to lose
% # <grain2d.simplifyBoundary.html |simplifyBoundary|> drops every vertex
% whose removal moves the boundary by less than |epsilon|, |d/10| by default,
% unless that would bring one of those pixel centres closer than |d/20| to
% the boundary or put it on the other side
%
% Which algorithm performs the first step is decided by a
% <boundaryFilter.html |boundaryFilter|>
%
% * <taubinFilter.html |taubinFilter|> - the default, follows every
% smoothing pass by a slightly larger unshrinking pass, so small grains keep
% their area
% * <laplaceFilter.html |laplaceFilter|> - repeated local averaging, which
% shrinks every convex grain
% * <curvatureFilter.html |curvatureFilter|> - one sparse
% solve instead of an iteration, stated as a smoothing *length* and therefore
% independent both of the iteration count and of the step size of the map
% * <huberFilter.html |huberFilter|> - the same, but with an
% l^1/l^2 penalty that keeps a genuinely faceted boundary faceted
%
% The pixel edges are those with a nonzero |gB.pixelDist|, which
% <EBSD.calcGrains.html |calcGrains|> records. Grains built otherwise have
% none; then only the junctions are held within half a step.
%
% The outer boundary is smoothed as well, but its junctions and the corners
% of its convex hull stay fixed unless |moveOuterBoundary| is given, so the
% map keeps its extent.
%
% The second step changes the number of boundary segments. A segment that no
% longer runs between a specific pair of pixels gets the |gB.ebsdId| 0, as the
% outer boundary has; where the pixel pairs are analysed, switch it off with
% |'noSimplify'| to keep them all.
%
% Smoothing moves the vertices off the pixel corners, so afterwards no
% segment is a pixel edge any more. Smoothing a second time then holds only
% the junctions; for a smoother boundary raise |iter| instead.
%
% Input
%  grains - @grain2d
%  iter   - number of Taubin pairs (default: 20)
%  F      - @boundaryFilter, the smoothing algorithm to use
%
% Output
%  grains - @grain2d
%  F      - @boundaryFilter that was used
%
% Options
%  simplify          - Douglas-Peucker tolerance (default: d/10)
%  noSimplify        - do not simplify the boundary
%  moveOuterBoundary - let the junctions and hull corners of the outer boundary move
%
% See also
% grain2d/simplifyBoundary grain2d/refineBoundary grain2d/reduceBoundary
% boundaryFilter laplaceFilter taubinFilter curvatureFilter huberFilter

% an option may take the place of iter, as in smoothBoundary(grains,'noSimplify').
% This has to happen before the tilt branch below, which passes iter on
if nargin > 1 && ~isnumeric(iter)
  varargin = [{iter},varargin];
  iter = [];
end
if nargin < 2 || isempty(iter), iter = 20; end

% smoothing happens in the xy plane - test the angle, an exact comparison never holds
if angle(grains.N,zvector,'antipodal') > 1e-10

  [grains,rot] = rotate2Plane(grains);
  [grains,F] = smoothBoundary(grains,iter,varargin{:});
  grains = inv(rot) * grains; %#ok<MINV>
  return

end

% compute incidence matrix vertices - faces
I_VF = [grains.boundary.I_VF,grains.innerBoundary.I_VF];

% compute vertices adjacency matrix
A_V = I_VF * I_VF';

% do not move a vertex no segment uses, nor the loose end of a boundary
vDegree = full(diag(A_V));
ignore = vDegree < 2;

% a grain of fewer than 14 boundary vertices keeps its measured boundary
gId = grains.boundary.grainId;
small = [false; accumarray(gId(gId > 0),1,[length(grains) 1]) < 14];
ignore(grains.boundary.F(any(small(gId + 1),2),:)) = true;

V = grains.allV.xyz;

% the outer boundary keeps its junctions and the corners of its convex hull
if ~check_option(varargin,'moveOuterBoundary')
  outerV = grains.boundary.F(any(grains.boundary.grainId==0,2),:);
  ignore(outerV(vDegree(outerV) ~= 2)) = true;
  used = find(vDegree > 0);
  ignore(used(convhull(V(used,1:2)))) = true;
end

% the pixel edges and the pixel spacing d
E = [grains.boundary.F; grains.innerBoundary.F];
pd = [pixelDist(grains.boundary); pixelDist(grains.innerBoundary)];
E = E(pd > 0,:);
pd = pd(pd > 0);
d = median(pd);
if isnan(d), d = median(grains.boundary.segLength); end
margin = d/20;

% the cell of a vertex of a pixel edge is the polygon of the pixel centres
% around it - a square, or a triangle on a hexagonal grid. Its faces lie at
% half the edge length, one facing along the edge, and move in by margin
t = V(E(:,2),1:2) - V(E(:,1),1:2);
K = 4 - (median(pd ./ vecnorm(t,2,2)) > 1.5);
[id,i] = unique(E(:));
phi = atan2(t(:,2),t(:,1)) + [0 pi];
h = repmat(vecnorm(t,2,2)/2 - margin,1,2);

% a junction without one stays within half a step
j = setdiff(find(vDegree > 2 & ~ignore),id);
cells = struct('id',[id;j],'V0',V([id;j],1:2),'phi',[phi(i);zeros(size(j))],...
  'h',[h(i);repmat(d/2 - margin,size(j))],'K',K);

% which algorithm does the smoothing
F = getClass(varargin,'boundaryFilter',[]);
if isempty(F), F = taubinFilter(iter,varargin{:}); end

V0 = V;
V = F.smooth(V,A_V,ignore,median(grains.boundary.segLength),@(V) toCell(V,cells));
grains.allV = vector3d.byXYZ(V,grains.how2plot);

if ~check_option(varargin,'noSimplify')
  grains = simplifyBoundary(grains,get_option(varargin,'simplify',d/10),...
    'margin',margin,'measuredV',V0);
end

% the vertices have left the pixel corners, so no segment is a pixel edge any more
grains.boundary.prop.pixelDist = zeros(length(grains.boundary),1);
grains.innerBoundary.prop.pixelDist = zeros(length(grains.innerBoundary),1);

end

% -------------------------------------------------------------------------
function pd = pixelDist(gB)
% gB.pixelDist, 0 where it was not recorded

pd = zeros(length(gB),1);
if isProperty(gB,'pixelDist'), pd = gB.pixelDist; end

end

% -------------------------------------------------------------------------
function V = toCell(V,c)
% the vertices c.id moved back into their cells - regular polygons of c.K faces
% about c.V0 at the distance c.h, the first facing in the direction c.phi

x = V(c.id,1:2) - c.V0;
a = c.phi + 2*pi*(0:c.K-1)/c.K;

% the face furthest outside - its line is where an outside vertex goes, up to
% the corners of the face
[o,k] = max(x(:,1).*cos(a) + x(:,2).*sin(a) - c.h,[],2);
a = a(sub2ind(size(a),(1:numel(k)).',k));
w = c.h * tan(pi/c.K);
w = max(-w,min(w,x(:,2).*cos(a) - x(:,1).*sin(a)));
out = o > 0;
x(out,:) = c.h(out).*[cos(a(out)) sin(a(out))] + w(out).*[-sin(a(out)) cos(a(out))];

V(c.id,1:2) = x + c.V0;

end
