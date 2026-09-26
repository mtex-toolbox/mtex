function grains2 = slice(grains3,plane,varargin)
% slice 3d-grains to obtain 2d-grains
%
% Syntax
%   N = vector3d(1,1,1)             % plane normal
%   P0 = vector3d(0.5, 0.5, 0.5)    % point within plane
%   grain2d = grains.slice(N,P0)
%
%   plane = plane3d.fit(v)
%   grain2d = grains.slice(plane)  
%
% Input
%  grains3   - @grain3d
%  plane    - @plane3d
%
% Output
%  grains2  - @grain2d
%
% See also
% grain2d grain3d/intersected

if ~isa(plane,'plane3d'), plane = plane3d(plane,varargin{:}); end

% we want to avoid that the plane go exactly through the vertices
plane.d = plane.d + 0.001 * (-1)^(plane.d>0);

% step 1: find intersected grains
isInter = grains3.intersected(plane);

if ~any(isInter), grains2 = grain2d; return, end

I_GF = grains3.I_GF;
FId = find(any(I_GF(isInter,:)));

% step 2: compute edges
if iscell(grains3.F)

  F = grains3.F(any(grains3.I_GF(isInter,:)));
  numE = cellfun(@numel,F)-1; % number of edge per face
  E1 = cellfun(@(x) x(1:end-1),F,'UniformOutput',false);
  E2 = cellfun(@(x) x(2:end),F,'UniformOutput',false);
  [E,~,EId] = unique(sort([E1{:};E2{:}],1).','rows');
  FId = repelem(FId,numE).';

else % triangulated shape

  F = grains3.F(any(grains3.I_GF(isInter,:)),:);
  E = [F(:,1),F(:,2);F(:,2),F(:,3);F(:,3),F(:,1)];
  FId = [FId,FId,FId].';

  [E,~,EId] = unique(sort(E,2),'rows');  

end

% step 3: compute intersection points -> new vertices
VNew = plane.intersect(grains3.allV(E(:,1)),grains3.allV(E(:,2)));
isInterE = ~isnan(VNew);
VNew = VNew(isInterE);

% step 4: compute 
% incidence matrix faces - reduced edges aka VNew
I_FVNew = sparse(FId(isInterE(EId)),EId(isInterE(EId)),true,...
  size(I_GF,2), size(E,1));
I_FVNew = I_FVNew(:,isInterE);

% faces that have two intersections create a new edge in the plane
hasEdge = sum(I_FVNew,2) == 2;
I_FVNew(~hasEdge,:) = 0; % TODO: what do we do in case of 1 or more than 3 intersections points
[FNew,FOld] = find(I_FVNew.');
FNew = reshape(FNew,2,[]).';
FOld = FOld(2:2:end).';

% this seems to work
%mapScatter(VNew)
%line(VNew.x(FNew).',VNew.y(FNew).',VNew.z(FNew).')
%
%mapScatter(VNew)
%for k = 1:size(FNew,1)
%  line(VNew.x(FNew(k,:)).',VNew.y(FNew(k,:)).',VNew.z(FNew(k,:)).')
%  pause
%end

% incidence matrix between the intersected grains and the new edges FNew
I_FNewG = (I_GF(isInter,FOld)~=0).';

% step 5: compute polygons
[poly,inclusionId] = calcPolygonsC(I_FNewG,FNew,VNew,plane.N);

oldId = find(isInter);

% calcPolygonsC returns every further loop of a grain as an inclusion, but a
% 3d grain may be cut into several pieces: a loop inside an odd number of the
% grain's other loops is a hole, any other loop a piece of its own
e1 = normalize(orth(plane.N)); e2 = cross(plane.N,e1);
xy = [dot(VNew,e1), dot(VNew,e2)];
newPoly = {};
for k = find(inclusionId(:).' > 0)

  % the loops: the first one closed, each further one closed and followed by
  % the first vertex of the grain, which it may pass through itself
  p = poly{k};
  loops = {p(1:end-inclusionId(k))};
  rest = p(end-inclusionId(k)+1:end);
  s = 1;
  while s < numel(rest)
    e = s + find(rest(s+1:end) == rest(s),1);
    loops{end+1} = rest(s:e); %#ok<AGROW>
    s = e + 2;
  end

  % loops may touch, so containment is decided at a vertex off the other loop
  n = numel(loops);
  inside = false(n);
  for i = 1:n
    for j = [1:i-1,i+1:n]
      v = setdiff(loops{i},loops{j});
      if isempty(v), continue; end
      inside(i,j) = inpolygon(xy(v(1),1),xy(v(1),2),xy(loops{j},1),xy(loops{j},2));
    end
  end
  isHole = mod(sum(inside,2),2) == 1;
  area = cellfun(@(l) polyarea(xy(l,1),xy(l,2)),loops);

  % every hole belongs to the smallest piece around it; the further pieces,
  % traced as inclusions, are turned round
  pieces = find(~isHole).';
  for i = pieces(2:end), loops{i} = fliplr(loops{i}); end
  parts = cell(1,n);
  for i = pieces, parts{i} = loops{i}; end
  for i = find(isHole).'
    around = pieces(inside(i,pieces));
    [~,m] = min(area(around));
    parts{around(m)} = [parts{around(m)}, loops{i}, parts{around(m)}(1)];
  end

  poly{k} = parts{1};
  newPoly = [newPoly; parts(pieces(2:end)).']; %#ok<AGROW>
  oldId = [oldId; repmat(oldId(k),numel(pieces)-1,1)]; %#ok<AGROW>

end
poly = [poly; newPoly];

% new 2d grains
grains2 = grain2d(VNew, poly, grains3.prop.meanRotation(oldId),...
  grains3.CSList, grains3.phaseId(oldId), grains3.phaseMap, 'id', 1:length(poly));
grains2.prop.Id3d = oldId;

end
