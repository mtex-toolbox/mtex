function varargout = get(obj,vname,varargin)
% get object variable

switch lower(vname)  
  case {'euler'}
    [varargout{1:nargout}] = Euler(obj,varargin{:});
  case {'rodrigues'}
    [varargout{1:nargout}] = Euler(obj,varargin{:});
  case fields(obj)
    varargout{1} = obj.(vname);
  case 'a'
    varargout{1} = obj.a;
  case 'b'
    varargout{1} = obj.b;
  case 'c'
    varargout{1} = obj.c;
  case 'd'
    varargout{1} = obj.d;
  case 'real'
    varargout{1} = obj.a;    
  case 'angle'
    varargout{1} = 2*acos(obj.a);
  case {'axis','rotaxis'}
    varargout{1} = rotaxis(obj);
  otherwise
    error('Unknown field in class quaternion!')
end

