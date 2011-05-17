function [grains ebsd] = segment3d(ebsd,varargin)
% neighour threshold segmentation of ebsd data
%
%% Input
%  ebsd   - @EBSD
%
%% Output
%  grains  - @grain
%  ebsd    - connected @EBSD data
%
%% Options
%  threshold     - array of threshold angles per phase of mis/disorientation in radians
%  property      - angle (default) or property of @EBSD data
%
%    * |'cube'|
%    * |'cubeI'|
%    * |'sphere'|
%
%  angletype     -
%
%    * |'misorientation'| (default)
%    * |'disorientation'|
%
%% See also
% grain/grain EBSD/calcGrains EBSD/segment2d

%% segmentation
% prepare data

% s = tic;

thresholds = get_option(varargin,{'threshold','angle'},15*degree);
if numel(thresholds) == 1 && numel(ebsd) > 1
  thresholds = repmat(thresholds,size(ebsd));
end


l = sampleSize(ebsd);
rl = [ 0 cumsum(l)];


X = vertcat(ebsd.X);

if isempty(X), error('no spatial data');end

% sort for voronoi
[Xt m n]  = unique(X(:,[3 2 1]),'first','rows');
clear Xt

X = X(m,:);
d = size(X,1);                % number of adjacent cells

if numel(m) ~= numel(n)
  warning('mtex:GrainGeneration','spatially duplicated data points, perceed by erasing them')
  ind = ~ismember(1:sum(sampleSize(ebsd)),m);
  [grains ebsd] = segment3d(delete(ebsd,ind),varargin{:});
  return
end

phase = get(ebsd,'phases');
[Al,Ar,sz,dz,lz] = spatialdecomposition3d(X,'unitcell',varargin{:});
clear X n
Al = m(Al);
Ar = m(Ar);

clear m



%%

prop = lower(get_option(varargin,'property','angle'));

regions = false(size(Al));
omega = false(size(Al));
for i=1:numel(ebsd)
  
  ind = phase(Al) == ebsd(i).phase & phase(Ar) == ebsd(i).phase;
  
  zll = Al(ind)-rl(i); zrr = Ar(ind)-rl(i);
  
  %   compute distances
  switch prop
    case 'angle'
      o = ebsd(i).orientations;
      
      cind = [uint32(0:1000000:numel(zll)-1) numel(zll)]; % memory
      for k=1:numel(cind)-1
        aind = cind(k)+1:cind(k+1);
        o1 = o(zll(aind));
        o2 = o(zrr(aind));
        omega(aind) = angle(o1,o2) <= thresholds(i);
      end
      
      clear o1 o2 aind
    otherwise
      p = get(ebsd(i),prop);
      omega = abs( p(zll) - p(zrr) ) <= thresholds(i);
      clear p
  end
  
  regions(ind) = omega(ind);
end
clear ind zll zrr omega prop



% adjacency of cells that have no common boundary
Ap = sparse(Al(regions),Ar(regions),true,d,d);
ids = graph2ids(Ap | Ap');
clear Ap
% adjacency of cells that have a boundary
Am = sparse(Al(~regions),Ar(~regions),true,d,d);
Am = Am | Am';
clear Al Ar regions


%% retrieve neighbours

DG = sparse(1:numel(ids),double(ids),1);    % voxels incident to grains
Ag = DG'*Am*DG;                     % adjacency of grains

%% interior and exterior grain boundaries

Aint = diag(double(any(Am*DG & DG,2))) * Am;  % adjacency of 'interal' boundaries
Aext = Am-Aint;                     % adjacency of 'external' boundaries

i = find(any(Am,2));
clear Am

% construct faces as needed
if numel(sz) == 3
  [v,VF,FD] = spatialdecomposition3d(sz,i,dz,lz);
else
  v = sz; clear sz
  VF = dz; clear dz
  FD = lz; clear lz
end
clear i sz dz lz

FG = FD*DG;                         % faces incident to grain

% background
Dint = diag(diag(FD*Aint*FD')>1);   % select those faces that are 'interal'
FG_int = logical(Dint*FG);
clear Dint
                                    % select faces that are 'external'
Dext = diag(diag(FD*Aext*FD') | sum(FD,2) == 1);
clear Aext

FG_ext = logical(Dext*FG);
clear Dext FD FG

%% generate polyeder for each grains

fd = size(VF,2);

p = struct(polytope);
nr = max(ids);
ply = repmat(p,1,nr);


for k = 1:nr
  
  fe = find(FG_ext(:,k));
  [vertids,b,face] = unique(VF(fe,:));
  
  ph = p;
  ph.Vertices =  v(vertids,:);
  ph.VertexIds = vertids;
  ph.Faces = reshape(uint32(face),[],fd);
  ph.FacetIds = uint32(fe);
  ply(k) = ph;
  
end
ply = polytope(ply);

clear FG_ext fe

%% setup subgrain boundaries for each grains

[i,j] = find(Aint);
clear Aint

fraction = cell(1,nr);
hasSubBoundary = find(any(FG_int));


[vg,g] = find(DG(:,hasSubBoundary));
clear DG
FG_int = FG_int(:,hasSubBoundary);

i = uint32(i);
j = uint32(i);
vg = uint32(vg);
g = uint32(g);

for k = 1:numel(hasSubBoundary)
  
  fi = find(FG_int(:,k));
  [vertids,b,face] = unique(VF(fi,:));
  
  ph = p;
  ph.Vertices =  v(vertids,:);
  ph.VertexIds = vertids;
  ph.Faces = reshape(uint32(face),[],fd);
  ph.FacetIds = uint32(fi);
  
  vgk = vg(g==k);
  s = ismembc(i,vgk) & ismembc(j,vgk);
  
  frac.pairs = [i(s),j(s)];
  frac.P = polytope(ph); % because of plotting its a polytope
  
  fraction{hasSubBoundary(k)} = frac;
end


clear VF v FG_int vertids face fi pls ph ...
  l i j b vgk vg g frac s p fd hasSubBoundary

%% conversion to cells

%store grain id's into ebsd option field
cids =  [0 cumsum(sampleSize(ebsd))];
checksum =  fix(rand(1)*16^8); %randi(16^8);
checksumid = [ 'grain_id' dec2hex(checksum)];
for k=1:numel(ebsd)
  ide = ids(cids(k)+1:cids(k+1));
  ebsd(k).options.(checksumid) = ide(:);
  
  [ide ndx] = sort(ide(:));
  pos = [0 ;find(diff(ide)); numel(ide)];
  aind = ide(pos(1:end-1)+1);
  
  orientations(aind) = ...
    partition(ebsd(k).orientations(ndx),pos);
end

clear aind cids ide checksumid ndx

% cell ids
[ix iy] = sort(ids);
id = cell(1,ix(end));
pos = [0 find(diff(ix)) numel(ix)];
for l=1:numel(pos)-1
  id{l} = iy(pos(l)+1:pos(l+1));
end

domean = cellfun('prodofsize',id) > 1;
orientations(domean) = cellfun(@mean,orientations(domean),'uniformoutput',false);


nc = length(id);

% neighbours
[ix iy] = find(Ag);
clear Ag
pos = [0; find(diff(iy)); numel(iy)];
neigh = cell(1,nc);
for l=1:numel(pos)-1
  ndx = pos(l)+1:pos(l+1);
  neigh{ iy(ndx(1)) } = ix(ndx);
end

clear ix iy ndx

% vdisp(['  ebsd segmentation: '  num2str(toc(s)) ' sec'],varargin{:});


%% retrieve polygons
% s = tic;

comment =  ['from ' ebsd(1).comment];

cid = cell(1,nc);
cchek = cell(1,nc);
ccom = cell(1,nc);
cprop = cell(1,nc);
phase_ebsd = cell(1,nc);
tstruc = struct;
for i=1:numel(cchek)
  cid{i} = i;
  cchek{i} = checksum;
  ccom{i} = comment;
  cprop{i} = tstruc;
  phase_ebsd{i} = phase(id{i}(1));
end

gr = struct('id',cid,...
  'cells',id,...
  'neighbour',neigh,...    %       'polygon',[],...
  'checksum',cchek,...
  'subfractions',fraction,...
  'phase',phase_ebsd,...
  'orientation',orientations,...
  'properties',cprop,...
  'comment',ccom);


grains = grain(gr,ply);


% vdisp(['  grain generation:  '  num2str(toc(s)) ' sec' ],varargin{:});
% vdisp(' ',varargin{:})




function ids = graph2ids(A)

%elimination tree
[parent] = etree(A);

n = length(parent);
ids = zeros(1,n,'uint32');
isleaf = parent ~= 0;

k = sum(~isleaf);
%set id for each tree in forest
for i = n:-1:1,
  if isleaf(i)
    ids(i) = ids(parent(i));
  else
    ids(i) = k;
    k = k - 1;
  end
end;

