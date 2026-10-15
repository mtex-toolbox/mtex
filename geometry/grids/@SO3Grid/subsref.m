function varargout = subsref(S3G,varargin)
% overloads subsref

try
  s = varargin{:};
  if strcmp(s.type,'.') && strcmp(s.subs,'gamma')
    [varargout{1:nargout}] = S3G.gamma;
    return
  end
end

try
  % subindexing SO3Grid is orientation!!
  [varargout{1:nargout}] = subsref(orientation(S3G),varargin{:});
catch %#ok<CTCH>
  [varargout{1:nargout}] = builtin('subsref',S3G,varargin{:});
end
