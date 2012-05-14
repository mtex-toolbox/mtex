function varargout = scatter(v,varargin)
%
%% Syntax
%   scatter(v)              %
%   scatter(v,data)         %
%   scatter(v,text)
%
%% Input
%  v     - @vector3d
%  data  - double
%  rgb   - a list of rgb color values
%
%% Options
%  Marker            - 
%  MarkerFaceColor   -
%  MarkerEdgeColor   - 
%  MarkerColor       - shortcut for the above two
%  MarkerSize        - size of the markers in pixel
%  DynamicMarkerSize - scale marker size when plot is resized
%
%% Output
%
%% See also

%% plot prepertations

% where to plot
[ax,v,varargin] = getAxHandle(v,varargin{:});

% extract plot options
projection = plotOptions(ax,v,varargin{:});

% project data
[x,y] = project(v,projection);

% default arguments
patchArgs = {'Parent',ax,...
    'vertices',[x(:) y(:)],...
    'faces',1:numel(x),...
    'facecolor','none',...
    'edgecolor','none',...
    'marker','o',...
    };

% markerSize
res = get(v,'resolution');
res = get_option(varargin,'scatter_resolution',res);
MarkerSize  = get_option(varargin,'MarkerSize',min(8,50*res));
patchArgs = [patchArgs,{'MarkerSize',MarkerSize}];

% dynamic markersize
if check_option(varargin,'dynamicMarkerSize')
  patchArgs = [patchArgs {'tag','dynamicMarkerSize','UserData',MarkerSize}];
end

% annotations
annotations = {};

%% colorcoding according to the first argument
if numel(varargin) > 0 && isnumeric(varargin{1})
  
  % extract colorcoding
  cdata = varargin{1};
  if numel(cdata) == numel(v)
    cdata = reshape(cdata,[],1);
  else
    cdata = reshape(cdata,[],3);
  end
    
  % draw patches
  h = optiondraw(patch(patchArgs{:},...
    'facevertexcdata',cdata(p),...
    'markerfacecolor','flat',...
    'markeredgecolor','flat'),varargin{2:end});
  
  % add annotations for min and max
  if numel(cdata) == numel(v)
    annotations = {'BL',{'Min:',xnum2str(min(cdata(:)))},'TL',{'Max:',xnum2str(max(cdata(:)))}};
  end
  
  %% colorcoding according to nextStyle
else 
  
  % get color
  if check_option(varargin,{'MarkerColor','MarkerFaceColor'})
    mfc = get_option(varargin,'MarkerColor','none');
    mfc = get_option(varargin,'MarkerFaceColor',mfc);
  else % cycle through colors
    [ls,mfc] = nextstyle(gca,true,true,~ishold); %#ok<ASGLU>
  end
  mec = get_option(varargin,'MarkerEdgeColor',mfc);
  
  % draw patches
  h = optiondraw(patch(patchArgs{3:end},...
    'MarkerFaceColor',mfc,...
    'MarkerEdgeColor',mec),varargin{:});

end

%% finalize the plot

% plot a spherical grid
plotGrid(ax,projection,varargin{:});

% add annotations
plotAnnotate(ax,annotations,varargin{:})

% set resize function for dynamic marker sizes
if check_option(varargin,'dynamicMarkerSize')
  if isempty(get(gcf,'resizeFcn'))
    set(gcf,'resizeFcn',{@resizeScatter});
  end
end

% output
if nargout > 0
  varargout{1} = ax;
  varargout{2} = h;
else
  m = 0.025;
  set(ax,'units','normalized','position',[0+m 0+m 1-2*m 1-2*m]);
end

%% ---------------------------------------------------------------
function resizeScatter(fig, evt, a)

% scale scatterplots
u = findobj(fig,'Tag','dynamicMarkerSize');

if isempty(u), return;end

p = get(u(1),'parent');
unit = get(p,'unit');
set(p,'unit','pixel')
pos = get(p,'position');
l = min([pos(4)-pos(2),pos(3)-pos(1)]);

for i = 1:length(u)
  d = get(u(i),'UserData');
  o = get(u(i),'MarkerSize');
  n = l/350 * d;
  if abs((o-n)/o) > 0.1, set(u(i),'MarkerSize',n);end
end

set(p,'unit',unit);
