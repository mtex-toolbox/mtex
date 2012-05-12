function varargout = text(v,s,varargin)
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

% extract plot options
projection = plotOptions(ax,v,varargin{:});
bounds = [-1 -1 2 2];

% project data
[x,y,hemi,p] = project(v,projection); %#ok<ASGLU>

% print labels
for i = 1:numel(varargin{1})
  smarttext(x(i),y(i),varargin{1}{i},bounds,'Margin',0.1,varargin{2:end});
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
