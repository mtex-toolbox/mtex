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
%   tP = rotate(tP,180*degree,'center',[0,0])
%
% Input
%  tP- @triplePointList
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
%  tP - @triplePointList

if isa(rot,'double'), rot = rotation.byAxisAngle(vector3d.Z,rot); end

center = get_option(varargin,'center',[0,0]);
  
tP = tP - center;
  
% store coordinates as vector3d
V = vector3d(tP.V(:,1),tP.V(:,2),0);
  
% rotate vertices
V = rot * V;
    
% store back
tP.V = [V.x,V.y];
  
tP = tP + center;

end
