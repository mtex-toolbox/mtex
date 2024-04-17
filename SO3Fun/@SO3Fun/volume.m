function v = volume(SO3F,center,radius,varargin)
% Integrates an SO3Fun on the region of all orientations that are close to  
% a specified orientation (center) by a tolerance (radius), i.e.
%
% $$ \int_{\angle(R,c)<r} f(R) \, dR.$$
%
% Description
% The function 'volume' returns the ratio of the volume of an SO3Fun on the 
% region (of all orientations that are close to a specified orientation 
% (center) by a tolerance (radius)) to the volume of the entire rotational 
% function.
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
% SO3FunHarmonic/volume SO3Fun/fibreVolume SO3Fun/entropy SO3Fun/textureindex

% TODO: direct computation for SO3FunHarmonic
% TODO: antipodal is not considered up to now

% if SO3F.antipodal
%   error(['The antipodal property is not considered up to now by the volume' ...
%     ' computation of an SO3Fun.'])
% end

if isa(center,'fibre')
  
  v = fibreVolume(SO3F,center.h,center.r,radius,varargin{:});  
  
else
  
  % get resolution
  res = get_option(varargin,'resolution',min(1.25*degree,radius/30),'double');

  % discretisation
  if nargin > 3 && isa(varargin{1},'orientation')
    S3G = varargin{1};
  else
    % there is no antipodal option
    S3G = equispacedSO3Grid(SO3F.CS,SO3F.SS,...
      'maxAngle',radius,'center',center,'resolution',res,varargin{:});
  end

  % full grid size without symmetries: 
  ntheta = fix(round(2*pi/res+1)/2);
  theta =  (0.5:ntheta-0.5)*res;
  points = sum(max(round(sin(theta)*2*ntheta),1)) * round(2*pi/res);
  % estimate volume portion of odf space
  f = min( 1 , length(S3G) / points * numProper(SO3F.CS) * numProper(SO3F.SS) );
  
  % eval odf
  if f == 0
    v = 0;
  else
    v = mean(eval(SO3F,S3G)) * f;   
  end 
end

end
