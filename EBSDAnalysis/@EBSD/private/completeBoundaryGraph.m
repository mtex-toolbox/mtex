function [A_Do,A_Db,componentId] = completeBoundaryGraph(A_Do,A_Db,I_FD,F)
% extend inner boundaries to existing non-inner boundaries
%
% Input
%  A_Do - logical adjacency of connected pixels
%  A_Db - logical adjacency of pixel pairs marked as grain boundaries
%  I_FD - incidence matrix faces -> pixels
%  F    - vertex ids of the boundary segments
%
% Output
%  A_Do        - connectivity after the additional cuts
%  A_Db        - retained and additionally introduced boundary edges
%  componentId - connected component of every pixel
%
% The Voronoi segments form the planar dual of the pixel adjacency graph.
% Retained inner-boundary segments are extended through this dual graph until
% every free end reaches an existing non-inner boundary. An augmentation may
% connect different boundary components, but never two ends of the same
% component. Hence newly introduced segments cannot close into an isolated
% loop around a pixel.
%
% Every augmentation uses the smallest available number of new segments.
% The sequence of shortest paths is greedy; it is not a globally optimal
% Steiner forest.
%
% Isolated inner-boundary components with fewer than three segments are
% ignored. They usually originate from individual noisy pixels. Segment
% connectivity is determined from F, so a short inner boundary that reaches
% an existing grain or map boundary is retained.

n = size(A_Do,1);

% A detected boundary is initially a hard separation constraint. This is
% relevant for soft criteria, for which an edge can occur in both graphs.
A_Do = A_Do - A_Do .* A_Db;
componentId = connectedComponents(A_Do);
componentColumn = componentId(:);

topology = faceIncidence(I_FD);
if isempty(topology.pair), return; end

pairIndex = sub2ind(size(A_Db),topology.pair(:,1),topology.pair(:,2));
isBoundary = full(A_Db(pairIndex)) ~= 0;
isInner = isBoundary & ...
  componentColumn(topology.pair(:,1)) == componentColumn(topology.pair(:,2));
if ~any(isInner), return; end

% Suppress short enclosed fragments before constructing any shortest-path
% problem. Ignored faces become ordinary within-grain connections.
ignoreRow = shortIsolatedBoundaryRows(topology,F,isBoundary,isInner, ...
  componentColumn);
if ~isempty(ignoreRow)
  ignoredPair = topology.pair(ignoreRow,:);
  ignored = sparse([ignoredPair(:,1);ignoredPair(:,2)], ...
    [ignoredPair(:,2);ignoredPair(:,1)],true,n,n);
  A_Db = A_Db - A_Db .* ignored;
  A_Do = A_Do | ignored;

  isBoundary = full(A_Db(pairIndex)) ~= 0;
  isInner = isBoundary & ...
    componentColumn(topology.pair(:,1)) == componentColumn(topology.pair(:,2));
  if ~any(isInner), return; end
end

addedFaceId = anchoredBoundaryFaces(A_Do,isBoundary,isInner, ...
  componentColumn,topology,F);

if ~isempty(addedFaceId)
  pairRowOfFace = zeros(size(F,1),1,'uint32');
  pairRowOfFace(topology.pairFaceId) = uint32(1:size(topology.pair,1));
  addedRow = double(pairRowOfFace(addedFaceId));
  if any(addedRow == 0)
    error('MTEX:calcGrains:boundaryCompletionFailed', ...
      'A completed boundary contains a face without two incident pixels.');
  end

  addedPair = unique(sort(topology.pair(addedRow,:),2),'rows');
  added = sparse([addedPair(:,1);addedPair(:,2)], ...
    [addedPair(:,2);addedPair(:,1)],true,n,n);
  A_Do = A_Do - A_Do .* added;
  A_Db = A_Db | added;
end

componentId = connectedComponents(A_Do);
[bdI,bdJ] = find(triu(A_Db,1));
if any(componentId(bdI) == componentId(bdJ))
  error('MTEX:calcGrains:boundaryCompletionFailed', ...
    ['Boundary completion could not anchor every retained inner boundary ' ...
    'at non-inner boundaries.']);
end

end

% -------------------------------------------------------------------------
function topology = faceIncidence(I_FD)
% extract paired and single-pixel faces from a sparse face incidence matrix

I_FDt = I_FD.';
[pixelId,faceId] = find(I_FDt);

if isempty(faceId)
  topology.pairFaceId = zeros(0,1);
  topology.pair = zeros(0,2);
  topology.singleFaceId = zeros(0,1);
  topology.singlePixel = zeros(0,1);
  return;
end

sameAsPrevious = [false; faceId(2:end) == faceId(1:end-1)];
sameAsNext = [faceId(1:end-1) == faceId(2:end); false];

topology.pairFaceId = faceId(sameAsPrevious);
topology.pair = [pixelId(sameAsNext),pixelId(sameAsPrevious)];
isSingle = ~sameAsPrevious & ~sameAsNext;
topology.singleFaceId = faceId(isSingle);
topology.singlePixel = pixelId(isSingle);

end

% -------------------------------------------------------------------------
function ignoreRow = shortIsolatedBoundaryRows(topology,F,isBoundary, ...
  isInner,componentId)
% find enclosed inner-boundary components with fewer than three segments

innerRow = find(isInner);
innerFaceId = topology.pairFaceId(innerRow);
innerSegments = double(F(innerFaceId,:));

if isempty(innerSegments) || any(innerSegments(:) < 1)
  ignoreRow = zeros(0,1);
  return;
end

numInner = numel(innerFaceId);
[~,~,innerVertexGroup] = unique(innerSegments(:));
I_VB = sparse(innerVertexGroup,[(1:numInner).';(1:numInner).'], ...
  true,max(innerVertexGroup),numInner);
boundaryComponent = connectedComponents(I_VB.' * I_VB);
boundaryComponent = boundaryComponent(:);

isOuterPair = isBoundary & ...
  componentId(topology.pair(:,1)) ~= componentId(topology.pair(:,2));
outerFaceId = [topology.singleFaceId;topology.pairFaceId(isOuterPair)];
outerSegments = double(F(outerFaceId,:));
outerVertex = unique(outerSegments(outerSegments > 0));
touchesOuter = any(ismember(innerSegments,outerVertex),2);

numComponents = max(boundaryComponent);
componentSize = accumarray(boundaryComponent,ones(size(boundaryComponent)), ...
  [numComponents 1]);
componentTouchesOuter = accumarray(boundaryComponent,touchesOuter, ...
  [numComponents 1],@(x) any(x),false);

ignore = componentSize(boundaryComponent) < 3 & ...
  ~componentTouchesOuter(boundaryComponent);
ignoreRow = innerRow(ignore);

end

% -------------------------------------------------------------------------
function addedFaceId = anchoredBoundaryFaces(A_Do,isBoundary,isInner, ...
  componentId,topology,F)
% complete each affected grain in the dual boundary-segment graph

pairIndex = sub2ind(size(A_Do),topology.pair(:,1),topology.pair(:,2));
isConnected = full(A_Do(pairIndex)) ~= 0;
pairComponent1 = componentId(topology.pair(:,1));
pairComponent2 = componentId(topology.pair(:,2));

affectedId = unique(pairComponent1(isInner));
addedByComponent = cell(numel(affectedId),1);

for iComponent = 1:numel(affectedId)
  gId = affectedId(iComponent);

  innerRow = find(isInner & pairComponent1 == gId);
  innerFaceId = topology.pairFaceId(innerRow);

  candidateRow = find(isConnected & pairComponent1 == gId & ...
    pairComponent2 == gId);
  candidateFaceId = topology.pairFaceId(candidateRow);

  isOuterPair = isBoundary & ...
    ((pairComponent1 == gId) ~= (pairComponent2 == gId));
  isOuterSingle = componentId(topology.singlePixel) == gId;
  outerFaceId = [topology.pairFaceId(isOuterPair); ...
    topology.singleFaceId(isOuterSingle)];
  outerVertex = unique(double(F(outerFaceId,:)));
  outerVertex = outerVertex(outerVertex > 0);

  addedByComponent{iComponent} = completeBoundaryNetwork(F,innerFaceId, ...
    candidateFaceId,outerVertex);
end

addedFaceId = vertcat(addedByComponent{:});

end

% -------------------------------------------------------------------------
function addedFaceId = completeBoundaryNetwork(F,boundaryFaceId, ...
  candidateFaceId,outerVertex)
% join every non-outer boundary endpoint to a different network or the outer

originalFaceId = boundaryFaceId;
addedFaceId = zeros(0,1);

while true
  [faceComponent,endPoint,endPointComponent,boundaryVertex, ...
    boundaryVertexComponent] = boundaryNetworkInfo(F,boundaryFaceId);

  isOuterEnd = ismember(endPoint,outerVertex);
  freeEnd = endPoint(~isOuterEnd);
  freeEndComponent = endPointComponent(~isOuterEnd);

  if isempty(freeEnd)
    numComponents = max(faceComponent);
    numEnds = accumarray(endPointComponent,ones(size(endPointComponent)), ...
      [numComponents 1]);
    if any(numEnds == 0)
      error('MTEX:calcGrains:boundaryCompletionLoop', ...
        ['A retained inner boundary forms a closed loop that cannot be ' ...
        'anchored without connecting the boundary to itself.']);
    end
    break;
  end

  bestLength = inf;
  bestPathFace = zeros(0,1);

  % Choose the globally shortest admissible next augmentation. Targets may
  % be outer-boundary vertices or free ends of a different boundary network.
  for iEnd = 1:numel(freeEnd)
    source = freeEnd(iEnd);
    sourceComponent = freeEndComponent(iEnd);
    sourceBoundaryVertex = ...
      boundaryVertex(boundaryVertexComponent == sourceComponent);

    outerTarget = outerVertex(~ismember(outerVertex,sourceBoundaryVertex));
    otherEndTarget = endPoint(endPointComponent ~= sourceComponent);
    target = unique([outerTarget;otherEndTarget]);
    if isempty(target), continue; end

    [pathFaceId,pathLength] = shortestBoundaryPath(F,candidateFaceId, ...
      source,target,boundaryVertex);

    if pathLength < bestLength
      bestLength = pathLength;
      bestPathFace = pathFaceId;
    end
  end

  if isempty(bestPathFace)
    error('MTEX:calcGrains:boundaryCompletionFailed', ...
      ['Could not extend a free inner-boundary end to a different boundary ' ...
      'network or a non-inner boundary.']);
  end

  boundaryFaceId = [boundaryFaceId;bestPathFace];
  addedFaceId = [addedFaceId;bestPathFace]; %#ok<AGROW>

  used = ismember(candidateFaceId,bestPathFace);
  candidateFaceId(used) = [];
end

% Every returned face is an actual addition, even if input data contained
% duplicate segment ids.
addedFaceId = setdiff(unique(addedFaceId),originalFaceId,'stable');

end

% -------------------------------------------------------------------------
function [faceComponent,endPoint,endPointComponent,boundaryVertex, ...
  boundaryVertexComponent] = boundaryNetworkInfo(F,boundaryFaceId)
% components and free ends of the current boundary-segment network

segments = double(F(boundaryFaceId,:));
numFaces = numel(boundaryFaceId);
[boundaryVertex,~,vertexGroup] = unique(segments(:));
I_VB = sparse(vertexGroup,[(1:numFaces).';(1:numFaces).'], ...
  true,numel(boundaryVertex),numFaces);
faceComponent = connectedComponents(I_VB.' * I_VB);
faceComponent = faceComponent(:);

vertexDegree = accumarray(vertexGroup,1);
boundaryVertexComponent = accumarray(vertexGroup, ...
  [faceComponent;faceComponent],[],@max);

isEnd = vertexDegree == 1;
endPoint = boundaryVertex(isEnd);
endPointComponent = boundaryVertexComponent(isEnd);

end

% -------------------------------------------------------------------------
function [pathFaceId,pathLength] = shortestBoundaryPath(F,candidateFaceId, ...
  source,target,boundaryVertex)
% shortest candidate-face path from source to any admissible target

pathFaceId = zeros(0,1);
pathLength = inf;
if isempty(candidateFaceId), return; end

candidateSegments = double(F(candidateFaceId,:));
[~,~,localId] = unique([candidateSegments(:,1);candidateSegments(:,2); ...
  boundaryVertex(:);target(:);source]);
numCandidate = size(candidateSegments,1);
numBoundaryVertex = numel(boundaryVertex);
numTarget = numel(target);

localI = localId(1:numCandidate);
localJ = localId(numCandidate+1:2*numCandidate);
boundaryLocal = localId(2*numCandidate+1: ...
  2*numCandidate+numBoundaryVertex);
targetLocal = localId(2*numCandidate+numBoundaryVertex+1: ...
  2*numCandidate+numBoundaryVertex+numTarget);
sourceLocal = localId(end);

blocked = false(max(localId),1);
blocked(boundaryLocal) = true;
blocked(sourceLocal) = false;
blocked(targetLocal) = false;
active = ~blocked(localI) & ~blocked(localJ);
if ~any(active), return; end

activeFaceId = candidateFaceId(active);
localI = localI(active);
localJ = localJ(active);

% The local ids above avoid graph objects with millions of isolated vertices
% when only one grain of a large EBSD map is affected.
superTarget = max(localId) + 1;

G = graph([localI;targetLocal],[localJ; ...
  repmat(superTarget,numel(targetLocal),1)],[],superTarget);
[pathLocal,pathLength] = shortestpath(G,sourceLocal,superTarget, ...
  'Method','unweighted');
if isempty(pathLocal) || ~isfinite(pathLength), return; end

pathLocal(end) = []; % remove the artificial super-target
pathLength = pathLength - 1;
if numel(pathLocal) < 2
  pathLength = inf;
  return;
end

numLocalVertices = max(localId);
edgeKey = double(min(localI,localJ)-1) * numLocalVertices + ...
  double(max(localI,localJ));
pathKey = double(min(pathLocal(1:end-1),pathLocal(2:end))-1) * ...
  numLocalVertices + double(max(pathLocal(1:end-1),pathLocal(2:end)));
[isCandidate,pathPosition] = ismember(pathKey,edgeKey);
if ~all(isCandidate)
  pathFaceId = zeros(0,1);
  pathLength = inf;
  return;
end

pathFaceId = activeFaceId(pathPosition);

end
