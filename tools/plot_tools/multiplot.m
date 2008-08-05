function multiplot(x,y,nplots,varargin)
% plot multiple graphs
%
%% Syntax
%  multiplot(x,y,nplots,'FONTSIZE',fontsize)
%  multiplot(x,y,nplots,'COLORCODING','equal')
%  multiplot(x,y,nplots,'COLORCODING',[cmin cmax])
%  multiplot(x,y,nplots,'ANNOTATION',string)
%
%% Input
%  x      - grid (@S1Grid, @S2Grid, @SO3Grid)
%  y      - vector of plot data
%  nplots - number of plots
%
%% Options
%  [cmin cmax] - minimum and maximum value for color coding
%  fontsize    - fontsize used for annotations
%  string      - some annotation to be added to the plot

%
%% Flags
%  MINMAX      - display minimum and maximum 
%  uncroppped  - do not resize window for a cropped plot
%  SILENT      - no output
%
%% See also
% S2Grid/plot savefigure   


%% calculate data
minz = +inf; maxz = -inf;
for i = 1:nplots
  Y{i} = y(i); %#ok<AGROW>
  minz = min(minz,min(Y{i}(Y{i}>-inf)));
  maxz = max(maxz,max(Y{i}(Y{i}<inf)));
  if ~check_option(varargin,'silent') && check_option(varargin,'DISP')
    s = get_option(varargin,'DISP');
    disp(s(i,Y{i}));
  end
end

%% contour levels and colorcoding

colorrange = [];

% contour levels specified ?
ncontour = get_option(varargin,{'contour','contourf'},10,'double');
if length(ncontour) >= 2, colorrange = [min(ncontour) max(ncontour)];end

% option colorrange set ?
if strcmpi(get_option(varargin,'colorrange'),'equal')
  colorrange = [minz,maxz];
else
  colorrange = get_option(varargin,'colorrange',colorrange,'double');
end

if length(colorrange) == 2 
   
  if check_option(varargin,'logarithmic')
    colorrange = log(colorrange) / log(10);
  end
  
  % set range for colorcoding
  varargin = set_option(varargin,'colorrange',colorrange);
  
  % expand contour levels
  if length(ncontour) == 1, ncontour = linspace(colorrange(1),colorrange(2),ncontour);end
  
  if check_option(varargin,'contour') 
    varargin = set_option(varargin,'contour',ncontour);
  elseif check_option(varargin,'contourf')
    varargin = set_option(varargin,'contourf',ncontour);
  end
  
end




%% 3d plot

if check_option(varargin,'3d')
  
  for i = 1:nplots
	
    figure
    Z = Y{i};
    X = x(i);
    plot(X,'DATA',Z,varargin{:});
    axis off;
    set(gca,'Tag','3d');
    h = rotate3d;
    set(h,'ActionPostCallback',@mypostcallback);
    set(h,'Enable','on');
    
  end

  return  
end


%% 2d plot

if ishold  

  if isappdata(gcf,'axes') && strcmp(get(gcf,'tag'),'multiplot') && ...
      length(findobj(gcf,'type','axes')) >= length(getappdata(gcf,'axes'))
    a = getappdata(gcf,'axes');    
  else
    hold off;    
  end
end

% clear figure
if ~ishold
  clf('reset');
  figure(clf);

  %set(gcf,'Visible','off');
  %set(gcf,'toolbar','none');

  % init statusbar
  try
    sb = statusbar('drawing plots ...');
    set(sb.ProgressBar, 'Visible','on', 'Minimum',0, 'Maximum',nplots, 'Value',0, 'StringPainted','on');
  catch
  end
end
fontsize = get_option(varargin,'FONTSIZE',13);

for i = 1:nplots
	
  if ~ishold
    a(i) = axes;
    set(a(i),'Visible','off')
  else
    axes(a(i));
    hold all;
  end
  Z = Y{i};
  X = x(i);
  plot(X,'DATA',Z,varargin{:},'axis',a(i));
  
  if ~ishold
    try, set(sb.ProgressBar,'Value',i);catch end
    
    if check_option(varargin,'MINMAX')
      anotation(a(i),min(Z(:)),max(Z(:)),fontsize);
    end
    if check_option(varargin,'ANOTATION')
      s = get_option(varargin,'ANOTATION');
      mtex_text(0.98,0.99,s(i),...
        'HorizontalAlignment','Right','VerticalAlignment','top',...
        'FontName','times','FontSize',fontsize,...
        'units','normalized');
    end
  end
end

if ~ishold
  % invisible axes for adding a colorbar
  d = axes('visible','off','position',[0 0 1 1],...
    'tag','colorbaraxis','HandleVisibility','callback');
  setappdata(gcf,'colorbaraxis',d);
  setappdata(gcf,'axes',a);
else 
  d = getappdata(gcf,'colorbaraxis');
end

if length(colorrange) ~= 2, colorrange = caxis; end

if colorrange(1) < colorrange(2)
  if check_option(varargin,'logarithmic')
    set(d,'ZScale','log');
    colorrange = 10.^colorrange;
  end
  set(d,'clim',colorrange);
else
  set(d,'clim',[0 2]);
end

if ~ishold
  
  % clear statusbar
  try, statusbar;catch,end; 

  set(gcf,'ResizeFcn',@(src,evt) figResize(src,evt,a));
  %set(gcf,'Position',get(gcf,'Position'));
  setappdata(gcf,'autofit','on');
  figResize([],[],a);
  if ~check_option(varargin,'uncropped')
    set(gcf,'Units','pixels');
    pos = get(gcf,'Position');
    si = get(gcf,'UserData');
    pos([3,4]) = si;
    set(gcf,'Position',pos);
  else
    set(gcf,'Position',get(gcf,'Position'));
  end

  set(gcf,'color',[1 1 1],'tag','multiplot','nextplot','replace');  
  set(a,'Visible','on');
else
  scalescatterplots(gcf);
  set(gcf,'nextplot','replace');
end

end

%% ================== private functions =========================


%% disp annotation in subfigures
function anotation(a,mini,maxi,fontsize)
mini = xnum2str(mini);
maxi = xnum2str(maxi);

set(a,'units','points');
apos = get(a,'Position');

text(1,3,{'min:',mini},'FontName','times','FontSize',fontsize,'Interpreter','tex',...
  'HorizontalAlignment','Left','VerticalAlignment','bottom',...
  'units','points');

text(apos(3)-1,3,{'max:',maxi},'FontName','times','FontSize',fontsize,'Interpreter','tex',...
  'HorizontalAlignment','Right','VerticalAlignment','bottom',...
  'units','points','Tag','rda');

end

%% resize figure and reorder subfigs
function figResize(src,evt,a) %#ok<INUSL,INUSL>

if isempty(gcbo) || gcbo ~= round(gcbo)
  fig = gcf;
else
  fig = gcbo;
end

old_units = get(fig,'Units');
set(fig,'Units','pixels');

if strcmp(getappdata(fig,'autofit'),'on')

  figpos = get(fig,'Position');
  border = get_mtex_option('border',10);
  spacingx = get_mtex_option('spacingx',0);
  spacingy = get_mtex_option('spacingy',0);

  figpos(4) = figpos(4)-2*border;
  figpos(3) = figpos(3)-2*border;
  dxdy = get(a(1),'PlotBoxAspectRatio');
  dxdy = dxdy(2)/dxdy(1);
  [nx,ny,l] = bestfit(figpos(3),figpos(4),dxdy,length(a),spacingx,spacingy);
  set(fig,'UserData',[nx*l+2*border+(nx-1)*spacingx,...
    ny*l*dxdy+2*border+(ny-1)*spacingy]);
  setappdata(fig,'length',l);

  for i = 1:length(a)
    [px,py] = ind2sub([nx ny],i);
    apos = [1+border+(px-1)*(l+spacingx),...
      1+border+figpos(4)-py*l*dxdy-(py-1)*spacingy,...
      l,l*dxdy];
    set(a(i),'Units','pixels','Position',apos);
  end
end

scalescatterplots(fig);
  
% set position of labels
u = findobj(fig,'Tag','rda');
for i = 1:length(u)
 
 a = get(u(i),'parent');
 set(a,'units','points');
 apos = get(a,'Position');
 set(u(i),'Units','points','Position',[apos(3)-1,3]);
end

set(fig,'Units',old_units);


end

function scalescatterplots(x)

% scale scatterplots
u = findobj(x,'Tag','scatterplot');
l = getappdata(x,'length');
for i = 1:length(u)
  d = get(u(i),'UserData');
  set(u(i),'SizeData',(l*d)^2);
end

end

%% determine best alignment of subfigures
function [nx,ny,l] = bestfit(dx,dy,dxdy,n,spacingx,spacingy)

% length in x direction
lx = @(nx,ny) min((dx-(nx-1)*spacingx)/nx,...
  (dy-(ny-1)*spacingy)/dxdy/ny);

ny = 1;
nx = n;
l = lx(nx,ny);
if n == 1, return;end
for ny=2:n
  nx = ceil(n/ny);
  if lx(nx,ny) > l
    l = lx(nx,ny);
  else
    ny = ny-1; %#ok<FXSET>
    nx = ceil(n/ny);
    break
  end
end
end



%% Callbacks for syncing 3d rotations

function mypostcallback(obj,evd)

cVA = get(evd.Axes,'cameraViewAngle');
cP = get(evd.Axes,'cameraPosition');
cT = get(evd.Axes,'cameraTarget');
cUV = get(evd.Axes,'cameraUpVector');

a = findobj('Tag','3d');
for i = 1:length(a)
  set(a(i),'cameraViewAngle',cVA);
  set(a(i),'cameraPosition',cP);
  set(a(i),'cameraTarget',cT);
  set(a(i),'cameraUpVector',cUV);
end

end
