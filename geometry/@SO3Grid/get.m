function varargout = get(obj,vname,varargin)
% get object variable

switch lower(vname)
  case 'cs'
    varargout{1} = obj.CS;
  case 'ss'
    varargout{1} = obj.SS;
  case {'quaternion','grid'}
    varargout = {quaternion(obj)};
  case {'res','resolution'}
    varargout{1} = obj.resolution;
  case fields(obj)
    varargout{1} = obj.(vname);
  otherwise
    try
      varargout{1} = get(obj.orientation,vname,varargin{:});
    catch
      error(['There is no ''' vname ''' property in the ''' class(obj) ''' object'])
    end
end
