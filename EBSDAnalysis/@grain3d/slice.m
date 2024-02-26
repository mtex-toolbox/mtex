function grains2d = slice(grains,varargin)
% grain3d.slice is a method to slice the 3d grain data to get grain2d
% data
%
% Syntax
%
%   N = vector3d(1,1,1)             % plane normal
%   P0 = vector3d(0.5, 0.5, 0.5)    % point within plane
%   grain2d = grains.slice(N,P0)
%
%   V = vector3d([0 1 0],[0 1 1],[0 1 0])
%   grain2d = grains.slice(V)       % three points
%
%   plane = createPlane(P0,N)       % note different sequence of inputs!
%   grain2d = grains.slice(plane)   % plane in matGeom format
%
% Input
%  grains   - @grain3d
%  plane    - plane in matGeom format
% Output
%  grain2d  - @grain2d
%
% See also
% grain2d

%%
% plane           - plane in matGeom Format
% V               - n x 3 array with allVertices
% F               - n x 1 cell array or n x 3 array
% E               - Edges with respect indices of V
% FE              - cell array of faces with respect to indices of E
% crossingEdges   - indices of Edges crossing the plane
% crossingFaces   - indices of Faces crossing the plane
% crossingFE_all  - array n x 2 with only the Edges to be intersected,
%   1st dim with respect to crossingFaces, 2nd dim respect to E
% newV            - crossingEdges intersected with plane @vector3d
% newPoly         - intersected Polygons, indices to newV
% newIds          - Ids of the cells in the slice
% intersec_GF     - I_GF, but only intersected cells (newIds) and faces
%%

if nargin < 2
  error 'too few arguments'
elseif nargin == 2
  if isa(varargin{1},'vector3d')
    plane = fitPlane(varargin{1}.xyz);
  else
    plane = varargin{1};
  end
elseif nargin == 3
  if isa(varargin{1},'vector3d')
    varargin{1} = varargin{1}.xyz;
    varargin{2} = varargin{2}.xyz;
  end
  plane = createPlane(varargin{2},varargin{1});   % sequence of inputs: P0,N
elseif nargin >= 4
  pts = [varargin{1:3}];
  plane = fitPlane(pts.xyz);
else
  error 'Input error'
end

assert(isPlane(plane),'Input error')

V = grains.boundary.allV.xyz;
F = grains.F;

E = meshEdges(F);
FE = meshFaceEdges(V, E, F);

crossingEdges = find(xor(isBelowPlane(V(E(:,1),:),plane),isBelowPlane(V(E(:,2),:),plane)));
assert(~isempty(crossingEdges),'plane is outside of grain3d bounding box')

crossingFE_all = cell2mat(cellfun((@(el) ismember(crossingEdges,el)'), FE, 'UniformOutput', false));
intersecFaces = find(sum(crossingFE_all,2)==2);

% crossingFE_all: 1.dim with respect to intersecFaces, 2.dim with respect to
% crossingEdges
[i,j] = find(crossingFE_all);
[~,i2] = sort(i);
crossingFE_all = reshape(j(i2),2,[])';

newV = intersectEdgePlane([V(E(crossingEdges,1),:) V(E(crossingEdges,2),:)],plane);

% if one of the points of the edge lies within the plane, the line above 
% produces a nan value for this edge
if(any(isnan(newV)))
  iN = any(isnan(newV),2);
  d1 = distancePointPlane(V(E(crossingEdges(iN),1),:),plane);
  d2 = distancePointPlane(V(E(crossingEdges(iN),2),:),plane);
  if any([d1 d2]==0)
    [~,j] = find([d1 d2]==0);
    assert(length(j)==find(length(iN)),'intersecting crossing edges failed')
    newV(iN,:) = V(E(crossingEdges(iN),j),:);
  else
    error 'intersecting crossing edges failed'
  end
end

newV = vector3d(newV).';

% intersec_GF = I_GF, but with only the intersected Faces in 2.dim and only
% the intersected Cells in 1.dim (newIds)
intersec_GF = grains.I_GF(:,intersecFaces);
newIds = find(any(intersec_GF,2));
intersec_GF = logical(intersec_GF(newIds,:));

newPoly = cell(size(intersec_GF,1),1);

for m = 1:length(newIds)

  crossingFE = crossingFE_all(intersec_GF(m,:),:);

  currPoly = zeros(1,size(crossingFE,1)+1);
  currPoly(1:2) = crossingFE(1,:);
  nextEdge = crossingFE(1,2);
  crossingFE(1,2) = 0;
  
  for n = 1:size(crossingFE,1)-1
    [i,j] = find(crossingFE==nextEdge);
    assert(isscalar(i))
    % abs(j-3) so 1=>2 and 2=>1
    nextEdge = crossingFE(i,abs(j-3));
    crossingFE(i,:) = [0 0];
    currPoly(n+2) = nextEdge;
  end
  newPoly(m) = {currPoly};
end

grains2d = grain2d(newV.xyz, newPoly, grains.meanOrientation(newIds),...
  grains.CSList, grains.phaseId(newIds), grains.phaseMap, 'id', newIds);

% check for clockwise poly's
isNeg = (grains2d.area<0);
grains2d.poly(isNeg) = cellfun(@fliplr, grains2d.poly(isNeg), 'UniformOutput', false);




