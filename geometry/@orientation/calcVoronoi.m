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
% See also
% S2Grid\calcVoronoi voronoin

oR = ori.CS.fundamentalRegion;
ori = ori.project2FundamentalRegion;

% compute the angle to the boundary of the fundamental region
omega = angle(oR,ori);

% take the orientations close to the boundary of the fundamental region
%res = 2*mean(abs(omega));
res = 45*degree;
% ind = (1:length(ori)).';
isBND = abs(omega) < res;

symRot = ori.CS.rot;
oriBND = ori.subSet(isBND) * symRot.subSet(2:numSym(ori.CS));
% indBND = repmat(ind(isBND),1,length(symRot)-1);

omega2 = angle(oR,oriBND);
isBND2 = omega2 < res;

oriBND2 = oriBND.subSet(isBND2);
% indBND2 = indBND(isBND2);

oriExt = [reshape(ori,[],1);oriBND2];
% indExt = [ind;indBND2];

q = quaternion(oriExt);
q = q .* (-1).^(q.a<0);

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
V(isBad) = sum(reshape(q.subSet(faces(isBad,:)),nnz(isBad),4),2);

V = V.normalize;

% Voronoi-vertices around generators
% center -> oriExt
% vertices -> vertices
[center, vertices] = sort(faces(:));
vertices = mod(vertices'-1,length(V))+1;

% consider only the Voronoi center corresponding to ori, i.e. inside the
% fundamental region
ind = center<=length(ori);
center = center(ind);
vertices = vertices(ind);

if check_option(varargin,'struct')
  C = struct('center',center(:),'vertices',vertices(:));
else % convert to cell list of vertices
  C = cell(length(ori),1);
  last = [0;find(diff(center));length(center)];
  for k=1:length(last)-1
    ndx = last(k)+1:last(k+1);
    C{center(ndx(1))} = vertices( ndx );
  end
end

end
