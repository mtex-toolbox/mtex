function varargout = text(v,strings,varargin)
%
%% Syntax
%   scatter(v,s)  %
%
%% Input
%  v  - @vector3d
%  s  - string
%
%% Options
%
%% Output
%
%% See also

%% plot prepertations

% where to plot
[ax,v,varargin] = getAxHandle(v,varargin{:});
h = [];

% extract plot options
projection = plotOptions(ax,v,varargin{:});

% project data
[x,y] = project(v,projection);

% ensure cell as input
strings = ensurecell(strings);
if numel(v)>1 && numel(strings)==1
  strings = repmat(strings,numel(v),1);
end

%% print labels
for i = 1:numel(strings)
  h(end+1) = smarttext(x(i),y(i),strings{i},projection.bounds,'Margin',0.1,varargin{2:end}); %#ok<AGROW>
end

%% finalize the plot

% plot a spherical grid
plotGrid(ax,projection,varargin{:});

% output
if nargout > 0
  varargout{1} = ax;
  varargout{2} = h;
else
  m = 0.025;
  set(ax,'units','normalized','position',[0+m 0+m 1-2*m 1-2*m]);
end
