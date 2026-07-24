function [A_Do,A_Db,componentId] = completeBoundaryGraph(A_Do,A_Db,I_FD,F)
% extend inner boundaries by recursively applying local minimum cuts
%
% Input
%  A_Do - weighted adjacency of connected pixels
%  A_Db - logical adjacency of pixel pairs marked as grain boundaries
%  I_FD - incidence matrix faces -> pixels
%  F    - vertex ids of the boundary segments
%
% Output
%  A_Do        - connectivity after the additional cuts
%  A_Db        - original and additionally introduced boundary edges
%  componentId - connected component of every pixel
%
% A boundary edge is inner if its incident pixels are connected by an
% alternative path in A_Do. For each affected component this function
% repeatedly separates the endpoints of one such edge by a minimum cut.
% Every cut strictly increases the number of components, and hence the
% procedure terminates with no inner boundary edges.
%
% The individual binary cuts are optimal with respect to the weights in
% A_Do. The sequence of cuts is a greedy multicut approximation; it is not
% a globally optimal solution of the multicut problem.
%
% Isolated inner-boundary components with fewer than three segments are
% ignored. They usually originate from individual noisy pixels. Segment
% connectivity is determined from F, so a short inner boundary that reaches
% an existing grain or map boundary is retained.

n = size(A_Do,1);

% A boundary is a hard separation constraint. This is relevant for soft or
% low-angle criteria, for which an edge can currently occur in both graphs.
A_Do = A_Do - A_Do .* A_Db;

[bdI,bdJ] = find(triu(A_Db,1));
componentId = connectedComponents(A_Do);

if isempty(bdI), return; end

isInner = componentId(bdI) == componentId(bdJ);
if ~any(isInner), return; end

% Remove short, enclosed boundary fragments before running any max-flow.
% Apart from suppressing pixel noise this is important for performance:
% every ignored fragment avoids a potentially grain-sized flow problem.
[ignoreI,ignoreJ] = shortIsolatedBoundaries(A_Db,componentId,I_FD,F);
if ~isempty(ignoreI)
  ignored = sparse([ignoreI;ignoreJ],[ignoreJ;ignoreI],true,n,n);
  A_Db = A_Db - A_Db .* ignored;

  % Treat an ignored fragment as ordinary within-grain connectivity. This
  % is also the intended behaviour for a hard (zero-connectivity) criterion.
  A_Do = A_Do | ignored;

  [bdI,bdJ] = find(triu(A_Db,1));
  isInner = componentId(bdI) == componentId(bdJ);
  if ~any(isInner), return; end
end

% Collect only the affected pixels in linear time. Sorting all component ids
% used to be noticeable for multi-million-pixel maps.
affectedId = unique(componentId(bdI(isInner)));
affectedLookup = zeros(n,1,'uint32');
affectedLookup(affectedId) = uint32(1:numel(affectedId));
affectedPosition = affectedLookup(componentId(:));
affectedPixel = find(affectedPosition);
pixelGroups = accumarray(double(affectedPosition(affectedPixel)),affectedPixel, ...
  [numel(affectedId),1],@(x) {x});

cutI = cell(numel(affectedId),1);
cutJ = cell(numel(affectedId),1);

for k = 1:numel(affectedId)
  pixels = pixelGroups{k};

  A = A_Do(pixels,pixels);
  B = A_Db(pixels,pixels);
  [dI,dJ] = find(triu(B,1));

  [localI,localJ] = completeComponent(A,dI,dJ);
  cutI{k} = pixels(localI);
  cutJ{k} = pixels(localJ);
end

cutI = vertcat(cutI{:});
cutJ = vertcat(cutJ{:});

if ~isempty(cutI)
  added = sparse([cutI;cutJ],[cutJ;cutI],true,n,n);
  A_Do = A_Do - A_Do .* added;
  A_Db = A_Db | added;
  componentId = connectedComponents(A_Do);
end

if any(componentId(bdI) == componentId(bdJ))
  error('MTEX:calcGrains:boundaryCompletionFailed', ...
    'Boundary completion left an inner grain-boundary constraint.');
end

end

% -------------------------------------------------------------------------
function [cutI,cutJ] = completeComponent(A,dI,dJ)
% complete all boundary constraints within one initially connected component

n = size(A,1);
numDemands = numel(dI);
cutI = cell(numDemands,1);
cutJ = cell(numDemands,1);
numCuts = 0;

% Each queue entry is already connected and contains only constraints whose
% endpoints lie in that block. After a cut, only child blocks with unresolved
% constraints are queued. Thus later max-flow and component computations run
% on progressively smaller graphs rather than repeatedly on the original
% grain.
nodeQueue = cell(2*numDemands+1,1);
demandQueue = cell(2*numDemands+1,1);
nodeQueue{1} = (1:n).';
demandQueue{1} = (1:numDemands).';
head = 1;
tail = 1;
blockPosition = zeros(n,1);

while head <= tail
  nodes = nodeQueue{head};
  demands = demandQueue{head};
  head = head + 1;

  numNodes = numel(nodes);
  blockPosition(nodes) = 1:numNodes;
  posI = blockPosition(dI(demands));
  posJ = blockPosition(dJ(demands));
  ABlock = A(nodes,nodes);

  % Prefer a constraint whose endpoints are well connected to their
  % surroundings. This reduces the tendency of an unconstrained s-t cut to
  % isolate a single boundary pixel.
  degree = full(sum(ABlock,2));
  score = min(degree(posI),degree(posJ));
  [~,iBest] = max(score);
  source = posI(iBest);
  target = posJ(iBest);

  [edgeI,edgeJ,weight] = find(triu(ABlock,1));
  G = graph(double(edgeI),double(edgeJ),double(weight),numNodes);
  [~,~,sourceNodes] = maxflow(G,source,target);

  sourceSide = false(numNodes,1);
  sourceSide(sourceNodes) = true;
  isCut = sourceSide(edgeI) ~= sourceSide(edgeJ);

  if ~any(isCut)
    error('MTEX:calcGrains:boundaryCompletionFailed', ...
      'Could not separate an inner grain-boundary constraint.');
  end

  numCuts = numCuts + 1;
  cutI{numCuts} = nodes(edgeI(isCut));
  cutJ{numCuts} = nodes(edgeJ(isCut));

  % Split only the two sides of this cut. The source side is normally
  % connected already; connectedComponents also handles the rare case in
  % which the other side contains several components.
  for onSourceSide = [true false]
    demandOnSide = sourceSide(posI) == onSourceSide & ...
      sourceSide(posJ) == onSourceSide;
    if ~any(demandOnSide), continue; end

    childLocal = find(sourceSide == onSourceSide);
    childComponent = connectedComponents(ABlock(childLocal,childLocal));

    componentInBlock = zeros(numNodes,1);
    componentInBlock(childLocal) = childComponent;
    demandComponent = componentInBlock(posI(demandOnSide));
    sameComponent = demandComponent == componentInBlock(posJ(demandOnSide));
    if ~any(sameComponent), continue; end

    childDemands = demands(demandOnSide);
    childDemands = childDemands(sameComponent);
    demandComponent = demandComponent(sameComponent);

    componentIds = unique(demandComponent);
    for iComponent = 1:numel(componentIds)
      cId = componentIds(iComponent);
      tail = tail + 1;
      nodeQueue{tail} = nodes(childLocal(childComponent == cId));
      demandQueue{tail} = childDemands(demandComponent == cId);
    end
  end
end

cutI = vertcat(cutI{1:numCuts});
cutJ = vertcat(cutJ{1:numCuts});

end

% -------------------------------------------------------------------------
function [ignoreI,ignoreJ] = shortIsolatedBoundaries(A_Db,componentId,I_FD,F)
% find enclosed inner-boundary components with fewer than three segments

ignoreI = zeros(0,1);
ignoreJ = zeros(0,1);
componentId = componentId(:);

nFaces = size(I_FD,1);
if nFaces == 0 || size(F,1) ~= nFaces || size(F,2) ~= 2, return; end

% Extract paired and single-pixel faces directly from the sparse incidence
% list. Avoiding a dense nFaces-by-2 array matters for large maps.
I_FDt = I_FD.';
[pixelId,faceId] = find(I_FDt);
if isempty(faceId), return; end

sameAsPrevious = [false; faceId(2:end) == faceId(1:end-1)];
sameAsNext = [faceId(1:end-1) == faceId(2:end); false];
pairFaceId = faceId(sameAsPrevious);
pair = [pixelId(sameAsNext),pixelId(sameAsPrevious)];
singleFaceId = faceId(~sameAsPrevious & ~sameAsNext);

pairIndex = sub2ind(size(A_Db),pair(:,1),pair(:,2));
isBoundary = full(A_Db(pairIndex)) ~= 0;
isInner = isBoundary & ...
  componentId(pair(:,1)) == componentId(pair(:,2));
if ~any(isInner), return; end

innerFaceId = pairFaceId(isInner);
innerSegments = double(F(innerFaceId,:));
if any(innerSegments(:) < 1), return; end

% Boundary segments are connected exactly when their rows in F share a
% Voronoi vertex. Only the (usually small) set of inner segments enters this
% sparse product.
numInner = numel(innerFaceId);
numVertices = double(max(F(:)));
I_VB = sparse(innerSegments(:),[(1:numInner).';(1:numInner).'], ...
  true,numVertices,numInner);
boundaryComponent = connectedComponents(I_VB.' * I_VB);
boundaryComponent = boundaryComponent(:);

% Existing inter-grain boundaries and the exterior of the measured map both
% count as outer boundaries.
isOuterPair = isBoundary & ...
  componentId(pair(:,1)) ~= componentId(pair(:,2));
outerFaceId = [singleFaceId;pairFaceId(isOuterPair)];

outerVertex = false(numVertices,1);
outerSegments = double(F(outerFaceId,:));
outerSegments = outerSegments(outerSegments > 0);
outerVertex(outerSegments) = true;
touchesOuter = any(outerVertex(innerSegments),2);

numComponents = max(boundaryComponent);
componentSize = accumarray(boundaryComponent(:),1,[numComponents 1]);
componentTouchesOuter = accumarray(boundaryComponent(:),touchesOuter, ...
  [numComponents 1],@(x) any(x),false);

ignore = componentSize(boundaryComponent) < 3 & ...
  ~componentTouchesOuter(boundaryComponent);
innerPairs = pair(isInner,:);
ignoredPairs = unique(sort(innerPairs(ignore,:),2),'rows');
ignoreI = ignoredPairs(:,1);
ignoreJ = ignoredPairs(:,2);

end
