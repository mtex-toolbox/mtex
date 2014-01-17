function varargout = subsref(S3G,varargin)
% overloads subsref

try
  [varargout{1:nargout}] = subsref(orientation(S3G),varargin{:});
catch %#ok<CTCH>
  [varargout{1:nargout}] = builtin('subsref',S3G,varargin{:});
end
