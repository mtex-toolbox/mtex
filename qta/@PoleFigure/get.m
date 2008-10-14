function value = get(obj,vname)
% get object variable

switch vname
  case fields(obj)
    value = obj.(vname);
  case {'theta','polar'}
    value = gettheta(getr(obj));
  case {'rho','azimuth'}
    value = getrho(getr(obj));
  case {'Miller','h','crystal directions'}
    value = getMiller(obj);
  otherwise
    error('Unknown property of class PoleFigure')
end
