function varargout = patchPatala(v,varargin)
%
%% Syntax
%
%% Input
%
%% Output
%
%% Options
%
%% See also
%

%% get input

[ax,v,varargin] = getAxHandle(v,varargin{:});
ax = ax{1};

%% draw surface

axes(ax)
varargin{1}(v)

plotAnnotate(ax,varargin{:})

% output
if nargout > 0
  varargout{1} = h;
end

