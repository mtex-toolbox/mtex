function varargout = subsref(S2G,varargin)
% overloads subsref

try
  % subindexing S2Grid is vector3d!!
  [varargout{1:nargout}] = subsref(vector3d(S2G),varargin{:});
catch %#ok<CTCH>
  [varargout{1:nargout}] = builtin('subsref',S2G,varargin{:});
end
