function varargout = get(obj,vname,varargin)
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
    case {'kappa','param','parameter'}
      varargout{1} = [obj.p1];
    case {'Fourier'}
      varargout{1} = obj.A;
      if check_option(varargin,'normalized')
        L = 0:length(obj.A)-1;
        varargout{1} = varargout{1} ./ (2*L+1);
      end
    otherwise
      error(['There is no ''' vname ''' property in the ''kernel'' object'])
  end
end

end
