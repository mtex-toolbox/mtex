function tP = rotate(tP,rot,varargin)
% rotate triple points
%
% Syntax
%
%   % rotate the tP about the z-axis by 90*degree
%   tP = rotate(tP,10*degree) 
%
%   % rotate about the x-axis
%   tP = rotate(tP,rotation.byAxisAngle(xvector,180*degree)) 
%
%   % rotate about a specific point
%   tP = rotate(tP,180*degree,'center',vector3d(20,10,0))
%
% Input
%  tP- @triplePointList
%  angle - double
%  rot   - @rotation
%
% Options
%  center - center of rotation - @vector3d
%
% Flags
%  keepXY    - rotate only the orientation data, i.e. the Euler angles
%  keepEuler - rotate only the spatial data, i.e., the x,y, and z values
%
% Output
%  tP - @triplePointList

if isa(rot,'double'), rot = rotation.byAxisAngle(vector3d.Z,rot); end

center = get_option(varargin,'center',vector3d.zeros);
    
% rotate vertices
tP.V = center + rot * (tP.V - center);

% rotate normal direction
tP.N = rot * tP.N;

end
