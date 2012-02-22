function value = get(obj,vname)
% get object variable

switch vname
  case {'resolution','res'}
    
    if obj.res >= 2*pi-0.001 && numel(obj)>4
      try
        a = calcVoronoiArea(obj);
        value = sqrt(mean(a));
        assert(value>0);
      catch
        value = obj.res;
      end
    else
      value = obj.res;
    end
    
  case 'theta'
    [theta,rho] = polar(obj); %#ok<NASGU>
    value = theta;
  case 'rho'
    [theta,rho] = polar(obj); %#ok<*ASGLU>
    value = rho;
  case fields(obj)
    value = [obj.(vname)];
  otherwise
    error('Unknown field in class S2Grid!')
end

