function plotgrains(grains,varargin)
% plot the grain boundaries
%
%% Syntax
%  plotgrains(grains)
%  plotgrains(grains,LineSpec,...)
%  plotgrains(grains,'property',PropertyValue,...)
%  plotgrains(grains,'property','orientation',...)
%  plotgrains(grains,ebsd,'misorientation',...)
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

ishull = check_option(varargin,{'hull','convhull'});
property = get_option(varargin,'property','orientation');
  %treat varargin

%% get the polygons

p = polygon(grains)';

%% data preperation

if ishull
  for k=1:length(p)
	xy = p(k).xy;    
    p(k).xy = xy(convhull(xy(:,1),xy(:,2)),:);
  end 
end

%% sort for fixing hole problem

pl = cellfun('length',{p.xy}); %pseudo-perimeter
[pl ndx] = sort(pl,'descend');
p = p(ndx);
grains = grains(ndx);

%% setup grain plot

newMTEXplot;
%set(gcf,'renderer','opengl');
% 
%%

if ~isempty(property)
  cc = lower(get_option(varargin,'colorcoding','ipdf'));
  
  %get the property     
  if ischar(property) 
    prop = get(grains,property);
  else
    prop = property(ndx);
  end
    
  if isa(prop,'quaternion')
    
    phase = get(grains,'phase');
    CS = get(grains,'CS');
    [phase1, m] = unique(phase);
    d = zeros(length(grains),3);
    for i = 1:length(phase1)
      sel = phase == phase1(i);
      d(sel,:) = reshape(orientation2color(prop(sel),cc,varargin{:}),sum(sel),[]);
    end
        
    setappdata(gcf,'CS',CS)
    setappdata(gcf,'r',get_option(varargin,'r',xvector,'vector3d')); 
    setappdata(gcf,'colorcenter',get_option(varargin,'colorcenter',[]));
    setappdata(gcf,'colorcoding',cc);
    setappdata(gcf,'options',extract_option(varargin,'antipodal'));
  elseif isnumeric(prop) && length(p) == length(prop) || islogical(prop)
    d = reshape(real(prop),[],1);  
  else
    error('Please verify your property')
  end
   
  if strcmpi(property,'phase')
    [x f d] = unique(d);
    co = get(gca,'colororder');
    colormap([get(gca,'color');co(x,:)]);
  end
  
  h = [];
  %split data
  ind = splitdata(pl,3);
 
  for k=1:length(ind)
    pind = ind{k}; 
    tp = p(pind);  %temporary polygons
    fac = get_faces({tp.xy}); % and its faces    
    xy = vertcat(tp.xy);
    if ~isempty(xy)
      [X, Y lx ly] = fixMTEXscreencoordinates(xy(:,1),xy(:,2),varargin{:});
    end    
    
    if ~isempty(fac)      
      if ishull
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
  if check_option(varargin,'misorientation')
    
    plotspatial(misorientation(grains,ebsd),varargin{:});
    return
  end
  
else 
  
  xy = cell2mat(arrayfun(@(x) [x.xy ; NaN NaN],p,'UniformOutput',false)); 
  [X,Y, lx,ly] = fixMTEXscreencoordinates(xy(:,1),xy(:,2),varargin{:});
  
  ih = ishold;
  if ~ih, hold on, end
  
  h(1) = plot(X(:),Y(:));

  %holes
  if ~check_option(varargin,'noholes') && ~ishull
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


function faces = get_faces(cxy)

cl = cellfun('length',cxy);
rl = max(cl);
crl = [0 cumsum(cl)];
faces = NaN(length(cxy),rl);
for k = 1:length(cxy)
  faces(k,1:cl(k)) = (crl(k)+1):crl(k+1);
end




