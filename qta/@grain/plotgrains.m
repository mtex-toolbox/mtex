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
%  ebsd   - @ebsd
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
   
%%

newMTEXplot;
set(gcf,'renderer','opengl');

%% sort for fixing hole problem

A = area(grains); 
[ignore ndx] = sort(A,'descend'); 
grains = grains(ndx);

%% data preperation

p = polygon(grains)';

if convhull
  for k=1:length(p)
    xy = p(k).xy;
    K = convhulln(p(k).xy);
    p(k).xy = xy([K(:,1); K(1,1)],:);
  end  
end

%%

if ~isempty(property), xy = vertcat(p.xy);
else xy = cell2mat(arrayfun(@(x) [x.xy ; NaN NaN],p,'UniformOutput',false)); end

  [X,Y, lx,ly] = fixMTEXscreencoordinates(xy(:,1),xy(:,2),varargin);
  prepareMTEXplot(X,Y);
  xlabel(lx); ylabel(ly);

if property
  cc = lower(get_option(varargin,'colorcoding','ipdf'));
  
  fac = get_faces({p.xy}); 
     
  if ~check_property(grains,property)
	  warning(['MATLAB:plotgrains:' property], ...
            ['please calculate ' property ' as object property first to ' ...
             'reduce subsequent calculations \n' ...
             'procede with random colors']) 
    d = rand(length(fac),3);
  else     
    switch property
      case 'mean'
        qm = get(grains,'mean');
        phase = get(grains,'phase');
        CS = get(grains,'CS');
        SS = get(grains,'SS');
        [phase1, m] = unique(phase);
        
        if numel(phase1)>1
          warning('MTEX:MultiplePhases','This operatorion is only permitted for a single phase! I''m going to process only the first phase.');
        end
        sel = phase == phase1(1);
        grid = SO3Grid(qm(sel),CS(m(1)),SS(m(1)));

        fac = fac(sel,:);
        grains = grains(sel);
        
        d = orientation2color(grid,cc,varargin{:});    
      case 'phase'
        d = get(grains,'phase')';
        co = get(gca,'colororder');
        colormap(co(1:length(unique(d)),:))
    end
  end  
 
  if convhull
    h = patch('Vertices',[X Y],'Faces',fac,'FaceVertexCData',d,'FaceColor','flat',varargin{:});
  else
    hh = hasholes(grains);
    h = [];
    if any(hh)     
      h(1) = patch('Vertices',[X Y],'Faces',fac(hh,:),'FaceVertexCData',d(hh,:),'FaceColor','flat');
      hp = [p(hh).hxy];
      hxy = vertcat(hp{:});
      [hX,hY] = fixMTEXscreencoordinates(hxy(:,1),hxy(:,2),varargin);
      hfac = get_faces(hp);
        c = repmat(get(gca,'color'),length(hfac),1);
      h(2) = patch('Vertices',[hX hY],'Faces',hfac,'FaceVertexCData',c,'FaceColor','flat');
    end

    if any(~hh)
      h(end+1) = patch('Vertices',[X Y],'Faces',fac(~hh,:),'FaceVertexCData',d(~hh,:),'FaceColor','flat');
    end  
  end
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
  ih = ishold;
  if ~ih, hold on, end
  
  h(1) = plot(X(:),Y(:));

  %holes
  if ~check_option(varargin,'noholes') & ~convhull
    bholes = hasholes(grains);
    
    if any(bholes)
      ps = polygon(grains(bholes))';

      xy = cell2mat(arrayfun( @(x) ...
        cell2mat(cellfun(@(h) [h;  NaN NaN], x.hxy,'uniformoutput',false)') ,...
        ps,'uniformoutput',false));
      
      [X,Y] = fixMTEXscreencoordinates(xy(:,1),xy(:,2),varargin);
      h(2) = plot(X(:),Y(:));
     
    end
  end
  if ~ih, hold off, end
end
  
fixMTEXplot;

set(gcf,'ResizeFcn',@fixMTEXplot);

%apply plotting options
optiondraw(h,varargin{:});

%% setup grain selector

th=findobj(allchild(gcf),'type','uitoolbar');
if ~any(strcmpi(get(allchild(th),'tag'),'MTEX.grainselector'))
  a = rand(16,16,3);
  htt = uitoggletool(th,'Tag','MTEX.grainselector','CData',a,'TooltipString','Grain Selection','OnCallback',{@grainselector,'start'},'OffCallback',{@grainselector,'stop'});
end

oldgrains = getappdata(gcf,'grains');
oldpolygons = getappdata(gcf,'polygons');
if ~isempty(oldgrains)
  grains = [oldgrains(:)' grains(:)'];
  p = [oldpolygons(:)' p(:)'];
end
setappdata(gcf,'grains',grains);
setappdata(gcf,'polygons',p);

% TODO grain selector with eval expression



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



%% Grain Selector
function [h sel] = tooltip(empt,eventdata) %#ok<INUSL>

grains = getappdata(gcf,'grains');
p = getappdata(gcf,'polygons');
hs = getappdata(gcf,'selection');
ks = getappdata(gcf,'selected');

cp = get(gca,'CurrentPoint');
xp = cp(1,1);
yp = cp(1,2);

pl = cellfun('length',{p.xy});
cpl = [0 cumsum(pl)];

xy = vertcat(p.xy);
[X Y] = fixMTEXscreencoordinates( xy(:,1), xy(:,2) );

dist = sqrt((X-xp).^2 + (Y-yp).^2);
pp = find( dist <= min(dist)*sqrt(2));

for k=length(pl):-1:1
    if any( cpl(k)+1 < pp & cpl(k+1) > pp)
     [X Y] = fixMTEXscreencoordinates( p(k).xy(:,1), p(k).xy(:,2) );
     if inpolygon(xp,yp,X,Y)
       setappdata(gcf,'selected',[ks k]);
      
       hold on, 
        h(1) = plot(X(:),Y(:),'color','r','linewidth',2); 
      
        if hasholes(grains(k))
          xy = cell2mat(cellfun(@(h) [h;  NaN NaN], p(k).hxy,'uniformoutput',false)') ;

          [X,Y] = fixMTEXscreencoordinates(xy(:,1),xy(:,2));
          h(2) = plot(X(:),Y(:),'color','r','linewidth',1);
        end
      
      hold off
      break
     end
  end
end

if exist('h','var')
  setappdata(gcf,'selection',[hs h]);
end


function grainselector(hObject, eventdata,state)

switch state
  case 'start'        
    set(gcf,'WindowButtonDownFcn',@tooltip)
  case 'stop'
    set(gcf,'WindowButtonDownFcn',[])
    
    hs = getappdata(gcf,'selection');
    ks = getappdata(gcf,'selected');
    
    delete(hs)
    setappdata(gcf,'selection',[]);
    setappdata(gcf,'selected',[]);
    
    grains = getappdata(gcf,'grains');      
    
    if ~isempty(ks)
      treatselection(grains(ks))
    end
end

function treatselection(grains)

str = {'assign in workspace','plot ODF','plot ODF with neighbours'};

[sel,ok] = listdlg('Name','Grain Selection','PromptString','Select an Operation:',...
                'SelectionMode','single',...
                'ListSize',[150 200],...
                'ListString',str);

if ok
  switch sel
    case 1 % workspace
      name = inputdlg({'Enter Variable name:'},'Grains to Workspace',1,{'grain_selection'});
      if ~isempty(name), assignin('base', name{1}, grains ); end
    case {2, 3} % odfs
      ebsd = getappdata(gcf,'ebsd');
      if isempty(ebsd)
        name = inputdlg({'Workspace Variable of corresponding EBSD-data:'},'EBSD Data Setup',1,{'ebsd'});
        ebsd = evalin('base', name{1});
        setappdata(gcf,'ebsd',ebsd);
      end
      
      types = {'SIGMA','ALPHA','GAMMA','PHI1','PHI2'};
      [sel2, ok] = listdlg('Name','Plotting options',...
        'SelectionMode','single',...
        'ListSize',[150 70],...
        'PromptString','Plot type','ListString',types);      
      if ok, 
        oldfig = gcf;
        figure
        eb = get(ebsd,grains);      
        
        if sel == 3
          org_grains = getappdata(oldfig,'grains');
          org_grains = org_grains(ismember(vertcat(org_grains(:).id),vertcat(grains(:).neighbour)));
          
          pha = get(eb,'phase');
          phb = get(ebsd,'phase');         
          
          eb2 = get(ebsd(phb == pha(1)),org_grains);          
          
          plot(eb2,types{sel2},'SECTIONS',6,'markercolor','r','MarkerSize',1); 
        end
        
        hold on, plot(eb,types{sel2},'SECTIONS',6); 
      end
     
  end
end
       


