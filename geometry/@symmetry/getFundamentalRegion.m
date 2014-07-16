function  [maxPhi1,maxPhi,maxPhi2] = getFundamentalRegion(cs,ss,varargin)
% get the fundamental region in Euler angles
%
% Syntax
%   [maxPhi1,maxPhi,maxPhi2] = getFundamentalRegion(cs,ss)
%
% Input
%  cs - crystal @symmetry
%  ss - specimen @symmetry
%
% Ouput
%  maxPhi1 - maximum Euler angle phi_1
%  maxPhi  - maximum Euler angle Phi
%  maxPhi2 - maximum Euler angle phi_2
%
% See also
% symmetry/getFundamentalRegionRodriguez symmetry/FundamentalSector

% phi1
maxPhi1 = 2*pi/ss.multiplicityZ;
if cs.multiplicityPerpZ >= 2 && ss.multiplicityPerpZ >= 2 
  maxPhi1 = max(pi/2,maxPhi1/2);
end

%phi2
maxPhi2 = 2*pi/cs.multiplicityZ;

% Phi
maxPhi = pi / min(2,max(cs.multiplicityPerpZ, ss.multiplicityPerpZ));

if check_option(varargin,'complete')
  maxPhi1 = 2*pi;
  maxPhi = pi;
  maxPhi2 = 2*pi;
end

if check_option(varargin,'SO3Grid') && strcmp(cs.LaueName,'m-3m')  
  maxPhi = pi/3;
end
