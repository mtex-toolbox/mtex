function varargout = get(obj,vname,varargin)
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
  
  case 'bounds'
    
    varargout{1} =  0;    % minTheta
    varargout{2} =  pi;   % maxTheta
    varargout{3} =  0;    % minRho
    varargout{4} =  2*pi; % maxRho
   
  case {'resolution','res'}
    
    varargout{1} = 2*pi; % default to 2*pi
    
    if numel(obj)>50000
      varargout{1} = sqrt(4*pi/numel(obj));
    elseif numel(obj)>4
      try %#ok<TRYNC>
        a = calcVoronoiArea(S2Grid(obj));
        assert(sqrt(mean(a))>0);
        varargout{1} = median(sqrt(a));
      end
    end
    
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
