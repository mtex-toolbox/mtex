function grains2d = slice(grains,varargin)
% grain3d.slice is a method to intersect 3D grain data by a plane to get 
% grain2d slices
%
% Syntax
%
%   N = vector3d(1,1,1)             % plane normal
%   P0 = vector3d(0.5, 0.5, 0.5)    % point within plane
%   grain2d = grains.slice(N,P0)
%
%   V = vector3d([0 1 0],[0 1 1],[0 1 0])
%   grain2d = grains.slice(V)       % set of points
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
% grain2d grain3d/intersected

%% Processing inputs
% plane           - plane in matGeom Format
if nargin < 2
  error 'too few arguments'
elseif nargin == 2            
  if isa(varargin{1},'vector3d')                  % set of points
    plane = fitPlane(varargin{1}.xyz);
  else
    plane = varargin{1};                          % plane in matGeom format
  end
elseif nargin == 3
  if isa(varargin{1},'vector3d')                  % N & P0 as vector3d
    varargin{1} = varargin{1}.xyz;
    varargin{2} = varargin{2}.xyz;
  end                                             % N & P0 as xyz
  plane = createPlane(varargin{2},varargin{1});   % different sequence of inputs for createPlane: P0,N
elseif nargin >= 4
  pts = [varargin{1:3}];                          % three points within the plane
  plane = fitPlane(pts.xyz);
else
  error 'Input error'
end

assert(isPlane(plane),'Input error')

%% TODO:
% faces with more than 2 intersected edges  (line 83)
% handling of crossroads and inclusions     (line 146, 157)

%%
inters_grains = grains.subSet(grains.intersected(plane)); % restrict to affected cells
newIds = inters_grains.id;                 % Ids of the new grains2d

V = inters_grains.boundary.allV.xyz;    % all vertices as xyz
V_is_below_P = isBelowPlane(V,plane);   % check if V is below plane
F = inters_grains.F;                    % all faces (polys) as nx1-cell or nx3 array
E = meshEdges(F);                       % incidence matrix edges - vertices (indices to V)

%% identify which faces and edges are affected
% list of edges crossing the plane, indices to E
crossingEdges = find(xor(V_is_below_P(E(:,1)),V_is_below_P(E(:,2))));
assert(length(crossingEdges)>=3,'plane is outside of grain3d bounding box')

% compute incidence matrix F - crossingEdges
if iscell(F)
  % input (grains3d) is not triangulated
  FE = meshFaceEdges(V, E, F);  % n x 1 cell list of Faces, indices of E
  crossingFE_all = cell2mat(cellfun((@(el) ismember(crossingEdges,el)'), FE, 'UniformOutput', false));
else
  % input (grains3d) is triangulated
  crossingFE_all = zeros(size(F,1),size(crossingEdges,1));
  for i = 1:length(F)
    crossingFE_all(i,:)=(sum(F(i,:)==E(crossingEdges,1),2)==1 & sum(F(i,:)==E(crossingEdges,2),2)==1)';
  end
end

% list of only intersected faces, indices to F
intersecFaces = find(sum(crossingFE_all,2)==2);   % a face is intersected if (at least) 2 crossing Edges belong to it

% restrict crossingFE_all to intersected Faces
[i,j] = find(crossingFE_all(intersecFaces,:));
[~,i2] = sort(i);
crossingFE_all = reshape(j(i2),2,[])';

% crossingEdges   - list of edges crossing the plane, indices to E
% intersecFaces   - list of intersected faces, indices to F
% crossingFE_all  - incidence matrix, 1.dim with respect to intersecFaces, 2.dim with respect to crossingEdges

%% newV
% compute new vertices of the 2d slice (crossingEdges intersected with plane)
newV = intersectEdgePlane([V(E(crossingEdges,1),:) V(E(crossingEdges,2),:)],plane);   % nx3 array of vertices (xyz)

% if one of the points of the edge lies directly within the plane, intersectEdgePlane 
% produces a nan value for this edge, solution:
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

% make newV list of @vector3d
newV = vector3d(newV).';

% restrict I_GF to the intersected Faces (intersecFaces)
intersec_GF = logical(inters_grains.I_GF(:,intersecFaces));

% newV        - vertices of the new grains2d slice (crossingEdges intersected with plane)
% intersec_GF - Incidence matrix newIds - intersecFaces

%% new polygons for grains2d
% empty cell array
newPoly = cell(size(intersec_GF,1),1);

% assemble polygon for each intersected cell
for m = 1:length(newIds)

  % list n x 2 of all affected faces for this cell (2 intersected edges per face), 1.dim: intersecFaces, indices to crossingEdges
  crossingFE = crossingFE_all(intersec_GF(m,:),:);

  % empty cell for poly, initialize with first line, set next edge
  currPoly = zeros(1,size(crossingFE,1)+1);
  currPoly(1:2) = crossingFE(1,:);
  nextEdge = crossingFE(1,2);
  % set only second column of this row to 0, so can detect closed loops later
  crossingFE(1,2) = 0;
  % initialize iterator and closed loop counter
  numPoly = 1;        % number of closed loops
  n = 1;
  
  while n <= size(crossingFE,1)+numPoly-2   % one more round for each closed loop
    % find adjacent face (same edge)
    [i,j] = find(crossingFE==nextEdge);

    if nextEdge == 0  % closed loop -> more than one closed polygon
      numPoly = numPoly + 1;
      % chose next face, that has not been processed
      i = find(crossingFE(:,1)~=0);
      i = i(1);
      nextEdge = crossingFE(i,2);
      crossingFE(i,2) = 0;   % set only second column of this row to 0, so can detect closed loops later
      % overwrite last 0 in poly and add new edge
      currPoly(n+1) = crossingFE(i,1);
      currPoly(n+2) = nextEdge;
    else
      if ~isscalar(i) % points of contact/Crossroads (inclusions, ...)
        % take first alternative
        i = i(1);
        j = j(1);
      end
      % take next edge from the other column (abs(j-3) so 1=>2 and 2=>1)
      nextEdge = crossingFE(i,abs(j-3));
      % set this row to zero, add edge to poly
      crossingFE(i,:) = [0 0];
      currPoly(n+2) = nextEdge;
    end
    n = n + 1;
  end
  % add polygon for this cell to list, move on to next cell
  newPoly(m) = {currPoly};
end

%% new 2d grains
grains2d = grain2d(newV.xyz, newPoly, grains.meanOrientation(newIds),...
  grains.CSList, grains.phaseId(newIds), grains.phaseMap, 'id', newIds);

% check for clockwise poly's
isNeg = (grains2d.area<0);
grains2d.poly(isNeg) = cellfun(@fliplr, grains2d.poly(isNeg), 'UniformOutput', false);

end