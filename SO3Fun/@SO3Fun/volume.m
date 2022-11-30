function v = volume(SO3F,center,radius,varargin)
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
  
  v = fibreVolume(SO3F,center.h,center.r,radius,varargin{:});  
  
else
  
  % get resolution
  res = get_option(varargin,'RESOLUTION',min(1.25*degree,radius/30),'double');

  % discretisation
  if nargin > 3 && isa(varargin{1},'orientation')
    S3G = varargin{1};
  else
    S3G = equispacedSO3Grid(SO3F.CS,SO3F.SS,...
      'maxAngle',radius,'center',center,'resolution',res,varargin{:});
  end

  % estimate volume portion of odf space
  reference = 9897129 * 96 / numProper(SO3F.CS) / numProper(SO3F.SS);
  f = min(1,length(S3G) * (res / 0.25 / degree)^3 / reference);
  
  % eval odf
  if f == 0
    v = 0;
  else
    v = mean(eval(SO3F,S3G)) * f;   
  end 
end

end
