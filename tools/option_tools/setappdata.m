function varargout = setappdata(ax,varargin)
% make setappdata work with multiple handles

for a = ax(:).'
  [varargout{1:nargout}] = builtin('setappdata',a,varargin{:}); 
end