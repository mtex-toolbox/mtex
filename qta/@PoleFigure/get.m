function varargout = get(obj,vname,varargin)
% get object variable

switch vname
  case {'SS','CS','comment','options'}
    varargout{1} = obj(1).(vname);
  case {'data','intensities'}
    varargout{1} = getdata(obj);
  case 'r'
    if nargout == 1
      varargout{1} = [obj.r];
    else
      varargout = {obj.r};
    end  
  case fields(obj)
    varargout{1} = [obj.(vname)];
  case {'theta','polar'}
    varargout{1} = getTheta(getr(obj));
  case {'rho','azimuth'}
    varargout{1} = getRho(getr(obj));
  case {'Miller','h','crystal directions'}
    varargout{1} = getMiller(obj);
  case fields(obj(1).options)
    varargout{1} = [];
    for i = 1:length(obj)
      varargout{1} = [varargout{1};reshape(obj(i).options.(vname),[],1)]; %#ok<AGROW>
    end
  otherwise
    error('Unknown property of class PoleFigure')
end
