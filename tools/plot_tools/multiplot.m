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

%% prepare plot

% generate some invisible axes
for k=1:nplots, a(k) = axes('visible','off'); end %#ok<AGROW>


%% extract data
if nargin>=2 && isa(varargin{2},'function_handle')
  data = cell(nplots,1);
  for k = 1:nplots
    data{k} = feval(varargin{2},k);
  end
  varargin(2) = []; %remove argument

  % for equal colorcoding determine min and max of data 
  if check_option(varargin,'colorRange',[],'equal')
    minData = nanmin(cellfun(@(x) nanmin(x(:)),data));
    maxData = nanmax(cellfun(@(x) nanmax(x(:)),data));
    
    % set colorcoding explicitly 
    varargin = set_option(varargin,'colorRange',[minData maxData]);
  end  
else
  data = [];
end

%% make plots
efun = find(cellfun('isclass',varargin,'function_handle'));
nfun = numel(efun);

for k=1:nplots
  targin = varargin;
  for kfun = 1:nfun
    targin{efun(kfun)} = feval(varargin{efun(kfun)},k);
  end
  
  % reinsert data
  if ~isempty(data), targin = {targin{1},data{k},targin{2:end}};end
  
  plot(a(k),targin{:});
end

%% invisible axes for adding a colorbar
if ~isappdata(gcf,'colorbaraxis')
  d = axes('visible','off','position',[0 0 1 1],...
    'tag','colorbaraxis');
  
  ch = get(gcf,'children');
  
  set(gcf,'children',[ch(ch ~= d);ch(ch == d)]);
  set(d,'HandleVisibility','callback');
  
  setappdata(gcf,'colorbaraxis',d);
end

%% post process figure

% make axes visible
for k=1:nplots, set(a(k),'visible','on'); end

set(gcf,'ResizeFcn',@(src,evt) figResize(src,evt,a));
%set(gcf,'Position',get(gcf,'Position'));
setappdata(gcf,'autofit','on');
setappdata(gcf,'border',10);
setappdata(gcf,'marginx',0);
setappdata(gcf,'marginy',0);
figResize(gcf,[],a);

 
end
%% ================== private functions =========================

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
