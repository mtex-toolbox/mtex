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

s = tic;

thresholds = get_option(varargin,{'threshold','angle'},15*degree);
if numel(thresholds) == 1 && numel(ebsd) > 1
  thresholds = repmat(thresholds,size(ebsd));
end


l = sampleSize(ebsd);
rl = [ 0 cumsum(l)];


X = vertcat(ebsd.X);

if isempty(X), error('no spatial data');end

% sort for voronoi
% [xy m n]  = unique(xy,'first','rows');
% if numel(m) ~= numel(n)
%   warning('mtex:GrainGeneration','spatially duplicated data points, perceed by erasing them')
%   ind = ~ismember(1:sum(sampleSize(ebsd)),m);
%   [grains ebsd] = segment3d(delete(ebsd,ind),varargin{:});
%   return
% end

phase = get(ebsd,'phases');


[A,v,VF,FD] = spatialdecomposition3d(X,'unitcell');

%%

prop = lower(get_option(varargin,'property','angle'));

regions = false(size(A,1),1);
for i=1:numel(ebsd)
 
  ind = all(phase(A) == ebsd(i).phase,2);
    
  zl = A(ind,1);
  zr = A(ind,2);
  
  zll = zl-rl(i); zrr = zr-rl(i);
  
  %   compute distances
  switch prop
    case 'angle'
      o1 = ebsd(i).orientations(zll);
      o2 = ebsd(i).orientations(zrr);
      omega = angle(o1,o2);
      clear o1 o2
    otherwise
      p = get(ebsd(i),prop);
      omega = abs( p(zll) - p(zrr) );
      clear p
  end
  
  regions(ind) = omega <= thresholds(i);
end
clear ind zl zr zll zrr omega

A = double(A); % because of sparse :/
d = size(X,1); % number of adjacent cells

                                    % adjacency of cells that have no common boundary
Ap = sparse(A(regions,1),A(regions,2),1,d,d);
ids = graph2ids(Ap | Ap');
clear Ap
                                    % adjacency of cells that have a boundary
Am = sparse(A(~regions,1),A(~regions,2),1,d,d);
Am = Am | Am';
clear A regions


%% retrieve neighbours

DG = sparse(1:numel(ids),ids,1);    % voxels incident to grains
Ag = DG'*Am*DG;                     % adjacency of grains

%% interior and exterior grain boundaries

Aint = diag(any(Am*DG & DG,2))* double(Am);  % adjacency of 'interal' boundaries
Aext = Am-Aint;                     % adjacency of 'external' boundaries

FG = FD*DG;                         % faces incident to grain

Dint = diag(diag(FD*Aint*FD')>1);   % select those faces that are 'interal'
FG_int = Dint*FG;
                                    % select faces that are 'external'
Dext = diag(diag(FD*Aext*FD') | sum(FD,2) == 1);
FG_ext = Dext*FG;

clear Aext Am FD FG Dint Dext

%% generate polyeder for each grains

fd = size(VF,2);

p = struct(polytope);
nr = max(ids);
ply = repmat(p,1,nr);


for k=1:max(ids)
  fe = find(FG_ext(:,k));
  [vertids,b,face] = unique(VF(fe,:));
  
  ph = p;
  ph.Vertices =  v(vertids,:);
  ph.VertexIds = vertids;
  ph.Faces = reshape(face,[],fd);
  ph.FacetIds = fe;
  ply(k) = ph;
  
end
ply = polytope(ply);

clear FG_ext fe

%% setup subgrain boundaries for each grains

[i,j] = find(Aint);

fraction = cell(1,nr);
hasSubBoundary = find(any(FG_int));

for k = hasSubBoundary

  fi = find(FG_int(:,k));
  [vertids,b,face] = unique(VF(fi,:));
  
  ph = p;
  ph.Vertices =  v(vertids,:);
  ph.VertexIds = vertids;
  ph.Faces = reshape(face,[],fd);
  ph.FacetIds = fi;  
  
  f = find(DG(:,k));
  s = ismembc(i,f) & ismembc(j,f);
  
  frac.pairs = [i(s),j(s)];
  frac.P = polytope(ph); % because of plotting its a polytope
  
  fraction{k} = frac;
end


clear FG_int vertids face fi pls l i j b

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

clear cids ide

% cell ids
[ix iy] = sort(ids);
id = cell(1,ix(end));
pos = [0 find(diff(ix)) numel(ix)];
for l=1:numel(pos)-1
  id{l} = iy(pos(l)+1:pos(l+1));
end


nc = length(id);

% neighbours
[ix iy] = find(Ag);
pos = [0; find(diff(iy)); numel(iy)];
neigh = cell(1,nc);
for l=1:numel(pos)-1
  ndx = pos(l)+1:pos(l+1);
  neigh{ iy(ndx(1)) } = ix(ndx);
end

clear Ag ix iy ndx

% vdisp(['  ebsd segmentation: '  num2str(toc(s)) ' sec'],varargin{:});


%% retrieve polygons
% s = tic;

comment =  ['from ' ebsd(1).comment];

% fract = cell(1,nc);
% fract(find(cfr)) = fractions;

domean = cellfun('prodofsize',id) > 1;
orientations(domean) = cellfun(@mean,orientations(domean),'uniformoutput',false);

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
ids = zeros(1,n);
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

