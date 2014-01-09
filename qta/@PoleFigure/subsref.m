function varargout = subsref(varargin)
% overloads subsref

try
  [varargout{1:nargout}] = builtin('subsref',varargin{:});  
catch
  [varargout{1:nargout}] = subsref@dynOption(varargin{:});
end

end
