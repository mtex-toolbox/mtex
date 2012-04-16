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
    
  case 'minrho'
    value = min(getMin(obj.rho));
  case 'maxrho'
    value = max(getMax(obj.rho));
  case 'mintheta'    
    m = obj.theta;
    if isa(m,'function_handle')
      value = 0;
    else
      value = min(getMin(m));
    end    
  case 'maxtheta'    
    value = obj.theta;
    if ~isa(value,'function_handle')
      value = max(getMax(value));
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

