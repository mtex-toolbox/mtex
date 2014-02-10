function varargout = get(obj,vname,varargin)
% get object variable
%
% Syntax
%   get(v,'x')
%   get(v,'y')
%   get(v,'z')
%   get(v,'polar')
%   get(v,'polar angle')
%   get(v,'azimuth')
%   get(v,'latitude')
%
% Input
%  v - @vector3d
%
% Ouput
%
% See also:
%


% switch fieldnames
switch lower(vname)
  
  case 'bounds'
    
    varargout{1} =  0;    % minTheta
    varargout{2} =  pi;   % maxTheta
    varargout{3} =  0;    % minRho
    varargout{4} =  2*pi; % maxRho
   
    
end
