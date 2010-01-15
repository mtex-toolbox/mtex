function plotData(X,Y,data,bounds,varargin)

if check_option(varargin,'colorrange','double')
  cr = get_option(varargin,'colorrange',[],'double');
  if cr(2)-cr(1) < 1e-15
    caxis([min(cr(1),0),max(cr(2),1)]);
  else
    caxis(cr);
  end
end

h = [];
plottype = get_flag(varargin,{'CONTOUR','CONTOURF','SMOOTH','SCATTER','TEXTUREMAP','rgb'});

%% round data for faster plotting

if check_option(varargin,{'contour','contourf','smooth'}) ...
    && exist('cr','var') && isa(data,'double') && ndims(data) == 2
  ca = caxis;
  dd = ca(2) - ca(1);
  data = ca(1) + dd/1024 * round(1024/dd * (data-ca(1)));
end


%% for compatiility with version 7.1
if ndims(X) == 2 && X(1,1) > X(1,end)
  X = fliplr(X);
  Y = fliplr(Y);
  data = flipdim(data,2);
end

%%

if check_option(varargin,'correctContour')  
  X = [X;X(1,:)];
  Y = [Y;Y(1,:)];
  data = [data;data(1,:)];
end

%% contour plot
if any(strcmpi(plottype,'TEXTUREMAP')) 

  set(gcf,'renderer','opengl');
  surface(X,Y,ones(size(X)),data,...
    'CDataMapping','direct','FaceColor','texturemap')
  shading flat

%% rgb plot
elseif any(strcmpi(plottype,'rgb'))
  
  set(gcf,'renderer','zBuffer');
  surf(X,Y,zeros(size(X)),real(data))
  shading interp
       
  
%% contour plot
elseif any(strcmpi(plottype,{'CONTOUR','CONTOURF'})) 

  set(gcf,'Renderer','painters');
  contours = get_option(varargin,{'contourf','contour'},{},'double');
  if ~isempty(contours), contours = {contours};end
  
  if check_option(varargin,'CONTOURF') % filled contour plot
  
    if numel(unique(data)) == 1
      fill(X,Y,data,'LineStyle','none');
    else
      [CM,h] = contourf(X,Y,data,contours{:});
      set(h,'LineStyle','none');
    end
  end
  if numel(unique(data)) > 1
    [CM,hh] = contour(X,Y,data,contours{:},'k');
    h = [h,hh];
  end

%% smooth plot
elseif any(strcmpi(plottype,'SMOOTH'))
  
  if check_option(varargin,'interp')   % interpolated

    h = pcolor(X,Y,data);
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
    
    set(gcf,'Renderer','painters');
    if isappr(min(data(:)),max(data(:))) % empty plot
      ind = convhull(X,Y);
      fill(X(ind),Y(ind),min(data(:)));
    else
      [CM,h] = contourf(X,Y,data,50);
      set(h,'LineStyle','none');
    end

  end
  
%% scatter plots
else 
  lastwarn('')
  set(gcf,'Renderer','Painters');  

  % get options
  options = {};
  
  % restrict to plotted region
  if check_option(varargin,'annotate')
    x = get(gca,'xlim');
    y = get(gca,'ylim');
    ind = find(X >= x(1)-0.0001 & X <= x(2)+0.0001 & Y >= y(1)-0.0001 & Y <= y(2)+0.0001);
    X = X(ind);
    Y = Y(ind);
    if ~isempty(data), data = data(ind);end
  end

  % Marker Size
  res = get_option(varargin,'scatter_resolution',10*degree);
  defaultMarkerSize = min(8,max(1,50*res));
  
  if check_option(varargin,'dynamicMarkerSize')
    options = {'tag','scatterplot','UserData',get_option(varargin,'MarkerSize',min(8,50*res))/50};
  end

  if ~isempty(data) && isa(data,'double') % data colored markers
    
    range = get_option(varargin,'colorrange',...
      [min(data(data>-inf)),max(data(data<inf))],'double');
    
    in_range = data >= range(1) & data <= range(2);
    
    % draw out of range markers
    if any(~in_range)
      h(2) = patch(X(~in_range),Y(~in_range),1,...
        'FaceColor','none',...
        'EdgeColor','none',...
        'MarkerFaceColor','w',...
        'MarkerEdgeColor','k',...
        'MarkerSize',get_option(varargin,'MarkerSize',defaultMarkerSize),...
        'Marker','o',options{:});
      X = X(in_range);
      Y = Y(in_range);
      data = data(in_range);
    end    
    
  else

    if ~isempty(data) % labels plot

      for i = 1:numel(data)
        smarttext(X(i),Y(i),data{i},bounds,'Margin',0.1,varargin{:});
      end
    end

    data = 1;
%   cax = getappdata(gcf,'colorbaraxis');
%   if ~isempty(cax)
%      hold(cax,'all');
%      scatter(cax,1,1,...
%        'MarkerFaceColor',get_option(varargin,{'MarkerFaceColor','MarkerColor'},'flat'),...
%        'MarkerEdgeColor',get_option(varargin,{'MarkerEdgeColor','MarkerColor'},'flat'),...
%        'visible','off',...
%        'Marker',get_option(varargin,'Marker','o'));
%      set(cax,'visible','off');
%    end
  end
    
  MFC = get_option(varargin,{'MarkerFaceColor','MarkerColor'},'flat');
  MEC = get_option(varargin,{'MarkerEdgeColor','MarkerColor'},MFC);
  
  % draw markers
  if ~isempty(X)
    h(1) = patch(X,Y,data,...
      'FaceColor','none',...
      'EdgeColor','none',...
      'MarkerFaceColor',MFC,...
      'MarkerEdgeColor',MEC,...
      'MarkerSize',get_option(varargin,'MarkerSize',defaultMarkerSize),...
      'Marker',get_option(varargin,'Marker','o'),...
      options{:});

    % draw invisible marker for legend only
    if length(data)==1 && data == 1
      patch(X(1),Y(1),data,...
        'FaceColor','none',...
        'EdgeColor','none',...
        'MarkerFaceColor',MFC,...
        'MarkerEdgeColor',MEC,...
        'Marker',get_option(varargin,'Marker','o'),...
        'visible','off',...
        options{:});
    end

  end  
end

% control legend entry
setLegend(h,'off');

