function grains = smoothBoundary(grains,iter,varargin)
% smooth the boundary surfaces of 3d grains
%
% Syntax
%
%   grains = smoothBoundary(grains)
%   grains = smoothBoundary(grains,10)
%   grains = smoothBoundary(grains,taubinFilter(20))
%   grains = smoothBoundary(grains,curvatureFilter('smoothingLength',3))
%   grains = smoothBoundary(grains,10,'maxDisplacement',0.5)
%
% Input
%  grains - @grain3d with triangular faces
%  iter   - number of iterations (default 1)
%
% Output
%  grains - @grain3d
%
% Options
%  scheme          - |'hierarchical'| (default) or |'coupled'|
%  maxDisplacement - no vertex moves further than this from where it was
%
% Flags
%  fixTripleLines    - keep the triple lines where they are
%  moveOuterBoundary - let the vertices on the outer hull move
%
% Description
%
% The vertices move, nothing else: the faces, the grains they separate and
% the voxels they carry stay. The boundary network is a stratified complex.
% Quadruple points, where four grains meet, are kept fixed. The
% |'hierarchical'| scheme then smooths every triple line as a curve between
% its quadruple points and afterwards every boundary face as a surface
% between its triple lines, so that a junction is never averaged with the
% interior of a face. The |'coupled'| scheme smooths all vertices at once
% and lets a triple line drift with the faces around it.
%
% Which filter moves the vertices is a <boundaryFilter.html |boundaryFilter|>,
% the same objects as in two dimensions: |laplaceFilter| shrinks every
% grain a little per iteration, |taubinFilter| keeps the volumes
% approximately, |curvatureFilter| and |huberFilter| solve for a smoothing
% length. The outer hull is fixed, so the volumes of all grains together
% are conserved exactly. |'maxDisplacement'| bounds how far the surface may
% travel, half a voxel keeps a one voxel grain in place.
%
% References
%
% * S. Maddali, S. Ta'asan, R. M. Suter, Topology-faithful nonparametric
%   estimation and tracking of bulk interface networks, Computational
%   Materials Science 125 (2016), the hierarchical scheme.
% * S. F. F. Gibson, Constrained elastic surface nets, MICCAI 1998, the
%   bound on the displacement.
%
% See also
% grain2d/smoothBoundary grain3d/reduceBoundary grain3d/refineBoundary boundaryFilter

if nargin > 1 && ~isnumeric(iter), varargin = [{iter},varargin]; end
if nargin < 2 || ~isnumeric(iter), iter = 1; end

gB = grains.boundary;
V = gB.allV.xyz;
V0 = V;
[E,F2E] = edges(gB);
t = nodeType(gB);

% an edge on three or more faces lies on a triple line
isTL = false(size(V,1),1);
isTL(E(accumarray(F2E(:),1) >= 3,:)) = true;
isFixed = mod(t,10) >= 4;
if ~check_option(varargin,'moveOuterBoundary'), isFixed = isFixed | t >= 10; end

h = median(vecnorm(V(E(:,1),:) - V(E(:,2),:),2,2));

F = getClass(varargin,'boundaryFilter',[]);
if isempty(F), F = laplaceFilter(iter,varargin{:}); end
F = F.prepare(struct('V',V,'F',gB.F,'E',E,'F2E',F2E,'nodeType',t,'grainId',gB.grainId,'N',gB.N));

% the triple lines as curves between their quadruple points
if strcmpi(get_option(varargin,'scheme','hierarchical'),'hierarchical')
  if ~check_option(varargin,'fixTripleLines')
    tl = find(isTL);
    Etl = E(all(isTL(E),2),:);
    A = adjacency(Etl,size(V,1));
    V(tl,:) = F.smooth(V(tl,:),A(tl,tl),isFixed(tl),h);
  end
  isFixed = isFixed | isTL;
end

% the faces as surfaces between the triple lines
V = F.smooth(V,adjacency(E,size(V,1)),isFixed,h);

d = get_option(varargin,'maxDisplacement',inf);
V = V0 + max(-d,min(d,V - V0));

grains.allV = vector3d.byXYZ(V,gB.allV.frame);

end

function A = adjacency(E,nV)
% vertex adjacency with the degree on the diagonal, as boundaryFilter expects

A = sparse([E(:,1);E(:,2)],[E(:,2);E(:,1)],1,nV,nV);
A = A + spdiags(sum(A,2),0,nV,nV);

end
