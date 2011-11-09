function ebsd = rotate(ebsd,q,varargin)
% rotate EBSD orientations or spatial data around point of origin
%
%% Input
%  ebsd - @EBSD
%  q    - @quaternion
%
%% Option
%  keepXY - do not rotate xy coordinates
%
%% Output
%  rotated ebsd - @EBSD

if isa(q,'double'), q = axis2quat(zvector,q); end

% rotate the orientations
ebsd.rotations = q .* ebsd.rotations;

% rotate the spatial data
if ~check_option(varargin,'keepXY')
  
  if isappr(dot(axis(q),zvector),1) 
    % rotation about z
    
    omega = dot(axis(q),zvector) * angle(q);
    A = [cos(omega) -sin(omega);sin(omega) cos(omega)];
    ebsd = affinetrans(ebsd,A);
    
  elseif isappr(angle(q),pi) && isnull(dot(axis(q),zvector)) 
    % rotation perpendicular to z
    
    [x y z] = double(axis(q)); %#ok<NASGU>
    omega = atan2(y,x);
    
    A = [cos(2*omega) sin(2*omega);sin(2*omega) -cos(2*omega)];
    ebsd = affinetrans(ebsd,A);
    
  else
    warning('MTEX:rotate',...
      'Spatial rotation of EBSD data is only supported for rotations about the z-axis. I''m going to rotate only the orientation data!');
  end
end
