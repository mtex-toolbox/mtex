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

% Note that specimenSymmetry('23') does not exist and consequently does not work

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
    if ismember(cs.properGroup.id,[12,28,36,41,43])
      maxPhi = pi;
      maxPhi2 = maxPhi2/2;
    elseif ismember(cs.properGroup.id,[3,6,19,22])
      maxPhi1 = 2*pi;
      maxPhi2 = pi/cs.multiplicityZ/2;
      maxPhi = pi;
    end
  end
  % correct if left symmetry is '312' or  '321'
  if (ss.properGroup.id == 22 && isa(ss,'crystalSymmetry')) || (ss.properGroup.id == 19 && isa(ss,'specimenSymmetry'))
    if ismember(cs.properGroup.id,[12,28,36,41,43])
      maxPhi = pi;
      maxPhi2 = maxPhi2/2;
    elseif ismember(cs.properGroup.id,[3,6,19,22])
      maxPhi1 = 2*pi/ss.multiplicityZ;
      maxPhi2 = pi/(2*cs.multiplicityZ);
      maxPhi = pi;
    end
  end

else

  % correct if left symmetry is '121'
  if ss.properGroup.id == 6
    if ismember(cs.properGroup.id,[3,12,22,28,36,41,43])
      maxPhi = pi;
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
      maxPhi = pi;
      maxPhi2 = maxPhi2/2;
    elseif ismember(cs.properGroup.id,[6,19])
      maxPhi1 = 2*pi/ss.multiplicityZ;
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

end

function TEST

S = {'1','211','121','112','222','3','321','312','4','422','6','622','23','432'};

NB = NaN(14,14,4);
NM = NaN(14,14,4);
for s=1:4
for i=1:14
  for j=1:14

    switch s
      case 1
        CS = crystalSymmetry(S{i});
        SS = crystalSymmetry(S{j});
      case 2
        CS = crystalSymmetry(S{i});
        SS = specimenSymmetry(S{j});
      case 3
        CS = specimenSymmetry(S{i});
        SS = crystalSymmetry(S{j});
      case 4
        CS = specimenSymmetry(S{i});
        SS = specimenSymmetry(S{j});
    end

    if (CS.id==22 && isa(CS,'specimenSymmetry')) || (SS.id == 22 && isa(SS,'specimenSymmetry'))
      continue;
    end

    rng(0);
    ori = orientation.rand(1000,CS,SS);

    % Test fundamentalRegionEuler - Bunge
    [phi1,Phi,phi2] = Euler(ori.symmetrise,'Bunge');
    [p1,P,p2] = fundamentalRegionEuler(CS,SS);
    E = (phi1<p1 & Phi<P & phi2<p2);
    NB(i,j,s) = all(any(E));

    % Test fundamentalRegionEuler - Matthies
    [alpha,beta,gamma] = Euler(ori.symmetrise,'Matthies');
    [a,b,g] = fundamentalRegionEuler(CS,SS,'Matthies');
    E = (alpha<a & beta<b & gamma<g);
    NM(i,j,s) = all(any(E));

    A = CS.multiplicityZ*SS.multiplicityZ*(1+double(CS.multiplicityPerpZ>1))*(1+double(SS.multiplicityPerpZ>1));
    if ((4*pi^3/(p1*P*p2) - A)>1e-3) || (abs(4*pi^3/(a*b*g) - A) >1e-3)
        error('The fundamental Region is to small.')
    end

    w = waitbar((j+(i-1)*14+(s-1)*14*14)/(14*14*4));

  end
end
end
close(w);

NB
NM

end
