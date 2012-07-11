function varargout = text(v,varargin)
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

% extract text
strings = varargin{1};
varargin = varargin(2:end);

% special option -> labeled
if check_option(varargin,'labeled')
  
  strings = cell(1,numel(v));
  for i = 1:numel(v), strings{i} = char(subsref(v,i),getpref('mtex','textInterpreter')); end
    
  c = colormap;
  if ~all(equal(c,2)), varargin = [{'BackGroundColor','w'},varargin];end
  
else % ensure cell as input
  
  strings = ensurecell(strings);
  if numel(v)>1 && numel(strings)==1
    strings = repmat(strings,numel(v),1);
  end
  
end

% extract plot options
projection = getProjection(ax,v,varargin{:});

% project data
[x,y] = project(v,projection);


%% print labels
for i = 1:numel(strings)
  s = strings{i};
  if ~ischar(s), s = char(s,getpref('mtex','textInterpreter'));end
  h(end+1) = smarttext(x(i),y(i),s,projection.bounds,'Margin',0.1,'parent',ax,varargin{2:end}); %#ok<AGROW>
end

%% finalize the plot

% plot a spherical grid
plotGrid(ax,projection,varargin{:});

% output
if nargout > 0
  varargout{1} = ax;
  varargout{2} = h;
end
