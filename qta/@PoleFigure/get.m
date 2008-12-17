function value = get(obj,vname)
% get object variable

switch vname
  case {'CS','SS','comment','options'}
    value = obj(1).(vname);
  case {'data','intensities'}
    value = getdata(obj);
  case fields(obj)
    value = [obj.(vname)];
  case {'theta','polar'}
    value = getTheta(getr(obj));
  case {'rho','azimuth'}
    value = getRho(getr(obj));
  case {'Miller','h','crystal directions'}
    value = getMiller(obj);
  otherwise
    error('Unknown property of class PoleFigure')
end
