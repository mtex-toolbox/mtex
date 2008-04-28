function plotData(X,Y,data,bounds,varargin)

bounds(3:4) = bounds(1:2) + bounds(3:4);

if isempty(get(gca,'children')) && ~isempty(data) && isa(data,'double')
  if max(data(:))-min(data(:)) < 1e-15
    caxis([min(min(data(:)),0),max(max(data(:)),1)]);
  else
    caxis([min(data(:)),max(data(:))]);
  end
end

% contour plot
if check_option(varargin, {'CONTOUR','CONTOURF'}) 

  contours = get_option(varargin,{'contourf','contour'},{},'double');
  if ~isempty(contours), contours = {contours};end
  
  if check_option(varargin,'CONTOURF') % filled contour plot
  
    [CM,h] = contourf(X,Y,data,contours{:});
    set(h,'LineStyle','none');
  end
  
  contour(X,Y,data,contours{:},'k');
  set(gcf,'Renderer','painters');
       
% smooth plot
elseif check_option(varargin,'SMOOTH') 
  
  if check_option(varargin,'interp')   % interpolated

    pcolor(X,Y,data);
    if numel(data) >= 500, shading interp;end
    %set(gcf,'Renderer','OpenGL');
    set(gcf,'Renderer','zBuffer');
    
  else  

    if isappr(min(data(:)),max(data(:))) % empty plot
      ind = convhull(X,Y);
      fill(X(ind),Y(ind),min(data(:)));
    else
      [CM,h] = contourf(X,Y,data,50);
      set(h,'LineStyle','none');
    end
  end
  
% singular points 
elseif isa(data,'cell') || check_option(varargin,'dots')% || numel(X)<20
    set(gcf,'Renderer','painters');
  
  if check_option(varargin,'annotate')
    x = get(gca,'xlim');
    y = get(gca,'ylim');
    ind = find(X >= x(1)-0.0001 & X <= x(2)+0.0001 & Y >= y(1)-0.0001 & Y <= y(2)+0.0001);
  else
    ind = 1:numel(X);
  end  
  
  for i = ind
    text(X(i),Y(i),'$\bullet$',...
      'FontSize',round(get_option(varargin,'FontSize',13)/2*3),...
      'color',get_option(varargin,'color','k'),...
      'HorizontalAlignment','Center','VerticalAlignment','middle','interpreter','latex');
    if isa(data,'cell')
      smarttext(X(i),Y(i),data(i),bounds,...
        'FontSize',get_option(varargin,'FontSize',13),...
        'Interpreter','latex');
    end
  end
  
elseif check_option(varargin,'scatter')
    
  diameter  = get_option(varargin,'diameter');
  if~isempty(data), 
    h = scatter(X(:),Y(:),(diameter*100)^2,data(:),'filled');
  else
    h = scatter(X(:),Y(:),(diameter*100)^2,...
      get_option(varargin,'color'),'filled');
  end
  set(h,'tag','scatterplot','UserData',diameter/3.2);
  
else
  
  % get options
  diameter  = get_option(varargin,'diameter');

  cminmax = get_option(varargin,'colorrange',...
    [min(data(data>-inf)),max(data(data<inf))]);
    
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
