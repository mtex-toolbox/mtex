function varargout = subsref(SO3G,varargin)
% overloads subsref

try
  % subindexing SO3Grid is orientation!!
  [varargout{1:nargout}] = subsref(orientation(SO3G),varargin{:});
catch %#ok<CTCH>
  [varargout{1:nargout}] = builtin('subsref',SO3G,varargin{:});
end
