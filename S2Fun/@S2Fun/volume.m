function v = volume(sF,center,radius,varargin)
% Integrates an S2Fun on the region of all vector3d's that are close to a 
% specified vector3d (center) by a tolerance (radius), i.e.
%
% $$ \int_{\angle(g,c)<r} f(g) \, dg.$$
%
% Description
% The function 'volume' returns the ratio of the volume of an S2Fun on the 
% region (of all vector3d's that are close to a specified vector3d (center) 
% by a tolerance (radius)) to the volume of the entire spherical function.
%
% Note that if the S2Fun $f$ is 'antipodal' the volume in any center with
% radius 90° will return the mean value of the S2Fun, which is infact the 
% volume of the whole sphere.
%
% Syntax
%   v = volume(sF,center,radius)
%
% Input
%  sF    - @S2Fun
%  center - @vector3d
%  radius - double
%
% Options
%  resolution - resolution of discretization
%
% See also
% S2FunHarmonic/volume S2Fun/sum S2Fun/mean

% get resolution
res = get_option(varargin,'resolution',min(0.1*degree,radius/200),'double');

% discretization
ind=[];
if nargin > 3 && isa(varargin{1},'vector3d')
  
  S2G = varargin{1};

elseif isa(sF,'S2FunHarmonicSym')
  
  % get fundamental sector
  cs = sF.s;
  a=[];
  if sF.antipodal
    a = 'antipodal';
  end
  sR = fundamentalSector(cs,a);
  
  % get S2Grid
  S2G = equispacedS2Grid('center',center,'maxTheta',pi,'resolution',res,sR,varargin{:});
  ind = min(angle(S2G(:).',center.symmetrise(cs,a)),[],1)<=radius;
  S2G = S2G(ind);

else

  S2G = equispacedS2Grid('center',center,'maxTheta',radius,'resolution',res,varargin{:});

end


% estimate volume portion of spherical function space
if ~isempty(ind)
  f = length(S2G)/length(ind(:));
else
  f = min(1,(1-cos(radius))/2 * (1+sF.antipodal));
end

% eval sF
if f == 0
  v = 0;
else
  v = mean(eval(sF,S2G)) * f;
end

end