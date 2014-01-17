function varargout = get(obj,vname,varargin)
% get object variable

switch lower(vname)
  case {'resolution','res'}
    
    if obj.res >= 2*pi-0.001 && length(obj)>4
      try
        a = calcVoronoiArea(obj);
        varargout{1} = sqrt(mean(a));
        assert(varargout{1}>0);
      catch
        varargout{1} = obj.res;
      end
    else
      varargout{1} = obj.res;
    end
    
  case 'bounds'
    
   varargout{1} =  get(obj,'minTheta');
   if isa(obj.thetaGrid,'function_handle')
     varargout{2} =  obj.thetaGrid;
   else
     varargout{2} =  get(obj,'maxTheta');
   end
   varargout{3} =  get(obj,'minRho');
   varargout{4} =  get(obj,'maxRho');
   
  case 'minrho'
    varargout{1} = min([obj.rhoGrid.min]);
  case 'maxrho'
    varargout{1} = max([obj.rhoGrid.max]);
  case 'mintheta'    
    if isa(obj.thetaGrid,'function_handle')
      varargout{1} = 0;
    else
      varargout{1} = min([obj.thetaGrid.min]);
    end    
  case 'maxtheta'    
    varargout{1} = obj.thetaGrid;
    if ~isa(varargout{1},'function_handle')
      varargout{1} = max([obj.thetaGrid.max]);
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

