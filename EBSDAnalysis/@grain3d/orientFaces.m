function grains = orientFaces(grains)
% set up grain.I_GF such that +/- 1 indicates outgoing/ingoing normals
%
% Syntax
%   grains = grains.orientFaces
%
% Input
%  grains - @grain3d
%
% Output
%  grains - @grain3d
%
% Description
%
% Some file formats, e.g. Dream3d, do not store the boundary faces of a
% grain with a consistent winding, i.e., the normals computed from the
% vertex order point randomly into or out of the grain. This function
% determines for every face and every adjacent grain whether the stored
% normal points out of that grain (+1) or into it (-1) and stores the
% result in <grain3d.I_GF |grains.I_GF|>. It also updates
% |grains.boundary.grainId| such that the face normal always points from
% the first to the second grain.
%
% The faces themselves are not modified. Non manifold edges, i.e. edges
% where the surface of a grain pinches itself, are ignored - the resulting
% surface patches are oriented independently of each other.
%
% See also
% grain3d/volume grain3Boundary/N
%

I_GF = grains.I_GF;
[gId,fId] = find(I_GF);
nHF = numel(gId);          % number of half faces, i.e. (grain,face) pairs

if nHF == 0, return; end

% -------------------------------------------------------------------------
% step 1: the directed edges of every half face
% -------------------------------------------------------------------------
% each half face contributes the edges of its face in the order given by the
% stored winding

if iscell(grains.F)

  loops = grains.F(fId);                 % closed loops, first vertex repeated
  numE = cellfun(@numel,loops(:)) - 1;   % number of edges per half face
  vId = double([loops{:}].');

  isFirst = false(numel(vId),1); isFirst(cumsum([1;numE(1:end-1)+1])) = true;
  isLast  = false(numel(vId),1); isLast(cumsum(numE+1)) = true;

  eA = vId(~isLast);
  eB = vId(~isFirst);
  hfId = repelem((1:nHF).',numE);

else

  F = double(grains.F(fId,:));

  eA = F(:);
  eB = reshape(F(:,[2 3 1]),[],1);
  hfId = repmat((1:nHF).',3,1);

end

% direction of each edge with respect to its sorted representation
eDir = 1 - 2*(eA > eB);

% -------------------------------------------------------------------------
% step 2: pair up the half faces that share an edge within the same grain
% -------------------------------------------------------------------------
% identify the undirected edges
nV = length(grains.boundary.allV);
[~,~,eId] = unique(min(eA,eB) * nV + max(eA,eB));

% group the directed edges by (grain, undirected edge)
[~,~,gEId] = unique((gId(hfId)-1) * max(eId) + eId);

% on a closed manifold surface every such group contains exactly two half
% faces - non manifold edges, where a grain surface pinches itself, are
% ignored. They may split a grain surface into several patches, which are
% then oriented independently in step 4.
isManifold = accumarray(gEId,1);
ind = find(isManifold(gEId) == 2);

% sorting by group puts the two partners next to each other
[~,order] = sort(gEId(ind));
ind = ind(order);
e1 = ind(1:2:end); e2 = ind(2:2:end);

% two adjacent faces are consistently oriented if and only if they traverse
% their common edge in opposite directions, i.e. x1 * x2 == w
n1 = hfId(e1); n2 = hfId(e2);
w = -eDir(e1) .* eDir(e2);

% -------------------------------------------------------------------------
% step 3: solve for the signs x by connected components
% -------------------------------------------------------------------------
% duplicate every half face into a node i for x = +1 and a node i + nHF for
% x = -1 and connect the copies according to w. Then every orientable patch
% falls apart into exactly two components - one for each of its two possible
% orientations
src = [n1; n1 + nHF];
dst = [n2 + nHF*(w<0); n2 + nHF*(w>0)];

comp = conncomp(graph(src,dst,[],2*nHF)).';
cPlus = comp(1:nHF); cMinus = comp(nHF+1:end);

if any(cPlus == cMinus)
  warning(['The grain boundary contains %d faces that can not be oriented ' ...
    'consistently.'],nnz(cPlus == cMinus));
end

% the component with the smaller label defines x = +1 - this is a canonical
% choice that is automatically consistent within a patch
x = 1 - 2*(cPlus > cMinus);

% the manifold patch each half face belongs to
[~,~,patchId] = unique(min(cPlus,cMinus));

% -------------------------------------------------------------------------
% step 4: flip those patches whose normals point inwards
% -------------------------------------------------------------------------
% a patch is oriented outwards if and only if it encloses a positive volume
fV = faceVolume(grains);
patchVol = accumarray(patchId, x .* fV(fId));

x = x .* (1 - 2*(patchVol(patchId) < 0));

% the two grains sharing an inner face have to see opposite normals - this
% fails if a grain completely encloses another one, as then the enclosing
% surface is a cavity that has to be oriented inwards
nG = accumarray(fId,1,[size(I_GF,2) 1]);
isInconsistent = (nG == 2) & (accumarray(fId,x,[size(I_GF,2) 1]) ~= 0);
if any(isInconsistent)
  warning(['%d inner faces could not be oriented consistently. This ' ...
    'happens for grains that completely enclose another grain - their ' ...
    'normals have to be flipped manually.'],nnz(isInconsistent));
end

% -------------------------------------------------------------------------
% step 5: store the result
% -------------------------------------------------------------------------
grains.I_GF = sparse(gId,fId,x,size(I_GF,1),size(I_GF,2));

% the face normal should point from the first to the second grain
oldId = grains.boundary.grainId;
newId = zeros(size(oldId));
[a,b] = find(grains.I_GF == 1);  newId(b,1) = a;
[a,b] = find(grains.I_GF == -1); newId(b,2) = a;

grains.boundary = flip(grains.boundary, ~all(newId == oldId,2));

end

function test %#ok<DEFNU>

grains = grain3d.load(fullfile(mtexDataPath,'EBSD','SmallIN100_MeshStats.dream3d'));
grains = grains.orientFaces;

gId = 3;
plot(grains(gId),'micronbar','off')
hold on
quiver3(grains(gId).boundary.centroid,grains(gId).I_GF.' .* grains(gId).boundary.N)
hold off

end
