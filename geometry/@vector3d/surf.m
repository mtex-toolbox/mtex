function varargout = surf(v,varargin)
%
% Syntax
%
% Input
%
% Output
%
% Options
%
% See also
%

% get input

% where to plot
[ax,v,varargin] = splitNorthSouth(v,varargin{:},'surf');
if isempty(ax), return;end

% extract plot options
[projection,extend] = getProjection(ax,v,varargin{:});

% why should I do this?
hfig = get(ax,'parent');
set(hfig,'color',[1 1 1]);

% extract colors 
cdata = varargin{1};

set(gcf,'renderer','zBuffer');
shading interp

% draw surface

hold(ax,'on')
    
% project data
[x,y] = project(v,projection,extend,'removeAntipodal');
    
% extract non nan data
ind = ~isnan(x);
x = submatrix(x,ind);
y = submatrix(y,ind);
data = reshape(submatrix(cdata,ind),[size(x) 3]);
     
% plot surface
h = surf(ax,x,y,zeros(size(x)),real(data));
    
hold(ax,'off')

% set styles
optiondraw(h,'LineStyle','none','Fill','on',varargin{:});


%-------- finalize the plot ---------------------------

% plot polar grid
plotGrid(ax,projection,extend,varargin{:});

% plot annotations
plotAnnotate(ax,varargin{:})

% output
if nargout > 0
  varargout{1} = h;
end

