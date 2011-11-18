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
%  threshold|angle - array of threshold angles per phase of mis/disorientation in radians
%  property        - angle (default) or property of @EBSD data
%  augmentation    - bounding of the spatial domain
%
%    * |'cube'| 
%    * |'hull'|  
%
%
%  distance        - maximum distance allowed between neighboured measurments
%
%% Flags
%  unitCell     - omit voronoi decomposition and treat a unitcell lattice
%
%% Example
%   mtexdata aachen
%   [grains ebsd] = segment2d(ebsd,'threshold',[10 15]*degree)
%
%   plot(grains)
%
%% See also
% grain/grain EBSD/calcGrains EBSD/segment3d

%% prepare data

s = tic;

% the threshold angles
thresholds = get_option(varargin,{'threshold','angle'},15*degree);
if numel(thresholds) == 1 && numel(ebsd) > 1
  thresholds = repmat(thresholds,size(ebsd));
end


xy = [ebsd.options.x,ebsd.options.y];

% sort for voronoi
[xy m n]  = unique(xy,'first','rows');

if numel(m) ~= numel(n)
  warning('mtex:GrainGeneration','spatially duplicated data points, perceed by erasing them')
  ind = ~ismember(1:numel(ebsd),m);
  [grains ebsd] = segment2d(subsref(ebsd,~ind),varargin{:});
  return
end

% sort ebsd accordingly
ebsd = subsref(ebsd,m);


%% grid neighbours

[neighbours vert cells] = neighbour(xy,ebsd.unitCell , varargin{:});
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

phase = sparse(ix,iy,ebsd.phase(ix) ~= ebsd.phase(iy),sm,sn);
phase = xor(phase,distance);
[ix iy]= find(phase);

%% disconnect by missorientation

angles = sparse(sm,sn);

% for all phase
for p = unique(ebsd.phase).'

  % restrict to the right phase
  indPhase = ebsd.phase == p;
  indPhase = indPhase(ix) & indPhase(iy);
  pix = ix(indPhase);
  piy = iy(indPhase);
  
  % generate orientations
  o1 = orientation(ebsd.rotations(pix),ebsd.CS{p},ebsd.SS);
  o2 = orientation(ebsd.rotations(piy),ebsd.CS{p},ebsd.SS);

  % check the missorientation
  ind = angle(o1,o2) > thresholds(p);

  angles = angles + sparse(pix(ind),piy(ind),1,sm,sn);
end

% disconnect regions
regions = xor(angles,phase);

clear angles phase


%% convert to tree graph

ids = graph2ids(regions);


%% retrieve neighbours

T2 = xor(regions,neighbours); %former neighbours
T2 = T2 + T2';
T1 = sparse(ids,1:length(ids),1);
T3 = T1*T2;
nn = T3*T1'; %neighbourhoods of regions
%self reference if interior has not connected neighbours

%% subgrain boundaries

inner = T1 & T3;           % vertices incident to a grain
[ix iy] = find(inner');

T2 = triu(T2,1);

fract = cell(1,max(ids));
if ~isempty(iy)
  pos = [0; find(diff(iy)); numel(iy)];
  p = struct(polytope);

  for l=1:numel(pos)-1
    ndx = pos(l)+1:pos(l+1);

    sx = ix(ndx);
    [lx ly] = find(T2(sx,sx));
    E = createSubBoundary(cells(sx(lx)),cells(sx(ly)));

    ply = repmat(p,1,numel(E));

    for k=1:numel(E)
      ply(k).Vertices = vert(E{k},:);
      ply(k).VertexIds = E{k};
    end

    % m([sx(lx) sx(ly)])
    frac.pairs = ([sx(lx) sx(ly)]);
    frac.P = polytope(ply);
    fract{iy(ndx(1))} = frac;
  end

end

%clean up
clear T1 T2 T3 regions angel_treshold inner


%% conversion to cells

% store grain id's into ebsd option field
ebsd.options.grain_id = ids(:);

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

comment =  ['from ' ebsd.comment];


%% compute mean orientations
%orientations = cellfun(@(ind) orientation(ebsd.rotations(ind),ebsd.CS{ebsd.phase(ind(1))},ebsd.SS),id,'uniformOutput',false);
%domean = cellfun('prodofsize',id) > 1;
%orientations(domean) = cellfun(@mean,orientations(domean),'uniformoutput',false);

q = quaternion(ebsd.rotations);
orientations = cellfun(@(ind) mean_CS(q(ind),...
  ebsd.CS{ebsd.phase(ind(1))},ebsd.SS),id,'uniformOutput',false);

%% set up grains
cid = num2cell(1:nc);            % id

ccom = repmat({comment},1,nc);   % comment

phase_ebsd = cellfun(...         % phase
  @(i) ebsd.phase(i(1)), id, 'uniformoutput', false);

%% compute mean grain options

% remove non numeric options
options = rmfield(ebsd.options,{'x','y','grain_id'});
for fn = fieldnames(options)'
  if ~isnumeric(options.(char(fn))), options = rmfield(options,fn);end
end

% compute the mean
fn = fieldnames(options);
if isempty(fn)
  cprop = repmat({struct()},1,nc);
else
  oArray = struct2cell(options); oArray = [oArray{:}];
  cprop = arrayfun(@(i) ...
    cell2struct(num2cell(mean(oArray(ids==i,:),1))',fn),1:nc,'uniformOutput',false);
end

%% set up the grain
gr = struct('id',cid,...
  'cells',id,...
  'neighbour',neigh,...    %       'polygon',[],...
  'subfractions',fract,...
  'phase',phase_ebsd,...'orientation', ,...
  'orientation',orientations,...
  'properties',cprop,...
  'comment',ccom);
grains = grain(gr,ply);

% compute mis2mean
ebsd = calcMis2Mean(ebsd,grains);

% verbose output
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


function [F v c] = neighbour(xy,unitCell,varargin)
% voronoi neighbours

[v c] = spatialdecomposition(xy,unitCell,varargin{:});

il = cat(2,c{:});
jl = zeros(1,length(il));

cl = cellfun('prodofsize',c);
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

%edges
F = T * T';
clear T;
F = triu(F,1);
F = F > 1;


function E = createSubBoundary(left,right)
% extract lines as an edge list

E = {};
for k=1:size(left,1)
  el = left{k};
  edge = el(ismembc(el,sort(right{k})));

  first = cellfun(@(x) x(1),E(:));
  last = cellfun(@(x) x(end),E(:));

  a = [first == edge(2) last == edge(2) last == edge(1) first == edge(1)];

  if any(a(:))
    [i,type] = find(a,1,'first');
    switch type
      case 1
        E{i} = [edge(1) E{i}];
      case 2
        E{i}(end+1) = edge(1);
      case 3
        E{i}(end+1) = edge(2);
      case 4
        E{i} = [edge(2) E{i}];
    end
  else
    E{end+1} = edge;
  end
end


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

