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
%  odf    - @SO3Fun
%  center - @orientation
%  fibre  - @fibre
%  radius - double
%
% Options
%  resolution - resolution of discretization
%
% See also
% SO3Fun/fibreVolume SO3Fun/entropy SO3Fun/textureindex

if isa(center,'fibre')
  v = fibreVolume(odf,center.h,center.r,radius,varargin{:});
  return
end

v = zeros(size(center));

% cycle through components
for ic = 1:length(center)

  S3G = [];
  
  for i = 1:length(odf.components)
  
    [iv,S3G] = volume(odf.components{i},center(ic),radius,S3G,varargin{:});
    v(ic) = v(ic) + iv;
    
  end
  
end

end
