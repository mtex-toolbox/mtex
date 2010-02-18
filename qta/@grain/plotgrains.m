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

if ishull % do it faster somehow
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
% set(gcf,'renderer','opengl');
% 
%%


if ~isempty(property)
  if strcmpi(property,'orientation')
    
    cc = lower(get_option(varargin,'colorcoding','ipdf'));
    
    [phase,uphase]= get(grains,'phase');    
    CS = cell(size(uphase));
    
    d = zeros(numel(grains),3);
    for k=1:numel(uphase)
       sel = phase == uphase(k);
       o = get(grains(sel),property);
       CS{k} = get(o,'CS');
       
       c = orientation2color(o,cc,varargin{:});
       d(sel,:) = reshape(c,[],3);
    end
           
    setappdata(gcf,'CS',CS)
    setappdata(gcf,'r',get_option(varargin,'r',xvector,'vector3d')); 
    setappdata(gcf,'colorcenter',get_option(varargin,'colorcenter',[]));
    setappdata(gcf,'colorcoding',cc);
    setappdata(gcf,'options',extract_option(varargin,'antipodal'));
    
  elseif any(strcmpi(property, fields(grains))) ||...
     any(strcmpi(property,fields(grains(1).properties)))
  
    d = reshape(get(grains,property),[],1);
    
    if strcmpi(property,'phase')
      colormap(hsv(max(d)+1));
    end
    
  elseif  isnumeric(property) && length(p) == length(property) || islogical(property)
    
    d = reshape(property(ndx),[],1);
    
  end
  
  h = [];
  %split data
  ind = splitdata(pl,3);
  x = 0; y = 0;
  for k=1:length(ind)
    pind = ind{k}; 
    tmp_ply = p(pind);  %temporary polygons
        
    [faces vertices] = get_faces(tmp_ply);
    
    if ~isempty(vertices)
      [X, Y lx ly] = fixMTEXscreencoordinates(vertices(:,1),vertices(:,2),varargin{:});
      x = min(X); y = min(Y);
    end
    
    if ~isempty(faces)
      if ishull
        h(end+1) = patch('Vertices',[X Y],'Faces',faces,'FaceVertexCData',d(pind,:));
      else
        holes = hasholes(grains(pind));
        
        if any(holes)
          [hfaces hvertices] = get_facesh(tmp_ply(holes));
          [hX,hY] = fixMTEXscreencoordinates(hvertices(:,1),hvertices(:,2),varargin{:});

          c = repmat(get(gca,'color'),size(hfaces,1),1);
          
          h(end+1) = patch('Vertices',[X Y],'Faces',faces(holes,:),'FaceVertexCData',d(pind(holes),:));            
          h(end+1) = patch('Vertices',[hX hY],'Faces',hfaces,'FaceVertexCData',c);
        end

        if any(~holes)
          h(end+1) = patch('Vertices',[X Y],'Faces',faces(~holes,:),'FaceVertexCData',d(pind(~holes),:));
        end  
      end
    end
  end
  %dummy patch
  [tx ty] = fixMTEXscreencoordinates(min(x), min(y),varargin{:});
  patch('Vertices',[tx ty],'Faces',1,'FaceVertexCData',get(gca,'color'));

  set(h,'FaceColor','flat')
  
elseif exist('ebsd','var') 
  
  if check_option(varargin,'misorientation')
    
    plotspatial(misorientation(grains,ebsd),varargin{:});
    return
  end
  
else
  
  for k=1:length(p), p(k).xy = [p(k).xy; NaN NaN]; end
  xy = vertcat(p.xy);
  
  [X,Y, lx,ly] = fixMTEXscreencoordinates(xy(:,1),xy(:,2),varargin{:});
  
  ih = ishold;
  if ~ih, hold on, end
  
  h(1) = plot(X(:),Y(:));

  %holes
  if ~check_option(varargin,'noholes') && ~ishull
    holes = hasholes(grains);
    
    if any(holes)      
      px = [p(holes).hxy]';
      for k=1:length(px), px{k} = [px{k}; NaN NaN]; end
      xy = vertcat(px{:});
      
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




function [faces vertices] = get_faces(cply)

vertices = vertcat(cply.xy);
faces = tofaces({cply.xy});


function [faces vertices] = get_facesh(cply)

hxy = [cply.hxy];
vertices = vertcat(hxy{:});
tmp = horzcat(hxy);
vertices = vertcat(tmp{:});
faces = tofaces(tmp);


function faces = tofaces(c)

cl = cellfun('length',c);
rl = max(cl);
crl = [0 cumsum(cl)];
faces = NaN(numel(c),rl);
for k = 1:numel(c)
  faces(k,1:cl(k)) = (crl(k)+1):crl(k+1);
end



