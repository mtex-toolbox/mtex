function plotgrains(grains,varargin)
% plot the grain boundaries
%
%% Syntax
%  plotgrains(grains)
%  plotgrains(grains,LineSpec,...)
%  plotgrains(grains,'PropertyName',PropertyValue,...)
%  plotgrains(grains,'property','mean',...)
%  plotgrains(grains,ebsd,'diffmean',...)
%
%% Input
%  grains - @grain
%  ebsd   - @EBSD
%
%% Options
%  NOHOLES  -  plot grains without holes
%  HULL / CONVHULL - plot the convex hull of grains
%
%% See also
% grain/plot grain/plotellipse grain/plotsubfractions

if nargin>1 && isa(varargin{1},'EBSD')
  ebsd = varargin{1};
  varargin = varargin(2:end);
elseif nargin>1 && isa(grains,'EBSD') && isa(varargin{1},'grain')
  ebsd = grains;
  grains = varargin{1};
  varargin = varargin(2:end);
end

convhull = check_option(varargin,{'hull','convhull'});
property = get_option(varargin,'property',[]);
  %treat varargin

%% get the polygons

p = polygon(grains)';

%% data preperation

if convhull
  for k=1:length(p)
    xy = p(k).xy;
    K = convhulln(p(k).xy);
    p(k).xy = xy([K(:,1); K(1,1)],:);
  end 
end

%% sort for fixing hole problem

pl = cellfun('length',{p.xy}); %pseudo-perimeter
[pl ndx] = sort(pl,'descend');
p = p(ndx);
grains = grains(ndx);

%% setup grain plot

newMTEXplot;
set(gcf,'renderer','opengl');

%%
if property
  cc = lower(get_option(varargin,'colorcoding','ipdf'));
  
  %get the coloring   
  if ~check_property(grains,property)
	  warning(['MATLAB:plotgrains:' property], ...
            ['please calculate ' property ' as object property first to ' ...
             'reduce subsequent calculations \n' ...
             'procede with random colors']) 
    d = rand(length(p),3);
  else     
    switch property
      case 'mean'
        qm = get(grains,'mean');
        phase = get(grains,'phase');
        CS = get(grains,'CS');
        SS = get(grains,'SS');
        [phase1, m] = unique(phase);
        d = zeros(length(grains),3);
        for i = 1:length(phase1)
          sel = phase == phase1(i);
          grid = SO3Grid(qm(sel),CS(m(i)),SS(m(i)));       
          d(sel,:) = orientation2color(grid,cc,varargin{:});
        end
        if strcmpi(cc,'ipdf')
          setappdata(gcf,'CS',vec2cell(CS(m)));
          setappdata(gcf,'r',get_option(varargin,'r',xvector,'vector3d'));
          setappdata(gcf,'colorcoding',...
            @(h,i) orientation2color(h,cc,'cs',CS(m(i)),varargin{:}))
          setappdata(gcf,'options',extract_option(varargin,'antipodal'));
        end
      case 'phase'
        [x x d] = unique(get(grains,'phase')');
        co = get(gca,'colororder');
        colormap([get(gca,'color');co(unique(d),:)]);
      case fields(grains(1).properties)
        d = get(grains,property)';
      otherwise
        error('MTEX:wrongProperty',['Property ''',property,''' not found!']);
    end
  end  
  
  h = [];
  %split data
  ind = splitdata(pl);
 
  for k=1:length(ind)
    pind = ind{k}; 
    tp = p(pind);  %temporary polygons
    fac = get_faces({tp.xy}); % and its faces    
    xy = vertcat(tp.xy);
    if ~isempty(xy)
      [X, Y lx ly] = fixMTEXscreencoordinates(xy(:,1),xy(:,2),varargin{:});
    end    
    
    if ~isempty(fac)      
      if convhull
        h(end+1) = patch('Vertices',[X Y],'Faces',fac,'FaceVertexCData',d(pind,:));
      else
        hashols = hasholes(grains(pind));          
        if any(hashols)   
          hh = find(hashols);
          
          %hole polygon
          hp = [tp(hh).hxy];
          hxy = vertcat(hp{:});
          [hX,hY] = fixMTEXscreencoordinates(hxy(:,1),hxy(:,2),varargin{:});
          hfac = get_faces(hp);
            c = repmat(get(gca,'color'),size(hfac,1),1);
            
          h(end+1) = patch('Vertices',[X Y],'Faces',fac(hh,:),'FaceVertexCData',d(pind(1)+hh-1,:));            
          h(end+1) = patch('Vertices',[hX hY],'Faces',hfac,'FaceVertexCData',c);
        end
 
        if any(~hashols)
          nh = find(~hashols);          
          h(end+1) = patch('Vertices',[X Y],'Faces',fac(nh,:),'FaceVertexCData',d(pind(1)+nh-1,:));
        end  
      end
    end
  end
  set(h,'FaceColor','flat')
elseif exist('ebsd','var') 
  if check_option(varargin,'diffmean') 
    if ~check_property(grains,'mean'),  
      warning('MATLAB:plotgrains:mean', ...
        'please calculate mean as object property first') 
    end
    
    [grains ebsd ids] = get(grains, ebsd(1));
    grid = getgrid(ebsd,'CheckPhase');
    cs = get(grid,'CS');
    ss = get(grid,'SS');  
    
    if ~isempty(grains)
      qm = get(grains,'mean');
      
      [ids2 ida idb] = unique(ids);
      [a ia ib] = intersect([grains.id],ids2);

      ql = symmetriceQuat(cs,ss,quaternion(grid));
      qr = repmat(qm(ia(idb)).',1,size(ql,2));
      q_res = ql.*inverse(qr);
      omega = rotangle(q_res);
  
      [omega,q_res] = selectMinbyRow(omega,q_res);
      
      plotspatial(set(ebsd(1),'orientations',SO3Grid(q_res,cs,ss)),varargin{:});
      return
    end
  end
  
else 
  
  xy = cell2mat(arrayfun(@(x) [x.xy ; NaN NaN],p,'UniformOutput',false)); 
  [X,Y, lx,ly] = fixMTEXscreencoordinates(xy(:,1),xy(:,2),varargin{:});
  
  ih = ishold;
  if ~ih, hold on, end
  
  h(1) = plot(X(:),Y(:));

  %holes
  if ~check_option(varargin,'noholes') && ~convhull
    bholes = hasholes(grains);
    
    if any(bholes)
      ps = polygon(grains(bholes))';

      xy = cell2mat(arrayfun( @(x) ...
        cell2mat(cellfun(@(h) [h;  NaN NaN], x.hxy,'uniformoutput',false)') ,...
        ps,'uniformoutput',false));
      
      [X,Y] = fixMTEXscreencoordinates(xy(:,1),xy(:,2),varargin{:});
      h(2) = plot(X(:),Y(:));
     
    end
  end
  if ~ih, hold off, end
end
  
xlabel(lx); ylabel(ly);
fixMTEXplot;
  
%
set(gcf,'ResizeFcn',{@fixMTEXplot,'noresize'});
selector(gcf,grains,p,h);
%apply plotting options
if exist('h','var'), optiondraw(h,varargin{:});end





function  b = check_property(grains,property)

b = any(strcmpi(fields(grains(1).properties),property));

    
function faces = get_faces(cxy)

cl = cellfun('length',cxy);
rl = max(cl);
crl = [0 cumsum(cl)];
faces = NaN(length(cxy),rl);
for k = 1:length(cxy)
  faces(k,1:cl(k)) = (crl(k)+1):crl(k+1);
end


function ind = splitdata(pl)

% make n - partitions
n = 1:2;
n = sum(2.^n)+1;

pk{1} = pl;
ind{1} = 1:length(pl);
ps{1} = 0;
for k=1:n %pseudo recursion
  [pk{end+1} pk{end+2} ind{end+1} ind{end+2} ps{end+1} ps{end+2}] = split(pk{k},ps{k});
end
ind = ind(end-n:end);


function [s1 s2 ind1 ind2 low up] = split(s,ps)

m = mean(s);
ind1 = s >  m;
ind2 = s <= m;
s1 = s( ind1 );
s2 = s( ind2 );

ind1 = find(ind1)+ps;
ind2 = find(ind2)+ps;

if ~isempty(ind1)
  low = ind1(1)-1;
  up = ind1(end);
else
  low = ps;
  up = ps;
end



