function varargout = get(obj,vname)
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
  
  case {'resolution','res'}
    
    varargout{1} = 2*pi; % default to 2*pi
    
    if numel(obj)>4
      try %#ok<TRYNC>
        a = calcVoronoiArea(S2Grid(obj));
        assert(sqrt(mean(a))>0);
        varargout{1} = sqrt(mean(a));
      end
    end
    
  case 'x'
    
    varargout{1} = obj.x;
    
  case 'y'
    
    varargout{1} = obj.y;
    
  case 'z'
    
    varargout{1} = obj.z;
    
  case 'rho'
    
    [theta,rho] = polar(obj); %#ok<ASGLU>
    varargout{1} = rho;
    
  case 'theta'
    
    theta = polar(obj);
    varargout{1} = theta;
    
  case 'polar'
    
    [varargout{1:nargout}] = polar(obj);    
    
  otherwise
    
    varargout{1} = obj.(vname);
    
end
