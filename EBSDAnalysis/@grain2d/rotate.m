function grains = rotate(grains,rot,varargin)
% rotate grains
%
% Syntax
%
%   % rotate the grains about the z-axis by 90*degree
%   grains = rotate(grains,10*degree) 
%
%   % rotate about the x-axis
%   grains = rotate(grains,rotation.byAxisAngle(xvector,180*degree)) 
%
%   % rotate about a specific point
%   grains = rotate(grains,180*degree,'center',[0,0])
%
% Input
%  grains- @grain2d
%  angle - double
%  rot   - @rotation
%
% Options
%  center - [x,y] center of rotation, default is (0,0)
%
% Flags
%  keepXY    - rotate only the orientation data, i.e. the Euler angles
%  keepEuler - rotate only the spatial data, i.e., the x,y, and z values
%
% Output
%  grains - @grain2d

if isa(rot,'double'), rot = rotation.byAxisAngle(vector3d.Z,rot); end

% rotate the orientations
if ~check_option(varargin,'keepEuler')
  grains.prop.meanRotation = quaternion(rot .* grains.prop.meanRotation);
end

% rotate the spatial data
if ~check_option(varargin,'keepXY')
  
  center = get_option(varargin,'center',[0,0]);
  
  grains = grains - center;
  
  % store coordinates as vector3d
  V = vector3d(grains.V(:,1),grains.V(:,2),0);
  
  % rotate vertices
  V = rot * V;
    
  % store back
  grains.V = [V.x(:),V.y(:)];
  
  grains = grains + center;
  
end
