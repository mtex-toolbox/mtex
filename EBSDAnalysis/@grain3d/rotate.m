function grains = rotate(grains,rot,varargin)
% rotate grains
%
% Syntax
%
%   % rotate about the x-axis
%   grains = rotate(grains,rotation.byAxisAngle(xvector,180*degree)) 
%
%   % rotate about a specific point
%   grains = rotate(grains,rotation.byAxisAngle(xvector,180*degree) ...
%     ,'center',vector3d(0,0,0))
%
% Input
%  grains- @grain3d
%  rot   - @rotation
%
% Options
%  center - @vector3d, center of rotation, default is (0,0,0)
%
% Flags
%  keepXY    - rotate only the orientation data, i.e. the Euler angles
%  keepEuler - rotate only the spatial data, i.e., the x,y, and z values
%
% Output
%  grains - @grain3d

% rotate the orientations
if ~check_option(varargin,'keepEuler')
  grains.prop.meanRotation = rot .* grains.prop.meanRotation;
end

% rotate the spatial data
if ~check_option(varargin,'keepXY')

  % the center of rotation
  center = get_option(varargin,'center',vector3d(0,0,0));
  if ~isa(center,'vector3d'); error('center has to be a @vector3d'); end

  % rotate vertices
  grains.allV = center + rot .* (grains.allV - center);

end
