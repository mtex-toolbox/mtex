function varargout = get(obj,vname)
% get object variable
%
%% Syntax
%   get(v,'x')
%   get(v,'y')
%   get(v,'z')
%   get(v,'polar')
%   get(v,'polar angle')
%   get(v,'azimuth')
%   get(v,'latitude')
%
%% Input
%  v - @vector3d
%
%% Ouput
%
%% See also:
%

%% no vname - return list of all fields
if nargin == 1
	vnames = get_obj_fields(obj(1));
  vnames = [vnames;{'hkl';'h';'k';'l';'i';'rho';'theta';'polar';'x';'y';'z'}];
  if nargout, varargout{1} = vnames; else disp(vnames), end
  return
end

%% switch fieldnames
switch lower(vname)

  case 'x'
    
    varargout{1} = obj.x;
    
  case 'y'
    
    varargout{1} = obj.y;
    
  case 'z'
    
    varargout{1} = obj.z;
    
  case {'rho','azimuth','longitude'}
    
    [theta,rho] = polar(obj); %#ok<ASGLU>
    varargout{1} = rho;
    
  case {'theta','polar angle','colatitude'}
          
    theta = polar(obj);
    varargout{1} = theta;
    
  case 'latitude'
    
    theta = polar(obj);
    varargout{1} = pi/2 - theta;
    
  case 'polar'
    
    [varargout{1:nargout}] = polar(obj);    
    
  otherwise
    
    varargout{1} = obj.(vname);
    
end
