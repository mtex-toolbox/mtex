function  [maxPhi1,maxPhi,maxPhi2] = fundamentalRegionEuler(cs,ss,varargin)
% get the fundamental region in Euler angles
%
% Syntax
%
%   [maxPhi1,maxPhi,maxPhi2] = fundamentalRegionEuler(cs)
%   [maxPhi1,maxPhi,maxPhi2] = fundamentalRegionEuler(cs,ss)
%
% Input
%  cs - @crystalSymmetry
%  ss - @specimenSymmetry
%
% Output
%  maxPhi1 - maximum Euler angle phi_1
%  maxPhi  - maximum Euler angle Phi
%  maxPhi2 - maximum Euler angle phi_2
%
% See also
% symmetry/FundamentalRegion symmetry/FundamentalSector


if nargin == 1, ss = specimenSymmetry; end

% phi1
maxPhi1 = 2*pi/ss.multiplicityZ;
if cs.multiplicityPerpZ >= 2 && ss.multiplicityPerpZ >= 2 
  %maxPhi1 = max(pi/2,maxPhi1/2);
  maxPhi1 = maxPhi1/2;
end

%phi2
maxPhi2 = 2*pi/cs.multiplicityZ;

% Phi
maxPhi = pi / min(2,max(cs.multiplicityPerpZ, ss.multiplicityPerpZ));

% for antipodal symmetry we can reduce either phi1 or phi2 to one half
if check_option(varargin,'antipodal'), maxPhi2 = maxPhi2 / 2; end


if check_option(varargin,'complete')
  maxPhi1 = 2*pi;
  maxPhi = pi;
  maxPhi2 = 2*pi;
end

if check_option(varargin,'SO3Grid') && cs.Laue.id == 45
  maxPhi = pi/3;
end
