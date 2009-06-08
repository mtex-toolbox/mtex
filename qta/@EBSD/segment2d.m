function [grains ebsd] = segment2d(ebsd,varargin)
% angle threshold segmentation of ebsd data 
%
%% Input
%  ebsd   - @EBSD
%
%% Output
%  grains  - @grain
%  ebsd    - connected @EBSD data
%
%% Options
%  angle         - threshold angle of mis/disorientation in radians
%  augmentation  - 'cube'/ 'cubeI' / 'sphere'
%  angletype     - misorientation / disorientation (default)
%
%% Example
%  [grains ebsd] = segment2d(ebsd,'angle',15*degree,'augmentation','cube')
%
%% See also
% grain/grain

%% segmentation
% prepare data
tic;

xy = vertcat(ebsd.xy);

if isempty(xy)
  error('no spatial data')
end

grid = [ebsd.orientations];
z = quaternion(grid); 

l = GridLength(grid);
rl = [ 0 cumsum(l)];
phase = ones(1,sum(l));
phaseCS = cell(numel(l),1);
phaseSS = cell(numel(l),1);
for i=1:numel(ebsd)
   phaseCS{i} = getCSym(ebsd(i).orientations);
   phaseSS{i} = getSSym(ebsd(i).orientations);
   phase( rl(i)+(1:l(i)) ) = i;
end

% sort for voronoi
[xy m n]  = unique(xy,'first','rows');
z = z(m);
phase = phase(m);

%% grid neighbours

%%
[neighbours vert cells] = neighbour(xy, varargin{:});
  [sm sn] = size(neighbours); %preserve size of sparse matrices
[ix iy]= find(neighbours);

%s(1) = toc;

%% disconnect phases

%tic

phases = sparse(ix,iy,phase(ix) ~= phase(iy),sm,sn);
phases = xor(phases,neighbours);
[ix iy]= find(phases);

%s(1) =  toc;

%% angel to neighbours
%tic

angels = sparse(ix,iy, nangle(z(ix),z(iy),phase(ix), phaseCS, phaseSS, varargin{:}),sm,sn);
  
%% find all angles lower threshold

angels = angels > get_option(varargin,'angle',15*degree); %map of disconnected neighbours.
regions = xor(angels,phases); 

%% convert to tree graph

ids = graph2ids(regions);

%s(1) = toc; 
 
%% retrieve neighbours

T2 = xor(regions,neighbours); %former neighbours
T1 = sparse(ids,1:length(ids),1);
T3 = T1*T2;
nn = T3*T1'; %neighbourhoods of regions
             %self reference if interior has not connected neighbours

%% subfractions 

inner = T1 & T3 ;
[ix iy] = find(inner);
[ix ndx] = sort(ix);
cfr = unique(ix);
iy = iy(ndx);
innerc = mat2cell(iy,histc(ix,unique(ix)),1);

%partners
[lx ly] = find(T2(iy,iy));
nx = [iy(lx) iy(ly)];
ll = sortrows(sort(nx,2));
ll = ll(1:2:end,:); % subractions

 
nl = length(ll);
lines = zeros(nl,2);

for k=1:nl
  left = cells{ll(k,1)};
  right = cells{ll(k,2)};
  mm = ismember(left, right);
  lines(k,:) = left(mm);  
end

xx = [vert(lines(:,1),1) vert(lines(:,2),1)];
yy = [vert(lines(:,1),2) vert(lines(:,2),2)];

nic = length(innerc);
fractions = cell(nic);

for k=1:nic
  mm = ismember(ll,innerc{k});
  mm = mm(:,1);
  fr.xx = xx(mm,:)';
  fr.yy = yy(mm,:)'; 
  fr.pairs = m(ll(mm,:));
    if numel(fr.pairs) <= 2, fr.pairs = fr.pairs'; end
  fractions{k} = fr;
end
                
  %clean up
  clear T1 T2 T3 angles neighbours regions angel_treshold
%% conversion to cells

ids = ids(n); %sort back

%store grain id's into ebsd option field
cids =  [0 cumsum(sampleSize(ebsd))];
checksum =  fix(rand(1)*16^8); %randi(16^8);
checksumid = [ 'grain_id' dec2hex(checksum)];
for k=1:numel(ebsd)
 ebsd(k).options.(checksumid) = ids(cids(k)+1:cids(k+1))';
end
  

cells = cells(n);

[ix iy] = sort(ids);
id = mat2cell(iy,1,histc(ix,unique(ix)));

[ix iy] = find(nn);
nfr = unique(iy);
if ~isempty(ix)
  histc(iy,unique(iy));
  nn = mat2cell(ix,histc(iy,unique(iy)),1);
else
  nn = cell(1);
end

s(1) = toc;
disp(['  ebsd segmentation: '  num2str(s(1)) ' sec']);


%% retrieve polygons
tic

nc = length(id);
grains = grain(nc);
for k=1:nc
  regionid = id{k};
  ply = createpolygon(cells(regionid),vert);

  grains(k) = grain(k, regionid, nn{find(k == nfr)},...
    ply,checksum,fractions{find(k == cfr)});
end

s(3) = toc;
disp(['  grain generation:  '  num2str(s(3)) ' sec' ]);
disp(' ')




function omega = nangle(zl , zr , phase, phaseCS, phaseSS, varargin)

angletype = get_option(varargin,'angletype','misorientation');

switch lower(angletype)
  case 'misorientation'
    omega = zeros(1,size(zl,2));
    %phase
    for i=1:numel(phaseCS)
      ind = find(phase == i); 
      %partition data due to memory issues
      part = [ 1:10000:length(ind) size(ind,2)+1]; 
      
      for k=1:length(part)-1
      	cur = ind(part(k):part(k+1)-1);
                
        ql = symmetriceQuat(phaseCS{i},phaseSS{i},zl(cur)); 
        qr = repmat(inverse(zr(cur)).',1,size(ql,2));
         
        omega(cur) = min(rotangle(ql .* qr),[],2) ;       
      end  
    end
  case 'disorientation'
    omega = rotangle(zl .* inverse(zr));
  otherwise
    error('wrong angletype option')
end



%misorientation
%[q,omega] = getFundamentalRegion(ebsd(2).orientations);

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

augmentation = get_option(varargin,'augmentation','cube');
%extrapolate dummy coordinates %dirty
switch lower(augmentation)
  case {'cube', 'cubei'}
    hx = unique(xy(:,1));
    hy = unique(xy(:,2));    
      
    [xx1 yy1] = meshgrid(hx,hy);

    x = [ hx(1:2)-2*diff(hx(1:3)); hx(:); hx(end-1:end)+2*diff(hx(end-2:end))];
    y = [ hy(1:2)-2*diff(hy(1:3)); hy(:); hy(end-1:end)+2*diff(hy(end-2:end))];
      clear hx hy
    
    [xx2 yy2] = meshgrid(x,y);
    
    clear x y
    switch lower(augmentation) 
      case 'cubei'
        ff1 = [xy(:,1),xy(:,2)];
      case 'cube'
        ff1 = [xx1(:),yy1(:)];
    end    
    ff2 = [xx2(:),yy2(:)];
      clear xx1 xx2 yy1 yy2
       
    m = ismember(ff2,ff1,'rows');
    
    dummy = ff2(~m,:);    
    	clear ff1 ff2 m
  case 'sphere'
    dx = (max(xy(:,1)) - min(xy(:,1)))/1.25;
    dy = (max(xy(:,2)) - min(xy(:,2)))/1.25;
    
    cc = -pi:.05:pi;
    hx = cos(cc);
    hy = -sin(cc);
   
    hx = (hx)*dx+ (max(xy(:,1)) + min(xy(:,1)))/2;
    hy = (hy)*dy+ (max(xy(:,2)) + min(xy(:,2)))/2;
   
    dummy = unique([hx(:),hy(:)],'first','rows');
    
      clear dx dy hx hy cc 
  otherwise
    error('wrong augmentation option')
end
xy = [xy; dummy];

[v c] = voronoin(xy,{'Q7'});   %Qf {'Qf'} ,{'Q7'}


% prepare data
  %c = c(1:end-length(dummy));
c(end-length(dummy)+1:end) = [];
  clear dummy xy

il = cat(2,c{:});
jl = zeros(1,length(il));

cl = cellfun('prodofsize',c);
ccl = [ 0 ;cumsum(cl)];
for i=1:length(c)
  jl(ccl(i)+1:ccl(i+1)) = i;
end
  clear cl ccl
% vertice map
T = sparse(jl,il,1); 
  clear jl il
T(:,1) = 0; %inf

%edges
F = T * T' > 1;
clear T
F = F - speye(length(c));



function [ply] = createpolygon(c,v)

gl = cat(2,c{:});

if length(c) == 1  %one cell
  border = [gl gl(1)];
  holes = cell(0);  
else             
  %shift indices
  inds = 2:length(gl)+1;
  r1 = cellfun('prodofsize',c);
  r1 = cumsum(r1);
  r2 = [1 ; r1+1];
  r2(end) =[];  
  inds(r1) = r2;
  %	clear r1 r2
  
  gr = gl(inds); %partner pointel
  %	clear inds 
  ii = [gl ;gr]; % linels  
  %	clear gl gr
  
% remove double edges
	ii = sort(ii)';
  ii = sortrows(ii);  %transpose
  
  dell = all(diff(ii) == 0,2);   %entry twice
  dell = [ 0; dell] | [ dell; 0]; 
  ii(dell,:) = [];  % free boundary  
  %  clear dell
 
  nf = length(ii);  
  f = zeros(1,nf);  %minimum size
 
  if isempty(ii)
     ply.xy = v(gl,:);
     ply.hxy = cell(0);
    return;
  end
    
%hamiltonian  trials   /eulerian?
  %setup first pointel   
  f(1) = ii(1,1);
  cc = 0; 
  
  k = 2;
   
  %for k=2:nf+1
  while ~isempty(ii)
    [ro co] = find(f(k-1) == ii);
     
    if ~isempty(co)
      ro = ro(end);
      co = co(end);
      f(k) = ii(ro,3-co);     
    else    
      f(k) = ii(1,1);
      cc(end+1) = k-1;
    end
    
    ii(ro,:) = [];  %delete visited point
    k = k+1; %for
  end
  
  
 %   clear ii
  
%convert to cells
  nc = length(cc);
  cc(end+1) = k-1;
  
  plygn = cell(1,nc);
  for k=1:nc 
    plygn{k} = [f(cc(k)+1:cc(k+1)) f(cc(k)+1)];
  end  
  %  clear f cc

%border
  psz = length(plygn);
 
  %holes?
  if psz > 1
    area = zeros(1,psz);
    for kpc= 1:psz
      inds = plygn{kpc};    
      px = v(inds,1); 
      py = v(inds,2);

      area(kpc) = polyarea(px,py);
    end
    
    [C I] = max(area);         
    holes = plygn;
    holes(I) = [];
    border = plygn{I};
  else
    border = plygn{:};
    holes = cell(0);
  end
end

ply.xy = v(border,:);
ply.hxy = cell(0);

if ~isempty(holes)
  ply.hxy = cellfun(@(h) v(h,:),holes,'uniformoutput',false);
end

