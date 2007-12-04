function multiplot(x,y,nplots,varargin)
% plot multiple graphs
% usage:  multiplot(x,y,nplots,<options>)
%
%% Input
%  x      - grid (@S1Grid, @S2Grid, @SO3Grid)
%  y      - vector of plot data
%  nplots - number of plots
%
%% Options
%  FONTSIZE,[int]     - fontsize used for annotations
%  ANOTATION,[string] - some annotation to be added to the plot
%
%% Flags
%  RELATIVE     - relative colorcoding (default)
%  ABSOLUTE     - absolute colorcoding 
%  MINMAX       - display minimum and maximum 
%  uncroppped   - do not resize window for a cropped plot
%  SILENT       - no output
%
%% See also
% S2Grid/plot savefigure   

clf('reset');
set(gcf,'Visible','off');
%set(gcf,'toolbar','none');

% calculate data
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

if check_option(varargin,'absolute')
  
  % set range for colorcoding
  varargin = set_default_option(varargin,'range',[minz,maxz]);
  
  % set contour levels
  ncontour = get_option(varargin,{'contour','contourf'},10,'double');
  if length(ncontour) == 1, ncontour = linspace(minz,maxz,ncontour);end
  
  if check_option(varargin,'contour') 
    varargin = set_option(varargin,'contour',ncontour);
  elseif check_option(varargin,'contourf')
    varargin = set_option(varargin,'contourf',ncontour);
  end
  
end


% plot
fontsize = get_option(varargin,'FONTSIZE',12);
for i = 1:nplots
	
  a(i) = axes;%#ok<AGROW>
  Z = Y{i};
  X = x(i);
  plot(X,'DATA',Z,varargin{:});
    
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

if ~check_option(varargin,'3d')
  if check_option(varargin,'absolute'), fitcaxis;end
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
end
set(gcf,'Visible','on');

end

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
