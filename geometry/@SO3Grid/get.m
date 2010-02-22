function varargout = get(obj,vname,varargin)
% get object variable

switch lower(vname)
  case {'cs','ss'}
    varargout = {obj.(vname)};
  case {'quaternion','grid','orientation'}
    varargout = {quaternion(obj)};
  case {'res','resolution'}
    varargout{1} = obj.res;
  case fields(obj)
    varargout = obj.(vname);
  otherwise
    error('Unknown field in class SO3Grid!')
end
