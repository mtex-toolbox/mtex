function multiplot(nplots,varargin)
% plot multiple graphs
%
%% Syntax
%  multiplot(x,y,nplots,'FONTSIZE',fontsize)
%  multiplot(x,y,nplots,'COLORCODING','equal')
%  multiplot(x,y,nplots,'COLORCODING',[cmin cmax])
%  multiplot(x,y,nplots,'ANOTATION',string)
%
%% Input
%  x      - grid (@S1Grid, @S2Grid, @SO3Grid)
%  y      - vector of plot data
%  nplots - number of plots
%
%% Options
%  [cmin cmax] - minimum and maximum value for color coding
%  fontsize    - fontsize used for anotations
%  string      - some anotation to be added to the plot
%  marginx     - 
%  marginy     -
%  border      -
%  MINMAX      - display minimum and maximum 
%
%% Flags
%  uncroppped  - do not resize window for a cropped plot
%  SILENT      - no output
%
%% See also
% S2Grid/plot savefigure   


for k=1:nplots  
  a(k) = axes('visible','off');  
end

% check_option(varargin,{'scatter','smooth','contour','contourf','line'})
    
plot_type = get_flag(varargin,{'scatter','smooth','contour','contourf','line','plot'},'scatter');
% plot_type
varargin = delete_option(varargin,plot_type,0);
    
efun = find(cellfun('isclass',varargin,'function_handle'));
nfun = numel(efun);

for k=1:nplots
  targin = varargin;
  for kfun = 1:nfun
     targin{efun(kfun)} = feval(varargin{efun(kfun)},k);
  end
  feval(plot_type,a(k),targin{:});
end

for k=1:nplots

  set(a(k),'visible','on');  
end

 set(gcf,'ResizeFcn',@(src,evt) figResize(src,evt,a));
  %set(gcf,'Position',get(gcf,'Position'));
  setappdata(gcf,'autofit','on');
  setappdata(gcf,'border',10);
  setappdata(gcf,'marginx',0);
  setappdata(gcf,'marginy',0);
  figResize(gcf,[],a);


return

end
%% ================== private functions =========================


%% disp anotation in subfigures
function anotation(a,mini,maxi,ref,varargin)
mini = xnum2str(mini,ref/10);
maxi = xnum2str(maxi,ref);

set(a,'units','points');
apos = get(a,'Position');

optiondraw(text(1,3,{'min:',mini},'FontName','times','Interpreter','tex',...
  'HorizontalAlignment','Left','VerticalAlignment','bottom',...
  'units','points','tag','minmax'),varargin{:});

optiondraw(text(apos(3)-1,3,{'max:',maxi},'FontName','times','Interpreter','tex',...
  'HorizontalAlignment','Right','VerticalAlignment','bottom',...
  'units','points','Tag','minmax'),varargin{:});

end

%% resize figure and reorder subfigs


function figResize(fig,evt,a) %#ok<INUSL,INUSL>

old_units = get(fig,'Units');
set(fig,'Units','pixels');

if strcmp(getappdata(fig,'autofit'),'on')

  figpos = get(fig,'Position');
  
  marginx = getappdata(fig,'marginx');
  marginy = getappdata(fig,'marginy');
  border = getappdata(fig,'border');


  figpos(4) = figpos(4)-2*border;
  figpos(3) = figpos(3)-2*border;
  dxdy = get(a(1),'PlotBoxAspectRatio');
  dxdy = dxdy(2)/dxdy(1);
  [nx,ny,l] = bestfit(figpos(3),figpos(4),dxdy,length(a),marginx,marginy);
  set(fig,'UserData',[nx*l+2*border+(nx-1)*marginx,...
    ny*l*dxdy+2*border+(ny-1)*marginy]);
  setappdata(fig,'length',l); 
 
  l = ceil(l);
  ldxdy = ceil(l*dxdy); 
  for i = 1:length(a)
    [px,py] = ind2sub([nx ny],i);
    apos = [1+border+(px-1)*(l+marginx),...
      1+border+figpos(4)-py*ldxdy-(py-1)*(marginy-1),...
      l,ldxdy];
    set(a(i),'Units','pixels','Position',apos);
  end
  
  % resize colorbaraxis
  set(getappdata(fig,'colorbaraxis'),'units','pixel','position',[border,border,figpos(3:4)]);
end

scalescatterplots(fig);
  
% set position of labels
u = findobj(fig,'Tag','minmax','HorizontalAlignment','Right');
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
  o = get(u(i),'MarkerSize');
  n = l*d/5;
  if abs((o-n)/o) > 0.1, set(u(i),'MarkerSize',n);end
end

end

%% determine best alignment of subfigures
function [bx,by,l] = bestfit(dx,dy,dxdy,n,marginx,marginy)

% length in x direction
lx = @(nx,ny) min((dx-(nx-1)*marginx)/nx,...
  (dy-(ny-1)*marginy)/dxdy/ny);

by = 1; bx = n;
l = lx(bx,by);

if n == 1, return;end

for ny=2:n
  nx = ceil(n/ny);
  if lx(nx,ny) > l % new best fit
    l = lx(nx,ny);
    bx = nx;
    by = ny;
  end
end
end



%% Callbacks for syncing 3d rotations

function mypostcallback(obj,evd) %#ok<INUSL>

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
