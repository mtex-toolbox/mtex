function v = fibreVolume(odf,h,r,radius,varargin)
% ratio of orientations with a certain orientation
%
% Description 
% returns the ratio of mass of the odf that is within a certain
% distance from a given fibre
%
% Syntax
%   v = fibreVolume(odf,h,r,radius)
%
% Input
%  odf    - @ODF
%  h      - @Miller
%  r      - @vector3d
%  radius - double
%
% Options
%  resolution - resolution of discretization
%
% See also
% ODF/volume ODF/entropy ODF/textureindex

% check input
argin_check(h,{'Miller','vector3d'});
if isa(h,'Miller'), h = odf.CS.ensureCS(h);end
argin_check(r,'vector3d');
argin_check(radius,'double');

% get resolution
res = get_option(varargin,'RESOLUTION',min(2.5*degree,radius/50),'double');

% discretisation
sR = odf.CS.fundamentalSector;  
S2G = equispacedS2Grid(sR,'resolution',res,varargin{:});
lS2G = length(S2G);
S2G = S2G(angle(h,Miller(S2G,odf.CS))<radius);

% estimate volume portion of odf space
f = length(S2G)/lS2G;

% eval odf
if f==0
  v = 0;
else
  v = min(1,mean(odf.calcPDF(S2G,r)) * f);
end

