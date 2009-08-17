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
%  angletype     - misorientation (default) / disorientation 
%
%% Example
%  [grains ebsd] = segment2d(ebsd,'angle',15*degree,'augmentation','cube')
%
%% See also
% grain/grain

%% segmentation
% prepare data

s = tic;

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
phase_ebsd = get(ebsd,'phase');
phase_ebsd = mat2cell(phase_ebsd,ones(size(phase_ebsd)),1);
comment = get(ebsd,'comment');

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


%% disconnect phases

phases = sparse(ix,iy,phase(ix) ~= phase(iy),sm,sn);
phases = xor(phases,neighbours);
[ix iy]= find(phases);

%% angel to neighbours

angels = sparse(ix,iy, nangle(z(ix),z(iy),phase(ix), phaseCS, phaseSS, varargin{:}),sm,sn);
  
%% find all angles lower threshold

angels = angels > get_option(varargin,'angle',15*degree); %map of disconnected neighbours.
regions = xor(angels,phases); 

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

inner = T1 & T3 ;
[ix iy] = find(inner);
[ix ndx] = sort(ix);
cfr = unique(ix);
cfr = sparse(1,cfr,1:length(cfr),1,length(nn));
iy = iy(ndx);
innerc = mat2cell(iy,histc(ix,unique(ix)),1);

%partners
[lx ly] = find(T2(iy,iy));
nx = [iy(lx) iy(ly)];
ll = sortrows(sort(nx,2));
ll = ll(1:2:end,:); % subractions

 
nl = size(ll,1);
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
fractions = cell(size(nic));

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
phase = phase(n);

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
iyu = unique(iy);
nfr = sparse(1,iyu,1:length(iyu),1,length(nn));
if ~isempty(ix)
  nn = mat2cell(ix,histc(iy,iyu),1);
else
  nn = cell(1);
end

disp(['  ebsd segmentation: '  num2str(toc(s)) ' sec']);


%% retrieve polygons
s = tic;

ply = createpolygons(cells,id,vert);

comment =  ['from ' comment];
nc = length(id);

neigh = cell(1,nc);
neigh(find(nfr)) = nn;
fract = cell(1,nc);
fract(find(cfr)) = fractions;

gr = struct('id',num2cell(1:nc),...
       'cells',id,...
       'neighbour',neigh,...
       'polygon',[],...
       'checksum',[],...
       'subfractions',fract,...
       'properties',[],...
       'comment',[]);

ph = phase(cellfun(@(x)x(1),id));
properties = struct( 'phase',phase_ebsd(ph),...
                     'CS', phaseCS(ph),...
                     'SS', phaseSS(ph));
for k=1:nc
  gr(k).checksum = checksum;
  gr(k).comment = comment;
  gr(k).polygon = ply(k);
  gr(k).properties = properties(k);
end

grains = grain('direct',gr);

disp(['  grain generation:  '  num2str(toc(s)) ' sec' ]);
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
                
        %ql = symmetriceQuat(phaseCS{i},phaseSS{i},zl(cur)); 
        %qr = repmat(zr(cur).',1,size(ql,2)); %this can be done faster
         
        %omega(cur) = min(rotangle(ql .* qr),[],2) ;       
        %omega(cur) = min(2*acos(abs(dot(ql,qr))),[],2);       
        omega(cur) = 2*acos(dot_sym(zl(cur),zr(cur),phaseCS{i},phaseSS{i}));
      end  
    end
  case 'disorientation'
    omega = rotangle(zl .* inverse(zr));
  otherwise
    error('wrong angletype option')
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

augmentation = get_option(varargin,'augmentation','cube');
%extrapolate dummy coordinates %dirty
switch lower(augmentation)
  case 'cube'
    k = convhulln(xy);
    k = [k(:,1); k(1,1)];    
   
    x = xy(1:200<end,1);
    y = xy(1:200<end,2);
    xx = repmat(x,1,length(x));
    yy = repmat(y,1,length(y));
    dist = abs(sqrt((xx-xx').^2 + (yy-yy').^2));
    dxy = min(dist(triu(true(size(dist)),1)));
       
    dummy = [];
    for ll = 1:length(k)-1
      xx = xy([k(ll) k(ll+1)],1);
      yy = xy([k(ll) k(ll+1)],2);
           
      dx = diff(xx);  dy = diff(yy);
      
      rot = angle(complex(dx,dy));    
      shiftxy = [cos(rot) -sin(rot); sin(rot) cos(rot)] * [0 ; dxy]./2;
      
      l1 = [ dx dy ];
      l1 = repmat(l1./norm(l1),length(xy),1);
      l2 = repmat([xx(1) yy(1)] - shiftxy' ,length(xy),1);
  
      l3 =  [ -dy dx ];
      l3 =  repmat(l3./norm(l3),length(xy),1);
      dist = dot(xy - l2,l3,2);
      
      co = l2 + repmat( dot(xy - l2,l1,2) ,1,2).*l1;
           
      [co ia]= sortrows(co);
      dist = dist(ia);      
      
      if sign(dx) < 0 , pmx = @ge; else pmx = @le; end
      if sign(dy) < 0 , pmy = @ge; else pmy = @le;  end

      idxy = (pmx(co(:,1) - xx(1),dx) & pmx(xx(2) - co(:,1),dx)) | ...
             (pmy(co(:,2) - yy(1),dy) & pmy(yy(2) - co(:,2),dy));
      co = co(idxy , : );
      dist = dist(idxy);
      
      sel = false(size(dist));     
      fdist = dxy*10; iter = 1;   
      
      while max(fdist) - dxy > 10^-10 
        sel = sel | dist < dxy*iter;
     
        fdist = abs(sqrt(sum(diff(co(sel,:)).^2,2)));
        iter = iter+1;
     
        if all(sel), break, end;
      end
     
      co = co(sel,:);  
      if ~isempty(co)
        non = [true;any(diff(co)> dxy*10^-8 ,2) ];
        co = co(non,:);
      end
      
      dummy = [dummy ;co];
    end
    
  case {'cubi','cubei'} %grid reconstruction, TODO
    hx = unique(xy(:,1));
    hy = unique(xy(:,2));    
      
    [xx1 yy1] = meshgrid(hx,hy);

    x = [ hx(1:2)-2*diff(hx(1:3)); hx(:); hx(end-1:end)+2*diff(hx(end-2:end))];
    y = [ hy(1:2)-2*diff(hy(1:3)); hy(:); hy(end-1:end)+2*diff(hy(end-2:end))];
      clear hx hy
    
    [xx2 yy2] = meshgrid(x,y);
    
    clear x y
    ff1 = [xy(:,1),xy(:,2)];
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

[v c] = voronoin(xy,{'Q7','Q8','Q5','Q3'});   %Qf {'Qf'} ,{'Q7'}

% prepare data
  %c = c(1:end-length(dummy));
c(end-length(dummy)+1:end) = [];
  clear dummy xy

il = cat(2,c{:});
jl = zeros(1,length(il));

cl = cellfun('length',c);
ccl = [ 0 ;cumsum(cl)];
for i=1:length(c)
  jl(ccl(i)+1:ccl(i+1)) = i;
end

%sort everything clockwise
ck = [c{:}];
cv = v(ck,:);

part = [ 1:10^6:length(cv) length(cv)+1];  % there might appear memory issues
dir = zeros(size(ck));
for k=1:length(part)-1
	cur = part(k):part(k+1)-1;  
  x = diff(cv(cur,1)); y = diff(cv(cur,2));
  l = length(x);
  dir(cur(1:end-2)) = x(1:l-1).*y(2:l)-x(2:l).*y(1:l-1);
end
dir = dir( ccl(1:end-1)+1);
c(dir>0) = cellfun(@fliplr,c(dir>0),'uniformoutput',false);

  clear cl ccl dir l x y dcv vc x y cv ck part i k cur
% vertice map
T = sparse(jl,il,1); 
  clear jl il
T(:,1) = 0; %inf

%edges
F = T * T';
  clear T;
F = triu(F,1) > 1;


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
ii = [gl ;gr]'; % linels  

% remove double edges
tmpii = sort(ii,2);
[tmpii ndx] = sortrows(tmpii);  %transpose

[k ib] = sort(ndx);

cc = [0; r1];
crc = [0 cumsum(cr1)];

nr = length(regionids);
ply = struct('xy',cell(1,nr), 'hxy',cell(1,nr)); %repmat({{}},1,nr));

for k =1:nr
  sel = cc(crc(k)+1)+1:cc(crc(k+1)+1);

  if cr1(k) > 1
    %remove double entries
    [ig nd] = sort(ib(sel));
    dell = find(sum(diff(tmpii(ig,:)) == 0,2)>1);
    sel( nd([dell dell+1]) ) = []; 
  
    border = converttoborder(gl(sel), gr(sel));
    
    psz = numel(border);
    if psz == 1
    	ply(k).xy = verts(border{1},:);      
    elseif psz > 1
      bo = cell(1,psz);
      ar = zeros(1,psz);
      for l=1:psz
        bo{l} = verts(border{l},:);
        ar(l) = farea(bo{l});
      end
      
      [ig ndx] = sort(ar,'descend');
      
      ply(k).xy = bo{ndx(1)};
      ply(k).hxy = bo(ndx(2:end));
      %? holes
    end
  else
    % finish polygon
    ply(k).xy = verts([gl(sel) gl(sel(1))],:);
  end  
end


function plygn = converttoborder(gl, gr)
% this should be done faster

if isempty(gl)
  plygn = {};
  return
end


nf = length(gr)*2;  
f = zeros(1,nf);  %minimum size
  
%hamiltonian  trials
f(1) = gl(1);
cc = 0; 
      
k=2;
while 1
  ro = find(f(k-1) == gr);
  
  if ~isempty(ro)
    ro = ro(end);
    f(k) = gl(ro);     
  else  
    ro = find(gr>0);
    if ~isempty(ro)
      ro = ro(1);
      f(k) = gl(ro);
      cc(end+1) = k-1;
    else
      cc(end+1) = k-1;
      break;
    end 
  end
    
  gr(ro) = -1;
  k = k+1;
end
  
%convert to cells
nc = length(cc)-1;  
plygn = cell(1,nc);
for k=1:nc 
  if k > 1
    plygn{k} = [f(cc(k)+1:cc(k+1)) f(cc(k)+1)];
  else
    plygn{k} = f(cc(k)+1:cc(k+1));
  end
end  


function A = farea(xy)
x = xy(:,1);
y = xy(:,2);

l = length(x);

cr = x(1:l-1).*y(2:l)-x(2:l).*y(1:l-1);

A = abs(sum(cr)*0.5);

% 
% function [ply] = createpolygon(c,v)
% 
% gl = cat(2,c{:});
% 
% if length(c) == 1  %one cell
%   border = [gl gl(1)];
%   holes = cell(0);  
% else             
%   %shift indices
%   inds = 2:length(gl)+1;
%   r1 = cellfun('length',c);
%   r1 = cumsum(r1);
%   r2 = [1 ; r1+1];
%   r2(end) =[];  
%   inds(r1) = r2;
%   
%   gr = gl(inds); %partner pointel
%   ii = [gl ;gr]'; % linels  
%   
%   
% %   dell = gl'*gl -gr'*gr;
% %   dell = any(dell == 0,2);
% %   gl = gl(~dell);
% %   gr = gr(~dell);
% %   
% % remove double edges
%   tmpii = sort(ii,2);
%   [tmpii ndx] = sortrows(tmpii);  %transpose
%   
%   dell = all(diff(tmpii) == 0,2);   %entry twice  
%   dell = [ 0; dell] | [ dell; 0]; 
%   gl = gl(ndx(~dell));
%   gr = gr(ndx(~dell));
%   
%   nf = length(gr)*2;  
%   f = zeros(1,nf);  %minimum size
%  
%   if isempty(ii)
%      ply.xy = v(gl,:);
%      ply.hxy = cell(0);
%     return;
%   end
%     
% %hamiltonian  trials
%   f(1) = gl(1);
%   cc = 0; 
%       
%   k=2;
%   while 1
%     ro = find(f(k-1) == gr); % this can be done faster, since only the last match is of interest
%     
%     if ~isempty(ro)
%       ro = ro(end);
%       f(k) = gl(ro);     
%     else  
%       ro = find(gr>0);
%       if ~isempty(ro)
%         ro = ro(1);
%         f(k) = gl(ro);
%         cc(end+1) = k-1;
%       else
%         break;
%       end 
%     end
%     
%     gr(ro) = -1;
%     k = k+1;
%   end
%   
% %convert to cells
%   nc = length(cc);
%   cc(end+1) = k-1;
%   
%   plygn = cell(1,nc);
%   for k=1:nc 
%     if k > 1
%       plygn{k} = [f(cc(k)+1:cc(k+1)) f(cc(k)+1)];
%     else
%       plygn{k} = f(cc(k)+1:cc(k+1));
%     end
%   end  
% 
% %border
%   psz = length(plygn);
%  
%   %holes?
%   if psz > 1
%     area = zeros(1,psz);
%     for kpc= 1:psz
%       inds = plygn{kpc};    
%       px = v(inds,1); 
%       py = v(inds,2);
% 
%       area(kpc) = polyarea(px,py);
%     end
%     
%     [C I] = max(area);         
%     holes = plygn;
%     holes(I) = [];
%     border = plygn{I};
%   else
%     border = plygn{:};
%     holes = cell(0);
%   end
% end
% 
% ply.xy = v(border,:);
% ply.hxy = cell(0);
% 
% if ~isempty(holes)
%   ply.hxy = cellfun(@(h) v(h,:),holes,'uniformoutput',false);
% end

