function [A_Do,A_Db,componentId] = completeBoundaryGraph(A_Do,A_Db)
% extend inner boundaries by recursively applying local minimum cuts
%
% Input
%  A_Do - weighted adjacency of connected pixels
%  A_Db - logical adjacency of pixel pairs marked as grain boundaries
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

n = size(A_Do,1);

% A boundary is a hard separation constraint. This is relevant for soft or
% low-angle criteria, for which an edge can currently occur in both graphs.
A_Do = A_Do - A_Do .* A_Db;

[bdI,bdJ] = find(triu(A_Db,1));
componentId = connectedComponents(A_Do);

if isempty(bdI), return; end

isInner = componentId(bdI) == componentId(bdJ);
if ~any(isInner), return; end

% Determine the pixels of every affected component without scanning the
% complete pixel array once per grain.
[sortedId,pixelOrder] = sort(componentId(:));
first = [1; find(diff(sortedId)) + 1];
last = [first(2:end) - 1; n];
presentId = sortedId(first);

firstOf = zeros(max(componentId),1);
lastOf = zeros(max(componentId),1);
firstOf(presentId) = first;
lastOf(presentId) = last;

affectedId = unique(componentId(bdI(isInner)));
cutI = cell(numel(affectedId),1);
cutJ = cell(numel(affectedId),1);

for k = 1:numel(affectedId)
  gId = affectedId(k);
  pixels = pixelOrder(firstOf(gId):lastOf(gId));

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
cutI = cell(0,1);
cutJ = cell(0,1);
componentId = connectedComponents(A);

while true
  isInner = componentId(dI) == componentId(dJ);
  if ~any(isInner), break; end

  % Prefer a constraint whose two endpoints are well connected to their
  % surroundings. This reduces the tendency of an unconstrained s-t cut to
  % isolate a single boundary pixel.
  candidates = find(isInner);
  degree = full(sum(A,2));
  score = min(degree(dI(candidates)),degree(dJ(candidates)));
  [~,iBest] = max(score);
  iDemand = candidates(iBest);
  source = dI(iDemand);
  target = dJ(iDemand);

  [edgeI,edgeJ,weight] = find(triu(A,1));
  G = graph(double(edgeI),double(edgeJ),double(weight),n);
  [~,~,sourceSide] = maxflow(G,source,target);

  inSource = false(n,1);
  inSource(sourceSide) = true;
  isCut = inSource(edgeI) ~= inSource(edgeJ);

  if ~any(isCut)
    error('MTEX:calcGrains:boundaryCompletionFailed', ...
      'Could not separate an inner grain-boundary constraint.');
  end

  newI = edgeI(isCut);
  newJ = edgeJ(isCut);
  cutI{end+1,1} = newI; %#ok<AGROW>
  cutJ{end+1,1} = newJ; %#ok<AGROW>

  cut = sparse([newI;newJ],[newJ;newI],true,n,n);
  A = A - A .* cut;
  componentId = connectedComponents(A);
end

cutI = vertcat(cutI{:});
cutJ = vertcat(cutJ{:});

end
