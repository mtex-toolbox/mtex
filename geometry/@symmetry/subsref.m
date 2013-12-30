function varargout = subsref(sym,varargin)
% overloads subsref

try
  [varargout{1:nargout}] = subsref(rotation(sym),varargin{:});
catch %#ok<CTCH>
  [varargout{1:nargout}] = builtin('subsref',sym,varargin{:});
end



