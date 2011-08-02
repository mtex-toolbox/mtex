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

%l = sampleSize(ebsd);
%rl = [ 0 cumsum(l)];

X = [ebsd.options.x,ebsd.options.y,ebsd.options.z];

if isempty(X), error('no spatial data');end

% sort for voronoi
[Xt m n]  = unique(X(:,[3 2 1]),'first','rows'); %#ok<ASGLU>
clear Xt

% check for duplicated data points
if numel(m) ~= numel(n)
  warning('mtex:GrainGeneration','spatially duplicated data points, perceed by erasing them')
  ind = ~ismember(1:sum(sampleSize(ebsd)),m);
  [grains ebsd] = segment3d(delete(ebsd,ind),varargin{:});
  return
end

% sort X
X = X(m,:);

% sort ebsd accordingly
ebsd = subsref(ebsd,m);

d = size(X,1);                % number of cells

% decompose into unit cells
[Al,Ar,sz,dz,lz] = spatialdecomposition3d(X,'unitcell',varargin{:});
clear X n m


%%

regions = false(size(Al));
omega = false(size(Al));

phase = ebsd.phase;

for p = unique(phase).'

  ind = phase(Al) == p & phase(Ar) == p;

  cind = [uint32(0:1000000:sum(ind)-1) sum(ind)]; % memory
  for k=1:numel(cind)-1
    aind = ind & cumsum(ind) > cind(k) & cumsum(ind) <= cind(k+1);
    
    o1 = orientation(ebsd.rotations(Al(aind)),ebsd.CS{p},ebsd.SS);
    o2 = orientation(ebsd.rotations(Ar(aind)),ebsd.CS{p},ebsd.SS);
    
    omega(aind) = angle(o1,o2) <= thresholds(p);
  end
  
  clear o1 o2 aind
  
  regions(ind) = omega(ind);
  
end
clear ind zll zrr omega prop


% adjacency of cells that have no common boundary
Ap = sparse(double(Al(regions)),double(Ar(regions)),true,d,d);
ids = graph2ids(Ap | Ap');
clear Ap
% adjacency of cells that have a boundary
Am = sparse(double(Al(~regions)),double(Ar(~regions)),true,d,d);
Am = Am | Am';
clear Al Ar regions


%% retrieve neighbours

DG = sparse(1:numel(ids),double(ids),1);    % voxels incident to grains
Ag = DG'*Am*DG;                     % adjacency of grains

%% interior and exterior grain boundaries

% construct faces as needed
if numel(sz) == 3
  i = find(any(Am,2));  % voxel that are incident to grain boudaries
  [v,VF,FD,FDb] = spatialdecomposition3d(sz,uint32(i(:)),dz,lz);
else % its voronoi decomposition
  v = sz; clear sz
  VF = dz; clear dz
  FD = lz; clear lz
  FDb = sparse(size(FD));
end
clear sz dz lz

sub = Am*DG & DG;                      % voxels that have a subgrain boundary
[i,j] = find( diag(any(sub,2))*double(Am) ); % all adjacence to those
sub = any(sub(i,:) & sub(j,:),2);      % pairs in a grain
Aint = sparse(i(sub),j(sub),1,d,d);
                                       % select faces that are 'internal'
[i,j] = find(triu(Aint,1));
Dint = diag(any(FD(:,i) & FD(:,j),2)); % common faces
FG_int = Dint*abs(FD)*DG;              % dismisses the orientation of the facet

Aext = Am-Aint;                        % adjacent over grain boundray
clear Am Dint

[i,j] = find(triu(Aext,1));
Dext = diag(any(FD(:,i) & FD(:,j),2)); % select faces that are 'external'
clear Aext

FG_ext = Dext*FD*DG + FDb*DG;
clear Dext FD FG FDb

%% generate polyeder for each grains

fd = size(VF,2);

p = struct(polytope);
nr = max(ids);
ply = repmat(p,1,nr);


for k = 1:nr

  [fe,ig,forient] = find(FG_ext(:,k));
  [vertids,b,face] = unique(VF(fe,:));

  ph = p;
  ph.Vertices =  v(vertids,:);
  ph.VertexIds = vertids;
  ph.Faces = reshape(int32(face),[],fd);
  ph.FacetIds = int32(sign(forient).*fe);
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

  [fi,ig,forient] = find(FG_int(:,k));
  [vertids,b,face] = unique(VF(fi,:));

  ph = p;
  ph.Vertices =  v(vertids,:);
  ph.VertexIds = vertids;
  ph.Faces = reshape(int32(face),[],fd);
  ph.FacetIds = int32(sign(forient).*fi);

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
ebsd.options.grain_id = ids;

clear cids  ndx

% cell ids
[ix iy] = sort(ids);
id = cell(1,ix(end));
pos = [0 find(diff(ix)) numel(ix)];
for l=1:numel(pos)-1
  id{l} = iy(pos(l)+1:pos(l+1));
end

% compute mean orientations
q = quaternion(ebsd.rotations);
orientations = cellfun(@(ind) mean_CS(q(ind),...
  ebsd.CS{ebsd.phase(ind(1))},ebsd.SS),id,'uniformOutput',false);

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
ccom = cell(1,nc);
cprop = cell(1,nc);
phase_ebsd = cell(1,nc);
tstruc = struct;
for i=1:nc
  cid{i} = i;
  ccom{i} = comment;
  cprop{i} = tstruc;
  phase_ebsd{i} = phase(id{i}(1));
end

gr = struct('id',cid,...
  'cells',id,...
  'neighbour',neigh,...    %       'polygon',[],...
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

