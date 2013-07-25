function varargout = plotCustom(v,pcmd,varargin)
%
%% Syntax
%   plotcustom(v,@(x,y) drawCommand(x,y))  %
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
[ax,v,pcmd,varargin] = splitNorthSouth(v,pcmd,varargin{:},'custom');
if isempty(ax), return;end
h = [];

% extract plot options
[projection,extend] = getProjection(ax,v,varargin{:});

% project data
[x,y] = project(v,projection,extend,varargin{:});

% plot a spherical grid
plotGrid(ax,projection,extend,varargin{:});

%% plot custom
for i = 1:length(x), pcmd{1}(ax,x(i),y(i)); end

%% finalize the plot

% output
if nargout > 0
  varargout{1} = ax;
  varargout{2} = h;
end
