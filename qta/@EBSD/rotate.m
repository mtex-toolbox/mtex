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

for i = 1:length(ebsd)  
  ebsd(i).orientations = q * ebsd(i).orientations;
end

if ~check_option(varargin,'keepXY')
  if abs(dot(rotaxis(q),zvector)) > 1-1e-10
    omega = dot(rotaxis(q),zvector) * angle(q);
    A = [cos(omega) -sin(omega);sin(omega) cos(omega)];
    ebsd = affinetrans(ebsd,A);
  else
    warning('MTEX:rotate',...
      'Spatial rotation of EBSD data is only supported for rotations about the z-axis. I''m going to rotate only the orientation data!');
  end
end
