

cs = crystalSymmetry('432');

res = 12*degree;
ori = rotation.rand * equispacedSO3Grid(cs,'resolution',res)

ori = ori.project2FundamentalRegion; ori = ori(:);

oR = cs.fundamentalRegion;

w = ori.calcVoronoiVolume;

plot(ori,'axisAngle')







%%

omega = angle(oR,ori);
max(omega)
clf
histogram(omega./degree)

%%

ind = (1:length(ori)).';
isBND = abs(omega) < res * 2;

plot(ori(isBND),'axisAngle')

symRot = ori.CS.rot;

oriBND = ori(isBND) * symRot(2:end);
indBND = repmat(ind(isBND),1,length(symRot)-1);

omega2 = angle(oR,oriBND);

%%

isBND2 = omega2 < res*2;

oriBND2 = oriBND(isBND2);
indBND2 = indBND(isBND2);

plot(ori,'axisAngle')
hold on
plot(oriBND2,'axisAngle','noBoundaryCheck')
hold off

oriExt = [ori;oriBND2];
intExt = [ind;indBND2];

sum(oR.checkInside(oriBND2))

%%

q = quaternion(oriExt);

% compute the delaunay triangulation
faces = convhulln(squeeze(double(q)));

% voronoi-vertices
V = normalize(cross(...
  q.subSet(faces(:,4))-q.subSet(faces(:,1)),...
  q.subSet(faces(:,3))-q.subSet(faces(:,1)),...
  q.subSet(faces(:,2))-q.subSet(faces(:,1))));


% voronoi-vertices around generators
[center, vertices] = sort(faces(:));
vertices = mod(vertices'-1,length(V))+1;

% center -> oriExt
% vertices -> vertices

center = center(center<=length(ori));

%% make a cell list consting of the vertices for each orientation

C = cell(length(ori),1);
last = [0;find(diff(center));length(center)];
for k=1:length(last)-1  
  ndx = last(k)+1:last(k+1);
  C{center(ndx(1))} = vertices( ndx );
end

%%

% compute edges
if nargout>3
  faces = faces(first,:);   % delete duplicated faces (look at line 39)
  faces = sort(faces,2);
  f = [faces(:,[2 3 4]); faces(:,[1 3 4]); faces(:,[1 2 4]); faces(:,[1 2 3])];
  [~,first,f] = unique(f,'rows','first');
  [~,last,~] = unique(f,'rows','last');
  first = mod(first-1,length(V))+1;
  last = mod(last-1,length(V))+1;
  E = [first,last];
  % G = graph(first,last);
  % E = adjacency(G);
end


%%

% now we delete duplicated voronoi vertices
eps = 10^-10; % machine precision
[~,first,ind] = unique(round(squeeze(double(V))/eps)/eps,'rows');
V = V.subSet(first); 
left = ind(vertices)';

% erase duplicated vertices in the pointer list
dublicated = find([diff(vertices)==0,false]);

% check whether the duplicated is in the next cell // they shouldn't be
% deleted
last = [0;find(diff(center));length(center)];
dublicated(ismember(dublicated,last)) = [];

left(dublicated) = [];
center(dublicated) = [];




 
% Now in V some rotations occurs a second time by there opposite quaternion
% for example try: unique(rotation(V))


% compute edges
if nargout>3
  faces = faces(first,:);   % delete duplicated faces (look at line 39)
  faces = sort(faces,2);
  f = [faces(:,[2 3 4]); faces(:,[1 3 4]); faces(:,[1 2 4]); faces(:,[1 2 3])];
  [~,first,f] = unique(f,'rows','first');
  [~,last,~] = unique(f,'rows','last');
  first = mod(first-1,length(V))+1;
  last = mod(last-1,length(V))+1;
  E = [first,last];
  % G = graph(first,last);
  % E = adjacency(G);
end







% q sind die Ecken der Tetraeder, d.h. die Zentren der Polyeder
% V sind die Zentren der Umkugel der Tetraeder, d.h. die Ecken der q umgebenden Polyeder.
% C sind die Ecken des Polyeders zu jedem q
% E sind die Kanten



% volume
V = cross(...
  q.subSet(faces(:,4))-q.subSet(faces(:,1)),...
  q.subSet(faces(:,3))-q.subSet(faces(:,1)),...
  q.subSet(faces(:,2))-q.subSet(faces(:,1)));

plot(V.normalize,'filled','markercolor','red','axisAngle','noBoundaryCheck')


%%

histogram(norm(V))

accumarray(V)



%%

ori = equispacedSO3Grid(cs,'resolution',5*degree)

ori = ori.project2FundamentalRegion; ori = ori(:);

q = quaternion(ori);

% compute the delaunay triangulation
faces = convhulln(squeeze(double(q)));

delta = [norm(q(faces(:,2)) - q(faces(:,1))), ...
  norm(q(faces(:,3)) - q(faces(:,1))),...
  norm(q(faces(:,4)) - q(faces(:,1))),...
  norm(q(faces(:,3)) - q(faces(:,2))),...
  norm(q(faces(:,4)) - q(faces(:,2))),...
  norm(q(faces(:,4)) - q(faces(:,3)))];

ind = faces(:,[2:4,3:4,4,1,1,1,2,2,3]);
delta = [delta,delta];

sepDist = accumarray(ind(:),delta(:),size(ori),@max);

close all
histogram(sepDist,'NumBins',100)

%%

ind = sepDist>mean(sepDist);
plot(ori(ind),sepDist(ind),'axisangle','filled')

%setColorRange([0,0.2])

oR = fundamentalRegion(ori.CS);

oriNew = ori(ind).symmetrise;

oriNew(oR.checkInside(oriNew)) = [];

%%

plot(oriNew,'axisangle','filled','noBoundaryCheck')


%%

histogram(sepDist)




%%




% voronoi-vertices
V = normalize(cross(...
  q.subSet(faces(:,4))-q.subSet(faces(:,1)),...
  q.subSet(faces(:,3))-q.subSet(faces(:,1)),...
  q.subSet(faces(:,2))-q.subSet(faces(:,1))));


%% find those orientations that are close to the boundary of the fundamental region




