function ebsd = segment(ebsd,varargin)
% segmentation of ebsd data 
%
%% Input
%  ebsd   - @EBSD
%
%% Options
%  ANGLE  - threshold angle of mis/disorientation
%  misorientation - criterium of segmentation, default disorientation
%

angel_treshold = get_option(varargin,'angle',15*degree);

%% start timer

disp('EBSD segmentation');
tic

%% get ebsd data

xy = cell2mat(ebsd.xy);
q = quaternion(ebsd.orientations);

ph = [];
l = length(ebsd);
for i=1:numel(ebsd)
   q_cs{i} = quaternion(getCSym(ebsd.orientations(i)));
   ph = [ph repmat(i,1, l(i))];
end

[xy m n]  = unique(xy,'first','rows');
q = q(m);
ph = ph(m);

%% grid neighbours

neighbours = neighbour(xy);

%% disconnect different phases

[ix iy]= find(neighbours);
border = sparse(ix,iy,ph(ix) ~= ph(iy));
neighbours = xor(border,neighbours);

%% angel to neighbours

[ix iy]= find(neighbours);
angels = sparse(ix,iy,minangle(q(iy),q(ix),q_cs,ph(ix),varargin{:}));

%% find all angles lower threshold

%map of disconnected neighbours.
w = angels >= angel_treshold;
  %border = or(w, border);
le_angles = xor(w,neighbours); 

%% convert to tree graph

parent = etree(le_angles);
ids = graph2id(parent);

%% assign ids

ebsd.grainid = mat2cell(ids(n)',l,1);

%% stop timer
toc

%% some plotting
% 
% figure;
% co = [xy(:,1) xy(:,2)];
% gplot(neighbours,co,'b-');
% hold on
% gplot(angels >= angel_treshold,co,'r*');
% axis off
% axis equal
% 
% figure;
% gplot(le_angles,co,'b-');
% axis off
% axis equal
% 
% figure;
% treeplot(parent)

function ids = graph2id(parent)

%disp('Reading graph')
n = length(parent);

ids = zeros(1,n);
s = find(parent == 0);
ids(s) = 1:length(s);

parent = rem (parent+n, n+1) + 1;  % change all 0s to n+1s

%tic
for i=1:n
  if ids(i) == 0
    x = i;
    b = i; 
    while ids(x) == 0,
      x = parent(x);
      b = [b x]; 
    end
    ids(b) = ids(b(end));
  end
end
%toc

function angle = minangle(qr,qb,varargin)
% misorientation

if check_option(varargin,'misorientation')
  angle = zeros(numel(qr),1);
  q_cs = varargin{1};
  ph = varargin{2};
  for i=1:numel(q_cs)
    pind = find(ph==i);

    n = length(pind); %partition of data to fix memory issues
    par = 25000; 
    nmax = fix(n/par+1);
    for ik=1:nmax
      if ik ~= nmax
        ind = pind((ik-1)*par+1:ik*par);
      else
        ind = pind((ik-1)*par+1:end);
      end

      q_ref = repmat(inverse(qr(ind)),[],numel(q_cs{i}));
      q_cceq = q_cs{i} * qb(ind);
      sc = rotangle(q_cceq.*q_ref);
      angle(ind) = sc(sc == repmat(min(sc,[],1),length(q_cs{i}),1));
    end
  end
else
  angle = rotangle(inverse(qr).*qb);
end

function [F v c] = neighbour(xy)
% voronoi neighbours

[v c] = voronoin(xy);   %Qf {'Qf'}

% prepare data
il = [c{:}]';
jl = zeros(length(il),1);

cl = cellfun('prodofsize',c);
ccl = [ 1 ;cumsum(cl)+1];

for i=1:length(cl)  
  jl(ccl(i):ccl(i+1)-1) = i;
end

% vertice map
T = sparse(jl,il,1); 
T(:,1) = 0; 

%edges
F = T * T' > 1 ;
F = F - speye(length(c)); 