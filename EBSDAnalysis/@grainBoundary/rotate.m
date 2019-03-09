function gB = rotate(gB,rot,varargin)
% rotate grainBoundaries
%
% Syntax
%
%   % rotate the gB about the z-axis by 90*degree
%   gB = rotate(gB,10*degree) 
%
%   % rotate about the x-axis
%   gB = rotate(gB,rotation.byAxisAngle(xvector,180*degree)) 
%
%   % rotate about a specific point
%   gB = rotate(gB,180*degree,'center',[0,0])
%
% Input
%  gB- @grainBoundary
%  angle - double
%  rot   - @rotation
%
% Options
%  center - [x,y] center of rotation, default is center of the gB
%
% Flags
%  keepXY    - rotate only the orientation data, i.e. the Euler angles
%  keepEuler - rotate only the spatial data, i.e., the x,y, and z values
%
% Output
%  gB - @grainBoundary

if isa(rot,'double'), rot = rotation.byAxisAngle(vector3d.Z,rot); end

center = get_option(varargin,'center',[0,0]);
  
gB = gB - center;
  
% store coordinates as vector3d
V = vector3d(gB.V(:,1),gB.V(:,2),0);
  
% rotate vertices
V = rot * V;
    
% store back
gB.V = [V.x,V.y];
  
gB = gB + center;

end
