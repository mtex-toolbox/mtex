function grains2d = slice(grains,varargin)
  % grain3d.slice is a method to slice the 3d grain data to get grain2d
  % data
  %
  % Syntax
  %   plane = createPlane([0.5 0.5 0.5],[1 1 1])
  %   grain2d = grains.slice(plane)
  %
  %   P0 = vector3d(0.5, 0.5, 0.5)    % point within plane
  %   N = vector3d(1,1,1)             % plane normal
  %   grain2d = grains.slice(P0,N)
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
% poly            - n x 1 cell array
% E               - Edges with respect indices of V
% FE              - cell array of faces with respect to indices of E
% crossingEdges   - indices of Edges crossing the plane
% crossingFaces   - indices of Faces crossing the plane
% crossingFE_all  - array n x 2 with only the Edges to be intersected,
%   1st dim with respect to crossingFaces, 2nd dim respect to E
% newV            - crossingEdges intersected with plane @vector3d
% newPoly         - intersected Polygons, indices to newV
% newIds          - Ids of the cells in the slice
% intersec_CF     - I_CF, but only intersected cells (newIds) and faces
%%

if nargin < 2
  error 'too few arguments. plane needed'
elseif nargin == 2
  plane = varargin{1};
elseif nargin == 3
  if isa(varargin{1},'vector3d')
    varargin{1} = varargin{1}.xyz;
    varargin{2} = varargin{2}.xyz;
  end
  plane = createPlane(varargin{1},varargin{2});
else
  error 'Input error'
end

V = grains.boundary.allV.xyz;
poly = grains.poly;

E = meshEdges(poly);
FE = meshFaceEdges(V, E, poly);

crossingEdges = find(xor(isBelowPlane(V(E(:,1),:),plane),isBelowPlane(V(E(:,2),:),plane)));
crossingFE_all = cell2mat(cellfun((@(el) ismember(crossingEdges,el)'), FE, 'UniformOutput', false));
intersecFaces = find(sum(crossingFE_all,2)==2);

% crossingFE_all: 1.dim with respect to intersecFaces, 2.dim with respect to
% crossingEdges
[i,j] = find(crossingFE_all);
[~,i2] = sort(i);
crossingFE_all = reshape(j(i2),2,[])';

newV = vector3d(intersectEdgePlane([V(E(crossingEdges,1),:) V(E(crossingEdges,2),:)],plane)).';

% intersec_CF = I_CF, but with only the intersected Faces in 2.dim and only
% the intersected Cells in 1.dim (newIds)
intersec_CF = grains.I_CF(:,intersecFaces);
newIds = find(any(intersec_CF,2));
intersec_CF = logical(intersec_CF(newIds,:));

newPoly = cell(size(intersec_CF,1),1);

for m = 1:length(newIds)

  crossingFE = crossingFE_all(intersec_CF(m,:),:);

  currPoly = zeros(1,size(crossingFE,1)+1);
  currPoly(1:2) = crossingFE(1,:);
  nextEdge = crossingFE(1,2);
  crossingFE(1,2) = 0;
  
  for n = 1:size(crossingFE,1)-1
    [i,j] = find(crossingFE==nextEdge);
    assert(length(i)==1)
    % abs(j-3) so 1=>2 and 2=>1
    nextEdge = crossingFE(i,abs(j-3));
    crossingFE(i,:) = [0 0];
    currPoly(n+2) = nextEdge;
  end
  newPoly(m) = {currPoly};
end

% TODO: id in grain2d implementieren
grains2d = grain2d(newV.xyz, newPoly, grains.meanOrientation(newIds),...
  grains.CSList, grains.phaseId(newIds), grains.phaseMap);

% check for clockwise poly's
isNeg = (grains2d.area<0);
grains2d.poly(isNeg) = cellfun(@fliplr, grains2d.poly(isNeg), 'UniformOutput', false);




