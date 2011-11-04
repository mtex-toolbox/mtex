function value = get(obj,vname)
% get object variable

switch vname
  case {'resolution','res'}
    
    if obj.res >= 2*pi-0.001 && numel(obj)>4
      a = calcVoronoiArea(obj);
      value = sqrt(mean(a));
    else
      value = obj.res;
    end
    
  case 'theta'
    [theta,rho] = polar(obj);
    value = theta;
  case 'rho'
    [theta,rho] = polar(obj);
    value = rho;
  case fields(obj)
    value = [obj.(vname)];
  otherwise
    error('Unknown field in class S2Grid!')
end

