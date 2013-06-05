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

%% plot preperations


% where to plot
[ax,v,varargin] = splitNorthSouth(v,varargin{:},'scatter');
if isempty(ax), return;end

% extract plot options
[projection,extend] = getProjection(ax,v,varargin{:});

% project data
[x,y] = project(v,projection,extend);

% annotations
annotations = {};

% check that there is something left to plot
if all(isnan(x) | isnan(y))
  if nargout > 0
    varargout{1} = [];
    varargout{2} = [];
    h = [];
  end
else

  % default arguments
  patchArgs = {'Parent',ax,...
    'vertices',[x(:) y(:)],...
    'faces',1:numel(x),...
    'facecolor','none',...
    'edgecolor','none',...
    'marker','o',...
    };

  % markerSize
  res = max(get(v,'resolution'),1*degree);
  res = get_option(varargin,'scatter_resolution',res);  
  MarkerSize  = get_option(varargin,'MarkerSize',min(8,50*res));
  patchArgs = [patchArgs,{'MarkerSize',MarkerSize}];

  % dynamic markersize
  if check_option(varargin,'dynamicMarkerSize') || ...
      (~check_option(varargin,'MarkerSize') && numel(v)>20)
    patchArgs = [patchArgs {'tag','dynamicMarkerSize','UserData',MarkerSize}];
  end
   
  %% colorcoding according to the first argument
  if numel(varargin) > 0 && isnumeric(varargin{1}) && ~isempty(varargin{1})
  
    % extract colorpatchArgs{3:end}coding
    cdata = varargin{1};
    if numel(cdata) == numel(v)
      cdata = reshape(cdata,[],1);
    else
      cdata = reshape(cdata,[],3);
    end
    
    % draw patches
    h = optiondraw(patch(patchArgs{:},...
      'facevertexcdata',cdata,...
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
      [ls,mfc] = nextstyle(ax,true,true,~ishold(ax)); %#ok<ASGLU>
    end
    mec = get_option(varargin,'MarkerEdgeColor',mfc);
  
    % draw patches
    h = optiondraw(patch(patchArgs{:},...
      'MarkerFaceColor',mfc,...
      'MarkerEdgeColor',mec),varargin{:});

  end
end

%% finalize the plot

% plot a spherical grid
plotGrid(ax,projection,extend,varargin{:});

% add annotations
plotAnnotate(ax,annotations{:},varargin{:})


% set resize function for dynamic marker sizes
hax = handle(ax);
hListener(1) = handle.listener(hax, findprop(hax, 'Position'), ...
  'PropertyPostSet', {@localResizeScatterCallback,ax});
% save listener, otherwise  callback may die
setappdata(hax, 'dynamicMarkerSizeListener', hListener);

% %if check_option(varargin,'dynamicMarkerSize')
%   setappdata(gcf,'dynamicMarkerSize',@resizeScatter);
%   if isempty(get(gcf,'resizeFcn'))
%     set(gcf,'resizeFcn',@callResizeScatter);
%   end
%end

% output
if nargout > 0
  varargout{1} = ax;
  varargout{2} = h;
end


%% -----------------------------------------------
function localResizeScatterCallback(h,e,hax)
% get(fig,'position')

hax = handle(hax);

%% adjust label positions
t = findobj(hax,'Tag','addMarkerSpacing');

% get markerSize
markerSize = get(findobj(hax,'type','patch'),'MarkerSize');
if isempty(markerSize)
  markerSize = 0;
elseif iscell(markerSize)
  markerSize = [markerSize{:}];
end

markerSize = max(markerSize);


for it = 1:numel(t)
  
  xy = get(t(it),'UserData');
  set(t(it),'unit','data','position',[xy,0]);
  set(t(it),'unit','pixels');
  xy = get(t(it),'position');
  if isappdata(t(it),'extent')
    extend = getappdata(t(it),'extent');
  else
    extend = get(t(it),'extent');
    setappdata(t(it),'extent',extend);
  end
  margin = get(t(it),'margin');
  xy(2) = xy(2) - extend(4)/2 - margin - markerSize/2 + 2;
  if isnumeric(get(t(it),'BackgroundColor')), xy(2) = xy(2) - 5;end
  set(t(it),'position',xy);
  set(t(it),'unit','data');
  %get(t(it),'position')
end

%% scale scatterplots
u = findobj(hax,'Tag','dynamicMarkerSize');

if isempty(u), return;end

p = get(u(1),'parent');
unit = get(p,'unit');
set(p,'unit','pixel')
pos = get(p,'position');
l = min([pos(3),pos(4)]);

for i = 1:length(u)
  d = get(u(i),'UserData');
  o = get(u(i),'MarkerSize');
  %n = l/350 * d;
  n = l/250 * d;
  if abs((o-n)/o) > 0.05, set(u(i),'MarkerSize',n);end
end

set(p,'unit',unit);

