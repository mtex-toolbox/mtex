function v = volume(odf,center,radius,varargin)
% ratio of orientations with a certain orientation
%
% Description
% The function 'volume' returns the ratio of an orientation that is close
% to an orientation (center) by a misorientation tolerance (radius) to the
% volume of the entire odf.
%
% Syntax
%   v = volume(odf,center,radius)
%   v = volume(odf,fibre,radius) % gives the volume with a fibre
%
% Input
%  odf    - @ODF
%  center - @orientation
%  fibre  - @fibre
%  radius - double
%
% Options
%  resolution - resolution of discretization
%
% See also
% ODF/fibreVolume ODF/entropy ODF/textureindex

if isa(center,'fibre')
  v = fibreVolume(odf,center.h,center.r,radius,varargin{:});
  return
end


% check input
argin_check(center,'quaternion');
argin_check(radius,'double');

v = 0;
S3G = [];

% cycle through components
for i = 1:length(odf.components)
  
  [iv,S3G] = volume(odf.components{i},center,radius,S3G,varargin{:});
  v = v + odf.weights(i) * iv;
  
end

end
