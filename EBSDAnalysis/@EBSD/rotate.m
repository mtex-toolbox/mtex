function ebsd = rotate(ebsd,rot,varargin)
% rotate EBSD maps
%
% Syntax
%
%   % rotate EBSD map about the z-axis by 10*degree
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

  % remove any grid
  ebsd = EBSD(ebsd);

  % the center of rotation
  center = get_option(varargin,'center',vector3d(0,0,0));
  if ~isa(center,'vector3d'), center = vector3d(center(1),center(2),0); end

  % rotate positions
  ebsd.pos = reshape(center + rot * (ebsd.pos - center),[],1);

  % rotate normal direction
  ebsd.N = rot * ebsd.N;

  % rotate the unitcell
  ebsd.unitCell = rot .* ebsd.unitCell;
end
