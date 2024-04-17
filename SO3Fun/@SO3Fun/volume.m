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

% TODO: direct computation for SO3FunHarmonic

if isa(center,'fibre')
  
  v = fibreVolume(SO3F,center.h,center.r,radius,varargin{:});  
  
else
  
  % get resolution
  res = get_option(varargin,'resolution',min(1.25*degree,radius/30),'double');

  % discretisation
  if nargin > 3 && isa(varargin{1},'orientation')
    S3G = varargin{1};
  else
    S3G = equispacedSO3Grid(SO3F.CS,SO3F.SS,...
      'maxAngle',radius,'center',center,'resolution',res,varargin{:});
  end

  % full grid size without symmetries: 
  ntheta = fix(round(2*pi/res+1)/2);
  theta =  (0.5:ntheta-0.5)*res;
  points = sum(max(round(sin(theta)*2*ntheta),1)) * round(2*pi/res);
  % estimate volume portion of odf space
  f = min( 1 , length(S3G) / points ) / numProper(SO3F.CS) / numProper(SO3F.SS);
  
  % eval odf
  if f == 0
    v = 0;
  else
    v = mean(eval(SO3F,S3G)) * f;   
  end 
end

end
