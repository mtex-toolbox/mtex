function ebsd = rotate(ebsd,rot,varargin)
% rotate EBSD 
%
% Syntax
%
%   % roate the whoole data set about the z-axis by 90*degree
%   ebsd = rotate(ebsd,10*degree) 
%
%   % rotate about the x-axis
%   ebsd = rotate(ebsd,rotation.byAxisAngle(xvector,180*degree)) 
%   
%   % rotate only the spatial data
%   ebsd = rotate(ebsd,180*degree,'keepEuler')
%
%   % rotate about a specific point
%   ebsd = rotate(ebsd,180*degree,'center',[0,0])
%
% Input
%  ebsd - @EBSD
%  angle - double
%  q    - @rotation
%
% Options
%  center - [x,y] center of rotation, default is (0,0)
%
% Flags
%  keepXY    - rotate only the orientation data, i.e. the Euler angles
%  keepEuler - rotate only the spatial data, i.e., the x,y, and z values
%
% Output
%  ebsd - @EBSD

if isa(rot,'double'), rot = rotation.byAxisAngle(zvector,rot); end

% rotate the orientations
if ~check_option(varargin,'keepEuler')
  ebsd.rotations = rotation(rot .* ebsd.rotations);
end

% rotate the spatial data
if ~check_option(varargin,'keepXY')
  
  center = get_option(varargin,'center',[0,0]);
  
  ebsd = ebsd - center;
  
  % store coordinates as vector3d
  V = vector3d(ebsd.prop.x,ebsd.prop.y,0);
  
  % rotate vertices
  V = rot * V;

  % store back
  ebsd.prop.x = V.x(:);
  ebsd.prop.y = V.y(:);
    
  ebsd = ebsd + center;
  
  % rotate the unitcell
  V = vector3d(ebsd.unitCell(:,1),ebsd.unitCell(:,2),0);
  V = rot * V;
  ebsd.unitCell = [V.x(:),V.y(:)];
end
