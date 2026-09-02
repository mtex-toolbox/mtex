function grains = reduceBoundary(grains,n,varargin)
% coarsen the boundary surfaces by clustering the vertices
%
% Syntax
%
%   grains = reduceBoundary(grains)
%   grains = reduceBoundary(grains,3)
%   grains = reduceBoundary(grains,2,'quadric')
%
% Input
%  grains - @grain3d with triangular faces
%  n      - coarsening factor (default 2)
%
% Output
%  grains - @grain3d
%
% Options
%  cell - size of the clustering cell (default n times the shortest edge)
%
% Flags
%  quadric - place each vertex where the faces it stands for are best
%            approximated, instead of at the centroid of its cluster
%
% Description
% The volume is divided into cells n times the voxel size, and the vertices
% of a cell become one. Vertices that belong to different sets of grains, or
% to different faces of the outer hull, never merge: a triple line stays a
% triple line between the same grains, a quadruple point stays where four
% grains meet, and the hull stays flat. Faces whose vertices fell together
% vanish, so a grain smaller than a cell keeps its voxels but loses its
% surface and its volume drops to zero.
%
% This is the blunt instrument: it thins a flat face and a curved one alike.
% The centroid of a cluster already averages the voxel steps, the |'quadric'|
% placement keeps flat faces flat and triple lines sharp.
%
% References
%
% * J. Rossignac, P. Borrel, Multi-resolution 3D approximations for
%   rendering complex scenes, Modeling in Computer Graphics, Springer 1993.
% * P. Lindstrom, Out-of-core simplification of large polygonal models,
%   SIGGRAPH 2000, the quadric placement.
%
% See also
% grain2d/reduceBoundary grain3d/refineBoundary grain3d/smoothBoundary

if nargin > 1 && ~isnumeric(n), varargin = [{n},varargin]; end
if nargin < 2 || ~isnumeric(n), n = 2; end

gB = grains.boundary;
V = gB.allV.xyz;
[E,~] = edges(gB);
h = get_option(varargin,'cell',n * min(vecnorm(V(E(:,1),:) - V(E(:,2),:),2,2)));

% the cell, the grains and the hull faces a vertex belongs to make its key
lo = min(V,[],1); hi = max(V,[],1);
onLo = abs(V - lo) < 1e-6*h; onHi = abs(V - hi) < 1e-6*h;
I_VG = gB.I_VG;
[gId,vId] = find(I_VG.');
isFirst = [true; diff(vId) ~= 0];
first = find(isFirst);
pos = (1:numel(vId)).' - first(cumsum(isFirst)) + 1;
gTuple = zeros(size(V,1),4);
gTuple(sub2ind(size(gTuple),vId(pos<=4),pos(pos<=4))) = gId(pos<=4);
key = [floor((V - lo) ./ h), gTuple, onLo*[1;2;4] + onHi*[8;16;32]];

% vertices meeting more than four grains stay
many = full(sum(I_VG,2)) > 4;
key(many,:) = [-(1:nnz(many)).', zeros(nnz(many),size(key,2)-1)];
[~,~,c] = unique(key,'rows');

% one representative per cluster, kept on the hull planes exactly
Vc = [accumarray(c,V(:,1)), accumarray(c,V(:,2)), accumarray(c,V(:,3))] ./ accumarray(c,1);
if check_option(varargin,'quadric'), Vc = quadricPlacement(Vc,c,gB); end
for k = 1:3
  Vc(accumarray(c,onLo(:,k),[],@any) > 0,k) = lo(k);
  Vc(accumarray(c,onHi(:,k),[],@any) > 0,k) = hi(k);
end

% faces that keep three distinct vertices
F = c(gB.F);
ok = find(all(diff(sort(F,2),1,2) ~= 0,2));

% a face drawn twice with the same sense stays once, drawn with opposite
% senses it cancels: sum the sense per vertex triple and grain pair
S = sort(F(ok,:),2);
even = (F(ok,1) == S(:,1) & F(ok,2) == S(:,2)) | (F(ok,1) == S(:,2) & F(ok,2) == S(:,3)) ...
  | (F(ok,1) == S(:,3) & F(ok,2) == S(:,1));
g = gB.grainId(ok,:);
sgn = (2*even - 1) .* (1 - 2*(g(:,1) > g(:,2)));
[~,first,id] = unique([S, sort(g,2)],'rows');
net = accumarray(id,sgn);
keep = ok(first(net ~= 0));
doFlip = sign(net(net ~= 0)) ~= sgn(first(net ~= 0));

gB = gB.subSet(keep);
gB.F = F(keep,:);
gB.F(doFlip,:) = fliplr(gB.F(doFlip,:));
gB = gB.flip(doFlip);
gB.id = (1:numel(keep)).';
gB.allV = vector3d.byXYZ(Vc,gB.allV.frame);

grains.boundary = gB;
grains.I_GF = grains.I_GF(:,keep);
grains.I_GF(:,doFlip) = -grains.I_GF(:,doFlip);

end

function Vc = quadricPlacement(Vc,c,gB)
% the point of a cluster closest to the planes of the faces around it,
% pulled towards the centroid where those planes leave it undetermined

N = gB.N.xyz;
d = -sum(N .* gB.centroid.xyz,2);

% every face counts for the clusters of its three vertices
cF = c(gB.F);
f = repmat((1:length(gB.F)).',3,1);
cF = cF(:);
nC = size(Vc,1);

A = zeros(nC,3,3); b = zeros(nC,3);
for i = 1:3
  b(:,i) = accumarray(cF,-d(f) .* N(f,i),[nC 1]);
  for j = i:3
    A(:,i,j) = accumarray(cF,N(f,i) .* N(f,j),[nC 1]);
    A(:,j,i) = A(:,i,j);
  end
end

reg = 1e-3 * (A(:,1,1) + A(:,2,2) + A(:,3,3));
A = A + reg .* reshape(eye(3),1,3,3);
b = b + reg .* Vc;

Vc = reshape(pagemldivide(permute(A,[2 3 1]),permute(b,[2 3 1])),3,[]).';

end
