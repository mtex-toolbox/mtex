function varargout = get(obj,vname,varargin)
% get object variable

%% no vname - return list of all fields
if nargin == 1
	vnames = get_obj_fields(obj(1));
  vnames = [vnames;{'hkl';'h';'k';'l';'i';'rho';'theta';'polar';'x';'y';'z'}];
  if nargout, varargout{1} = vnames; else disp(vnames), end
  return
end

%% switch fieldnames
switch lower(vname)

  case {'hkl','h','k','l','i'}
 
    varargout{1} = v2m(obj);
   
    switch lower(vname)
        
      case 'h', varargout{1} = varargout{1}(:,1);
      case 'k', varargout{1} = varargout{1}(:,2);
      case 'l', varargout{1} = varargout{1}(:,end);
      case 'i'
        if size(varargout{1},2) == 4
          varargout{1} = varargout{1}(:,3);
        else
          varargout{1} = [];
        end
    end
  
  case {'uvw','u','v','w','t'}
    
    varargout{1} = v2d(obj);
    
    switch lower(vname)
    
      case 'u', varargout{1} = varargout{1}(:,1);
      case 'v', varargout{1} = varargout{1}(:,2);
      case 'w', varargout{1} = varargout{1}(:,3);
      case 't'
        if size(varargout{1},2) == 4
          varargout{1} = varargout{1}(:,3);
        else
          varargout{1} = [];
        end
        
    end
    
  case 'cs'
    
    varargout{1} = obj.CS;
   
  case {'bounds','fundamentalregion'}
    
    if check_option(varargin,'fundamentalRegion') && ~check_option(varargin,'complete')
  
      % get fundamental region
      [minTheta,maxTheta,minRho,maxRho] = getFundamentalRegionPF(obj.CS,varargin{:});
      varargout{1} = minTheta;
      varargout{2} = maxTheta;
      varargout{3} = minRho;
      varargout{4} = maxRho;
      
    else
      
      [varargout{1:nargout}] = get(obj.vector3d,vname,varargin{:});
            
    end

  otherwise
    
    try
      [varargout{1:nargout}] = get(obj.vector3d,vname);
    catch %#ok<CTCH>
      error(['No such filed: ' vname])
    end
    
end
