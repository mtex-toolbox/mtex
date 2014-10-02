function varargout = patchPatala(v,varargin)
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


% draw surface
% TODO
axes(ax)
varargin{1}(v)

plotAnnotate(ax,varargin{:})

% output
if nargout > 0
  varargout{1} = h;
end

