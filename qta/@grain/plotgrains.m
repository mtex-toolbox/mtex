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

%% setup grain plot

newMTEXplot;
set(gcf,'renderer','opengl');
selector(gcf,grains,p);

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






