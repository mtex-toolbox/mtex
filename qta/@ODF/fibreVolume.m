function v = fibreVolume(odf,h,r,radius,varargin)
% ratio of orientations with a certain orientation
%
% Description
% returns the ratio of mass of the odf that within a certain
% distance from a given fibre
%
% Syntax
%   v = fibreVolume(odf,h,r,radius,<options>)
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
if isa(h,'Miller'), h = ensureCS(odf(1).CS,{h});end
argin_check(r,'vector3d');
argin_check(radius,'double');

if ~strcmp(Laue(odf(1).SS),'-1')
  error('Only triclinic specimen symmetry is supported for fibreVolume');
end

% get resolution
res = get_option(varargin,'RESOLUTION',min(2.5*degree,radius/50),'double');

% discretisation
[minTheta,maxTheta,minRho,maxRho] = getFundamentalRegionPF(odf(1).CS);  
S2G = equispacedS2Grid('resolution',res,...
  'minTheta',minTheta,'maxTheta',maxTheta,'maxRho',maxRho,'minRho',minRho,...
  'restrict2MinMax',varargin{:});
lS2G = length(S2G);
S2G = subGrid(S2G,symmetrise(h),radius);

% estimate volume portion of odf space
%if radius < rotangle_max_z(odf(1).CS) / 8
%  % theoretical value
%  f = length(odf(1).CS) * (1-cos(radius))./2;
%else
  % numerical value
  f = length(S2G)/lS2G;
%end  f = numel(S2G)/lS2G;

% eval odf
if f==0
  v = 0;
else
  v = min(1,mean(pdf(odf,S2G,r)) * f);
end

