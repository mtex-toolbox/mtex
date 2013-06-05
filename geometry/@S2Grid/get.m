function varargout = get(obj,vname,varargin)
% get object variable

switch lower(vname)
  case {'resolution','res'}
    
    if obj.res >= 2*pi-0.001 && numel(obj)>4
      try
        a = calcVoronoiArea(obj);
        varargout{1} = sqrt(mean(a));
        assert(value>0);
      catch
        varargout{1} = obj.res;
      end
    else
      varargout{1} = obj.res;
    end
    
  case 'bounds'
    
   varargout{1} =  get(obj,'minTheta');
   if isa(obj.theta,'function_handle')
     varargout{2} =  obj.theta;
   else
     varargout{2} =  get(obj,'maxTheta');
   end
   varargout{3} =  get(obj,'minRho');
   varargout{4} =  get(obj,'maxRho');
   
  case 'minrho'
    varargout{1} = min(getMin(obj.rho));
  case 'maxrho'
    varargout{1} = max(getMax(obj.rho));
  case 'mintheta'    
    m = obj.theta;
    if isa(m,'function_handle')
      varargout{1} = 0;
    else
      varargout{1} = min(getMin(m));
    end    
  case 'maxtheta'    
    varargout{1} = obj.theta;
    if ~isa(varargout{1},'function_handle')
      varargout{1} = max(getMax(varargout{1}));
    end    
  case 'theta'
    [theta,rho] = polar(obj); %#ok<NASGU>
    varargout{1} = theta;
  case 'rho'
    [theta,rho] = polar(obj); %#ok<*ASGLU>
    varargout{1} = rho;
  case fields(obj)
    varargout{1} = [obj.(vname)];
  otherwise
    error('Unknown field in class S2Grid!')
end

