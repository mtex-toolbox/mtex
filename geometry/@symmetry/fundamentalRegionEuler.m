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

if check_option(varargin,{'ABG','Matthies','ZYZ','nfft'})

  % correct if left symmetry is '211'
  if ss.properGroup.id == 3
    if ismember(cs.properGroup.id,[12,28,36])
      maxPhi = maxPhi*2;
      maxPhi2 = maxPhi2/2;
    elseif ismember(cs.properGroup.id,[3,6,19,22])
      maxPhi1 = 2*pi;
      maxPhi2 = pi/(2*cs.multiplicityZ);
      maxPhi = pi;
    end
  end
  % correct if left symmetry is '312' or  '321'
  if (ss.properGroup.id == 22 && isa(ss,'crystalSymmetry')) || (ss.properGroup.id == 19 && isa(ss,'specimenSymmetry'))
    if ismember(cs.properGroup.id,[12,28,36,41,43])
      maxPhi = maxPhi*2;
      maxPhi2 = maxPhi2/2;
    elseif ismember(cs.properGroup.id,[3,6,19,22])
      maxPhi1 = 2*pi;
      maxPhi2 = pi/(2*cs.multiplicityZ);
      maxPhi = pi;
    end
  end

else  

  % correct if left symmetry is '121'
  if ss.properGroup.id == 6
    if ismember(cs.properGroup.id,[3,12,22,28,36])
      maxPhi = maxPhi*2;
      maxPhi2 = maxPhi2/2;
    elseif ismember(cs.properGroup.id,[6,19])
      maxPhi1 = 2*pi;
      maxPhi2 = pi/(2*cs.multiplicityZ);
      maxPhi = pi;
    end
  end
  % correct if left symmetry is '321'
  if ss.properGroup.id == 19 && isa(ss,'crystalSymmetry')
    if ismember(cs.properGroup.id,[3,12,22,28,36,41,43])
      maxPhi = maxPhi*2;
      maxPhi2 = maxPhi2/2;
    elseif ismember(cs.properGroup.id,[6,19])
      maxPhi1 = 2*pi;
      maxPhi2 = pi/(2*cs.multiplicityZ);
      maxPhi = pi;
    end
  end

end

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
