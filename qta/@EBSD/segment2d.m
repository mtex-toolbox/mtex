function [grains ebsd] = segment2d(ebsd,varargin)
% neighbour threshold segmentation of ebsd data
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
%  augmentation  - bounds the spatial domain
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
%  distance      - maximum distance allowed between neighboured measurments
%
%% Flags
%  unitcell     - omit voronoi decomposition and treat a unitcell lattice
%
%% Example
%   loadaachen
%   [grains ebsd] = segment2d(ebsd(1:2),'threshold',[10 15]*degree)
%
%   plot(grains)
%
%   [grains ebsd] = segment2d(ebsd,'property','bc','threshold',5)
%   plot(grains)
%
%% See also
% grain/grain EBSD/calcGrains EBSD/segment3d

%% prepare data 

s = tic;

thresholds = get_option(varargin,{'threshold','angle'},15*degree);
if numel(thresholds) == 1 && numel(ebsd) > 1
  thresholds = repmat(thresholds,size(ebsd));
end


xy = vertcat(ebsd.X);

if isempty(xy), error('no spatial data');end

% sort for voronoi
[xy m n]  = unique(xy,'first','rows');

if numel(m) ~= numel(n)
  warning('mtex:GrainGeneration','spatially duplicated data points, perceed by erasing them')
  ind = ~ismember(1:sum(sampleSize(ebsd)),m);
  [grains ebsd] = segment2d(delete(ebsd,ind),varargin{:});
  return
end

phaseEBSD = get(ebsd,'phase');
phaseEBSD = mat2cell(phaseEBSD,ones(size(phaseEBSD)),1)';

% generate long phase vector
l = sampleSize(ebsd);
rl = [ 0 cumsum(l)];
phase = ones(1,sum(l));
for i=1:numel(ebsd)
  phase( rl(i)+(1:l(i)) ) = i;
end



phase = phase(m);



%% grid neighbours

[neighbours vert cells] = neighbour(xy, varargin{:});
[sm sn] = size(neighbours); %preserve size of sparse matrices
[ix iy]= find(neighbours);

%% maximum distance between neighbours

if check_option(varargin,'distance')
  distance = sqrt(sum((xy(ix,:)-xy(iy,:)).^2,2));
  distance = distance > get_option(varargin,'distance',max(distance),'double');
  distance = sparse(ix,iy,distance,sm,sn);
  distance = xor(distance,neighbours);
  [ix iy]= find(distance);
else
  distance = neighbours;
end


%% disconnect by phase

phases = sparse(ix,iy,phase(ix) ~= phase(iy),sm,sn);
phases = xor(phases,distance);
[ix iy]= find(phases);

%% disconnect by missorientation

angles = sparse(sm,sn);

zl = m(ix);
zr = m(iy);

prop = lower(get_option(varargin,'property','angle'));

for i=1:numel(ebsd)
  %   restrict to correct phase
  ind = rl(i) < zl & zl <=  rl(i+1);
  
  zll = zl(ind)-rl(i); zrr = zr(ind)-rl(i);
  mix = ix(ind); miy = iy(ind);
  
  %   compute distances
  switch prop
    case 'angle'
      o1 = ebsd(i).orientations(zll);
      o2 = ebsd(i).orientations(zrr);
      omega = angle(o1,o2);
    otherwise
      p = get(ebsd(i),prop);
      omega = abs( p(zll) - p(zrr) );
  end
  
   ind = omega > thresholds(i);
  
  angles = angles + sparse(mix(ind),miy(ind),1,sm,sn);
end

% disconnect regions
regions = xor(angles,phases);

clear angles phases


%% convert to tree graph

ids = graph2ids(regions);


%% retrieve neighbours

T2 = xor(regions,neighbours); %former neighbours
T2 = T2 + T2';
T1 = sparse(ids,1:length(ids),1);
T3 = T1*T2;
nn = T3*T1'; %neighbourhoods of regions
%self reference if interior has not connected neighbours

%% subfractions

inner = T1 & T3;
[ix iy] = find(inner');

fract = cell(1,max(ids));
if ~isempty(iy)
  pos = [0; find(diff(iy)); numel(iy)];
  
  for l=1:numel(pos)-1
    ndx = pos(l)+1:pos(l+1);
    
    sx = ix(ndx);
    [lx ly] = find(T2(sx,sx));
    nx = [sx(lx) sx(ly)];
    
    lines = zeros(size(nx));
    for k=1:size(nx,1)
      ax = sort(cells{nx(k,1)});
      ay = sort(cells{nx(k,2)});
      lines(k,:) = ax(ismembc(ax,ay));
    end
    
    fr.xx = reshape(vert(lines,1),size(lines))';
    fr.yy = reshape(vert(lines,2),size(lines))';
    fr.pairs = reshape(nx,[],2);
    
    fract{l} = fr;
  end
  
end

%clean up
clear T1 T2 T3 regions angel_treshold


%% conversion to cells

ids = ids(n); %sort back
phase = phase(n);
cells = cells(n);

%store grain id's into ebsd option field
cids =  [0 cumsum(sampleSize(ebsd))];
checksum =  fix(rand(1)*16^8); %randi(16^8);
checksumid = [ 'grain_id' dec2hex(checksum)];
for k=1:numel(ebsd)
  ide = ids(cids(k)+1:cids(k+1));
  ebsd(k).options.(checksumid) = ide(:);
  
  if ~isempty(ide)
    [ide ndx] = sort(ide(:));
    pos = [0 ;find(diff(ide)); numel(ide)];
    aind = ide(pos(1:end-1)+1);
    
    orientations(aind) = ...
      partition(ebsd(k).orientations(ndx),pos);
  end
end

% cell ids
[ix iy] = sort(ids);
id = cell(1,ix(end));
pos = [0 find(diff(ix)) numel(ix)];
for l=1:numel(pos)-1
  id{l} = iy(pos(l)+1:pos(l+1));
end


nc = length(id);

% neighbours
neigh = cell(1,nc);
if ~isempty(nn)
  [ix iy] = find(nn);
  if ~isempty(iy)
    pos = [0; find(diff(iy)); numel(iy)];
    for l=1:numel(pos)-1
      ndx = pos(l)+1:pos(l+1);
      neigh{ iy(ndx(1)) } = ix(ndx);
    end
  end
end

if check_mtex_option('debug')
  vdisp(['  ebsd segmentation: '  num2str(toc(s)) ' sec'],varargin{:});
end


%% retrieve polygons
s = tic;

ply = createpolygons(cells,id,vert);

comment =  ['from ' ebsd(1).comment];

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
  phase_ebsd{i} = phaseEBSD{phase(id{i}(1))};
end

gr = struct('id',cid,...
  'cells',id,...
  'neighbour',neigh,...    %       'polygon',[],...
  'checksum',cchek,...
  'subfractions',fract,...
  'phase',phase_ebsd,...
  'orientation',orientations,...
  'properties',cprop,...
  'comment',ccom);

grains = grain(gr,ply);



if check_mtex_option('debug')
  vdisp(['  grain generation:  '  num2str(toc(s)) ' sec' ],varargin{:});
  vdisp(' ',varargin{:})
end




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


function [F v c] = neighbour(xy,varargin)
% voronoi neighbours

[v c] = spatialdecomposition(xy,'voronoi',varargin{:});

il = cat(2,c{:});
jl = zeros(1,length(il));

cl = cellfun('length',c);
ccl = [ 0 ;cumsum(cl)];

if ~check_option(varargin,'unitcell')
  %sort everything clockwise
  parts = [0:10000:numel(c)-1 numel(c)];
  
  f = false(size(c));
  for l=1:numel(parts)-1
    ind = parts(l)+1:parts(l+1);
    cv = v( il( ccl(ind(1))+1:ccl(ind(end)+1) ),:);
    
    r = diff(cv);
    r = r(1:end-1,1).*r(2:end,2)-r(2:end,1).*r(1:end-1,2);
    r = r > 0;
    
    f( ind ) = r( ccl(ind)+1-ccl(ind(1)) );
  end
  
  for i=1:length(c)
    jl(ccl(i)+1:ccl(i+1)) = i;
    if f(i), l = c{i}; c{i} = l(end:-1:1); end
  end
  
  clear cv parts ind r f cl
else
  for i=1:length(c)
    jl(ccl(i)+1:ccl(i+1)) = i;
  end
end

% vertice map
T = sparse(jl,il,1);
clear jl il ccl
T(:,1) = 0; %inf

%edges
F = T * T';
clear T;
F = triu(F,1);
F = F > 1;


function ply = createpolygons(cells,regionids,verts)

rcells = cells([regionids{:}]);
gl = [rcells{:}];

%shift indices
indi = 1:length(gl);
inds = indi+1;
c1 = cellfun('length',rcells);
cr1 = cellfun('length',regionids);
r1 = cumsum(c1);
r2 = [1 ; r1+1];
r2(end) =[];
inds(r1) = r2;
gr = gl(inds); %partner pointel

cc = [0; r1];
cr = cumsum(cr1);

clear rcells r1 r2 indi c1 inds

%
nr = length(regionids);
p = struct(polytope);
ply = repmat(p,1,nr);

f = (gl+gr).*gl.*gr; % try to make unique linel ids
rid = [0;cc(cr+1)];
for k=1:nr
  sel = rid(k)+1:rid(k+1);
  
  if cr1(k)>1
    ft = f(sel); % erase double edges
    [ft nd] = sort(ft);
    dell = find(diff(ft) == 0);
    nd([dell dell+1]) = [];
    sel = sel(nd);
    gll = gl(sel);
    grr = gr(sel);
    
    border = convert2border(gll, grr);
    
    psz = numel(border);
    if psz == 1
      
      v = border{1};
      xy = verts(v,:);
      ply(k).Vertices = xy;
      ply(k).VertexIds = v;
      ply(k).Envelope = envelope(xy);
      
    else
      
      hply = repmat(p,1,psz);
      
      for l=1:psz
        
        v = border{l};
        xy = verts(v,:);
        hply(l).Vertices = xy;
        hply(l).VertexIds = v;
        hply(l).Envelope = envelope(xy);
        
      end
      
      hply = polytope(hply);
      [ig ndx] = sort(area(hply),'descend');
      ply(k) = hply(ndx(1));
      ply(k).Holes = hply(ndx(2:end));
      
    end
  else
    
    v = gl(sel);
    v(end+1) = v(1);
    xy = verts(v,:);
    ply(k).Vertices = xy;
    ply(k).VertexIds = v;
    ply(k).Envelope = envelope(xy);
    
  end
end
ply = polytope(ply);



function env = envelope(xy)

env([1,3]) = min(xy);
env([2,4]) = max(xy);


function border = convert2border(gl,gr)

[gll a] = sort(gl);
[grr b] = sort(gr);

nn = numel(gl);

sb = zeros(nn,1);
v = sb;

sb(b) = a;
v(1) = a(1);

cc = 0;
l = 2;
lp = 1;

while true
  np = sb(v(lp));
  
  if np > 0
    v(l) = np;
    sb(v(lp)) = -1;
  else
    cc(end+1) = lp;
    n = sb(sb>0);
    if isempty(n)
      break
    else
      v(l) = n(1);
    end
  end
  
  lp = l;
  l=l+1;
end

nc = numel(cc)-1;
if nc > 1, border = cell(1,nc); end

for k=1:nc
  vt = gl(v(cc(k)+1:cc(k+1)));
  border(k) = {vt};
end

