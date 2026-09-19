function [V,C] = calcVoronoi(ori,varargin)
% compute the Voronoi decomposition for unit quaternions
%
% Input
%  ori - @orientation
%
% Output
%  V - Voronoi--Vertices
%  C - Voronoi--Cells containing the index to the Voronoi--Vertex
%
% Flags
%  struct - C as center/vertex incidences and the number of orientations
%           sharing each cell
%
% See also
% S2Grid\calcVoronoi voronoin

oR = ori.CS.fundamentalRegion;
ori = ori.project2FundamentalRegion;
nOri = length(ori);

% take the orientations close to the boundary of the fundamental region
res = 45*degree;
isBND = abs(angle(oR,ori)) < res;

% their symmetric equivalents are the neighbours across the boundary
symRot = ori.CS.properGroup.rot;
rotBND = rotation(ori.subSet(isBND)) * symRot.subSet(2:length(symRot));
isBND2 = angle(oR,rotBND) < res;

q = [reshape(quaternion(ori),[],1);reshape(quaternion(rotBND.subSet(isBND2)),[],1)];
q = q .* (-1).^(q.a<0);

% every point of the cloud knows the orientation it descends from
src = repmat(reshape(find(isBND),[],1),1,length(symRot)-1);
src = [(1:nOri).';src(isBND2)];

% the 180 degree wall of the fundamental region is glued to itself
% antipodally, so a neighbour across it is the opposite quaternion
isWall = q.a < sin(res/2);
q = [q; -q.subSet(isWall)];
src = [src; src(isWall)];

% convhulln keeps one of a set of coincident points - let it stand for them
[~,firstQ,indQ] = unique(round(squeeze(double(q))*1e10),'rows','stable');
q = q.subSet(firstQ);

% an orientation reaching the cloud through several lifts is still one
% orientation, and every lift carries the whole cell
merge = accumarray(indQ,src,[],@min);
merge = merge(indQ(1:nOri));
mult = accumarray(merge,1,[nOri 1]);
mult = mult(merge);

% compute the Delaunay triangulation
if length(q)>1e5
  warning('The Voronoi decomposition is calculated. This may take some time.')
end
faces = convhulln(squeeze(double(q)));
% Voronoi-vertices are the intersections of the perpendicular bisector
V = cross(...
  q.subSet(faces(:,4))-q.subSet(faces(:,1)),...
  q.subSet(faces(:,3))-q.subSet(faces(:,1)),...
  q.subSet(faces(:,2))-q.subSet(faces(:,1)));

% some tetrahedrons may be degenerated - then take simply the mean
isBad = norm(V)<1e-8;
V = V.setSubSet(isBad,sum(reshape(q.subSet(faces(isBad,:)),nnz(isBad),4),2));

V = V.normalize;

% Voronoi-vertices around generators
[center, vertices] = sort(faces(:));
vertices = mod(vertices-1,length(V))+1;

% keep the cells of the orientations, each at its own lift
inc = sparse(center,vertices,1,length(q),length(V));
[vertices,center] = find(inc(indQ(1:nOri),:).');

if check_option(varargin,'struct')
  C = struct('center',center,'vertices',vertices,'mult',mult);
else % convert to cell list of vertices
  C = cell(nOri,1);
  last = [0;find(diff(center));length(center)];
  for k=1:length(last)-1
    ndx = last(k)+1:last(k+1);
    C{center(ndx(1))} = vertices(ndx);
  end
end

end
