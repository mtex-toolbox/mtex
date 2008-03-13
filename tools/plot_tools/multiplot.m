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
  minz = min(minz,min(Y{i}(:)));
  maxz = max(maxz,max(Y{i}(:)));
  if ~check_option(varargin,'silent') && check_option(varargin,'DISP')
    s = get_option(varargin,'DISP');
    disp(s(i,Y{i}));
  end
end

%% calculate contour levels for absolute colorcoding

if strcmpi(get_option(varargin,'colorrange'),'equal')
  colorrange = [minz,maxz];
else
  colorrange = get_option(varargin,'colorrange',[],'double');
end


if length(colorrange) == 2
   
  % set range for colorcoding
  varargin = set_default_option(varargin, {},'range',colorrange);
  
  % set contour levels
  ncontour = get_option(varargin,{'contour','contourf'},10,'double');
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

% clear figure
clf('reset');
figure(clf);
%set(gcf,'Visible','off');
%set(gcf,'toolbar','none');

% init statusbar
sb = statusbar('drawing plots ...');
set(sb.ProgressBar, 'Visible','on', 'Minimum',0, 'Maximum',nplots, 'Value',0, 'StringPainted','on');

fontsize = get_option(varargin,'FONTSIZE',12);

for i = 1:nplots
	
  a(i) = axes;%#ok<AGROW>
  set(a(i),'Visible','off')
  Z = Y{i};
  X = x(i);
  plot(X,'DATA',Z,varargin{:});
  set(sb.ProgressBar,'Value',i);
    
  if check_option(varargin,'MINMAX') 
    anotation(a(i),min(Z(:)),max(Z(:)),fontsize);
  end
  if check_option(varargin,'ANOTATION')
    s = get_option(varargin,'ANOTATION');
    text(0.98,0.99,s(i),...
      'HorizontalAlignment','Right','VerticalAlignment','top',...
      'FontName','times','FontSize',fontsize,'Interpreter','latex',...
      'units','normalized');
  end
end

% clear statusbar
statusbar;

if length(colorrange) == 2, setcolorrange(colorrange);end
set(gcf,'ResizeFcn',@(src,evt) figResize(src,evt,a));
%set(gcf,'Position',get(gcf,'Position'));
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

set(a,'Visible','on');

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
figpos = get(fig,'Position');
offsety = 1;%25;
offsetx = 0;%10;
%figpos(3:4) = figpos(3:4) - 1;
figpos(4) = figpos(4)-offsety;
figpos(3) = figpos(3)-offsetx;
dxdy = get(a(1),'PlotBoxAspectRatio');
dxdy = dxdy(2)/dxdy(1);
[nx,ny,l] = bestfit(figpos(3),figpos(4)/dxdy,length(a));
set(gcf,'UserData',[nx*l,ny*l*dxdy]);

for i = 1:length(a)
  [px,py] = ind2sub([nx ny],i);
  apos = [1+(px-1)*l,offsety+1+figpos(4)-py*l*dxdy,l,l*dxdy];
  set(a(i),'Units','pixels','Position',apos);
end
  
u = findobj(gcbo,'Tag','rda');
for i = 1:length(u)
 
 a = get(u(i),'parent');
 set(a,'units','points');
 apos = get(a,'Position');
 set(u(i),'Units','points','Position',[apos(3)-1,3]);
end

set(fig,'Units',old_units);


end

%% determine best alignment of subfigures
function [nx,ny,l] = bestfit(dx,dy,n)

ny = 1;
nx = n;
l = min(dx/nx,dy/ny);
if n == 1, return;end
for ny=2:n
  nx = ceil(n/ny);
  if min(dx/nx,dy/ny) < l
    ny = ny-1; %#ok<FXSET>
    nx = ceil(n/ny);
    break
  else
    l = min(dx/nx,dy/ny);
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
