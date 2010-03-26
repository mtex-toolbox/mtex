function varargout = get(obj,vname)
% get object variable

if nargin == 1
  vnames = get_obj_fields(obj(1));
  if nargout, varargout{1} = vnames; else disp(vnames), end
else

if any(strcmp(fields(obj),vname))
  varargout{1} = [obj.(vname)];
else
  switch vname
    case {'hw','halfwidth'}
      varargout{1} = [obj.hw];
    otherwise
      error(['There is no ''' vname ''' property in the ''kernel'' object'])
  end
end

end