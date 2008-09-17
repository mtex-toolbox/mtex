function plotData(X,Y,data,bounds,varargin)

if check_option(varargin,'colorrange','double')
  cr = get_option(varargin,'colorrange',[],'double');
  if cr(2)-cr(1) < 1e-15
    caxis([min(cr(1),0),max(cr(2),1)]);
  else
    caxis(cr);
  end
end

plottype = get_flag(varargin,{'CONTOUR','CONTOURF','dots','smooth','scatter'});

% contour plot
if any(strcmpi(plottype,{'CONTOUR','CONTOURF'})) 

  contours = get_option(varargin,{'contourf','contour'},{},'double');
  if ~isempty(contours), contours = {contours};end
  
  if check_option(varargin,'CONTOURF') % filled contour plot
  
    [CM,h] = contourf(X,Y,data,contours{:});
    set(h,'LineStyle','none');
  end
  
  contour(X,Y,data,contours{:},'k');
  set(gcf,'Renderer','painters');
       
% smooth plot
elseif any(strcmpi(plottype,'SMOOTH'))
  
  if check_option(varargin,'interp')   % interpolated

    pcolor(X,Y,data);
    if numel(data) >= 500
     if length(unique(data))<50
       shading flat;
     else
       shading interp;
       set(gcf,'Renderer','zBuffer');
     end
    else
      set(gcf,'Renderer','painters');
    end
        
  else  

    if isappr(min(data(:)),max(data(:))) % empty plot
      ind = convhull(X,Y);
      fill(X(ind),Y(ind),min(data(:)));
    else
      [CM,h] = contourf(X,Y,data,50);
      set(h,'LineStyle','none');
    end
    set(gcf,'Renderer','painters');
  end
  
% singular points 
elseif isa(data,'cell') || any(strcmpi(plottype,'dots'))% || numel(X)<20
    set(gcf,'Renderer','painters');
  
  if check_option(varargin,'annotate')
    x = get(gca,'xlim');
    y = get(gca,'ylim');
    ind = find(X >= x(1)-0.0001 & X <= x(2)+0.0001 & Y >= y(1)-0.0001 & Y <= y(2)+0.0001);
  else
    ind = 1:numel(X);
  end  
  
  for i = 1:length(ind)
    j = ind(i);
    if isa(data,'cell') && ~check_option(varargin,'notext')
      smarttext(X(j),Y(j),data{j},bounds,...
        'Interpreter','latex','Margin',0.1,varargin{:});
    end
    mtex_text(X(j),Y(j),'\bullet',...
      'bulletFontSize',round(get_option(varargin,'FontSize',13)),...
      'bulletHorizontalAlignment','Center',...
      'bulletVerticalAlignment','middle',...
      'bullettag','bullet',...
      'prefix','bullet',varargin{:});
  end
  
elseif any(strcmpi(plottype,'scatter'))
    
  diameter  = get_option(varargin,'diameter');
  if ~isempty(data), 
    h = scatter(X(:),Y(:),(diameter*100)^2,data(:),'filled');
  else
    h = scatter(X(:),Y(:),(diameter*100)^2,...
      get_option(varargin,'bulletcolor'),'filled');
  end
  set(h,'tag','scatterplot','UserData',diameter/3.2);
  
else
  
  % get options
  diameter  = get_option(varargin,'diameter');

  cminmax = get_option(varargin,'colorrange',...
    [min(data(data>-inf)),max(data(data<inf))],'double');
    
  if length(cminmax)>1 && cminmax(2)>cminmax(1)
    data = 1+round((data-cminmax(1)) / (cminmax(2)-cminmax(1)) * 63);
  else
    data = ones(size(data));
  end

  myscatter(X(:),Y(:),data(:),diameter,varargin{:})
  
end


function myscatter(X,Y,C,diameter,varargin)

if isempty(C)

  c = get_option(varargin,'color','b');
  arrayfun(@(x,y) filled_circle(x,y,diameter,c),X,Y);  
  
else
  cmap = colormap;

  ind = C >= 1 & C <= 64;
  C = cmap(C(ind),:);
  
  arrayfun(@(x,y,c1,c2,c3) filled_circle(x,y,diameter,[c1,c2,c3]),...
    X(ind),Y(ind),C(:,1),C(:,2),C(:,3));  
  arrayfun(@(x,y) empty_circle(x,y,diameter),X(~ind),Y(~ind));  
  
end

function filled_circle(x,y,d,c)

rectangle('Position',[x-d/2,y-d/2,d,d],'Curvature',[1,1],'FaceColor',c,'EdgeColor',c);

function empty_circle(x,y,d)

rectangle('Position',[x-d/2,y-d/2,d,d],'Curvature',[1,1]);
