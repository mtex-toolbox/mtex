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
%% See also
% grain/grain EBSD/calcGrains EBSD/segment2d

%% segmentation
% prepare data

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
  [grains ebsd] = segment3d(delete(ebsd,ind),varargin{:});
  return
end

phase_ebsd = get(ebsd,'phase');
phase_ebsd = mat2cell(phase_ebsd,ones(size(phase_ebsd)),1)';

% generate long phase vector
l = sampleSize(ebsd);
rl = [ 0 cumsum(l)];
phase = ones(1,sum(l));
for i=1:numel(ebsd)
  phase( rl(i)+(1:l(i)) ) = i;
end



phase = phase(m);



%% grid neighbours

[neighbours vert cells tri] = neighbour(xy, varargin{:});
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


%%


%% retrieve neighbours

T2 = xor(regions,neighbours); %former neighbours
T2 = T2 + T2';
T1 = sparse(ids,1:length(ids),1);
T3 = T1*T2;
nn = T3*T1'; %neighbourhoods of regions
             %self reference if interior has not connected neighbours

             
             
%% subfractions 

% inner = T1 & T3 ;
% [ix iy] = find(inner);
% [ix ndx] = sort(ix);
% cfr = unique(ix);
% cfr = sparse(1,cfr,1:length(cfr),1,length(nn));
% iy = iy(ndx);
% 
% if ~isempty(iy)
%   innerc = mat2cell(iy,histc(ix,unique(ix)),1);
% 
%   %partners
%   [lx ly] = find(T2(iy,iy));
%   nx = [iy(lx) iy(ly)];
%   ll = sortrows(sort(nx,2));
%   ll = ll(1:2:end,:); % subractions
% 
% 
%   nl = size(ll,1);
%   lines = zeros(nl,2);
% 
%   for k=1:nl
%     left = cells{ll(k,1)};
%     right = cells{ll(k,2)};
%     mm = ismember(left, right);
%     lines(k,:) = left(mm);  
%   end
% 
%   xx = [vert(lines(:,1),1) vert(lines(:,2),1)];
%   yy = [vert(lines(:,1),2) vert(lines(:,2),2)];
% 
%   nic = length(innerc);
%   fractions = cell(size(nic));
% 
%   for k=1:nic
%     mm = ismember(ll,innerc{k});
%     mm = mm(:,1);
%     fr.xx = xx(mm,:)';
%     fr.yy = yy(mm,:)'; 
%     fr.pairs = m(ll(mm,:));
%       if numel(fr.pairs) <= 2, fr.pairs = fr.pairs'; end
%     fractions{k} = fr;
%   end
% else
%   fractions = cell(0);
% end
%% subfractions 

inner = T1 & T3 ;

if ~isempty(inner)
  [ix iy] = find(inner');
  pos = [0; find(diff(iy)) ; numel(iy)];

  trisa = vertcat(tri{:});
  [tris fo ind] = unique(sort(trisa,2),'rows');
  ind = mat2cell(ind,cellfun('size',tri,1),1);

   fraction = cell(1,max(ids));
  for k=1:numel(pos)-1
    ndx = pos(k)+1:pos(k+1);
    gid = iy(ndx(1));
    vid = ix(ndx);

    [lx ly] = find(T2(vid,vid));

    f = vid([lx ly]);

    l = ind(f(:,1));
    r = ind(f(:,2));

    l = [l{:}];
    r = [r{:}];

    ll = repmat(1:size(l,2),6,1);

    I = sparse(l,ll,1) &  sparse(r,ll,2);

    [llx lly] = find(I);
    [llx b c]= unique(llx);

    subfaces = trisa(fo(llx),:);

    [vfaces ig subfaces] = unique(subfaces);

    frac.pair = m(f(b,:));
    
    p = struct(polytope);
    p.Faces = reshape(subfaces,[],size(tris,2));
    p.Vertices = vert(vfaces,:);
    
    frac.P = polyeder(p);

    fraction{gid} = frac;

  end
end


clear T1 T2 T3 regions angel_treshold


%% conversion to cells

ids = ids(n); %sort back
phase = phase(n);
cells = cells(n);
tri = tri(n);

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

% cell ids
[ix iy] = sort(ids);
id = cell(1,ix(end));
pos = [0 find(diff(ix)) numel(ix)];
for l=1:numel(pos)-1
  id{l} = iy(pos(l)+1:pos(l+1));
end


nc = length(id);

% neighbours
[ix iy] = find(nn);
pos = [0; find(diff(iy)); numel(iy)];
neigh = cell(1,nc);
for l=1:numel(pos)-1
  ndx = pos(l)+1:pos(l+1);
  neigh{ iy(ndx(1)) } = ix(ndx);
end

% vdisp(['  ebsd segmentation: '  num2str(toc(s)) ' sec'],varargin{:});


%% retrieve polygons
s = tic;

ply = createpolyeder(cells,id,vert,tri);

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


function [F v c tri] = neighbour(xy,varargin)
% voronoi neighbours


[v c tri] = spatialdecomposition3d(xy,'unitcell',varargin{:});
clear xy
il = (cat(2,c{:}));
jl = (zeros(1,length(il)));

cl = cellfun('length',c);
ccl = [ 0 ;cumsum(cl)];

if ~check_option(varargin,'unitcell')
  %sort everything clockwise  
%   parts = [0:10000:numel(c)-1 numel(c)];
%   
%   f = false(size(c));
%   for l=1:numel(parts)-1
%     ind = parts(l)+1:parts(l+1);
%     cv = v( il( ccl(ind(1))+1:ccl(ind(end)+1) ),:);
%         
%     r = diff(cv);
%     r = r(1:end-1,1).*r(2:end,2)-r(2:end,1).*r(1:end-1,2);
%     r = r > 0;
%     
%     f( ind ) = r( ccl(ind)+1-ccl(ind(1)) );
%   end
%   
  for i=1:length(c)
    jl(ccl(i)+1:ccl(i+1)) = i;    
%     if f(i), l = c{i}; c{i} = l(end:-1:1); end
  end
  
  clear cv parts ind r f cl
else  
  for i=1:length(c)
    jl(ccl(i)+1:ccl(i+1)) = i;
  end
end

  % vertice map
T = sparse(jl,il,1); 
  clear jl il ccl cl
T(:,1) = false; %inf

%edges
F = T * T';
  clear T;
F = triu(F,1);
F = F > 3;

function ply = createpolyeder(cells,regionids,verts,tri)

p = struct(polytope);
nr = numel(regionids);
ply = repmat(p,1,nr);

nnn = numel(regionids);

cs = cellfun('prodofsize',regionids);

cl = cellfun('size',tri,1);
cl = [0;cumsum(cl)];

tris = vertcat(tri{:});
[tris f ind] = unique(sort(tris,2),'rows');
ind = mat2cell(ind,cellfun('size',tri,1),1);

% tic
for k=1:nnn %pr
%   progress(k,nnn)
  
  ids = regionids{k};
  c = cells(ids);
  cv = [c{:}];  
  tris = vertcat(tri{ids});
  inds = vertcat(ind{ids});
  
  [ft nd] = sort(inds);
	dell = find(diff(ft) == 0);
	nd([dell dell+1]) = [];
  faces = tris(nd,:);
  sz = size(faces);
  
  [vfaces ig faces] = unique(faces);
  
  pt = p;
  pt.Vertices = verts(vfaces,:);
  pt.VertexIds = vfaces;
  
  pt.Faces = reshape(faces,sz);
  pt.FacetIds = inds(nd) ;
 
  ply(k) = pt;

end
ply = polytope(ply);
