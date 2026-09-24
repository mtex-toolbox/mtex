function [sFs,psi] = symmetrise(sF, varargin)
% symmetrises a function with respect to a symmetry or a direction
%
% Syntax
%
%   % symmetrise with respect to a crystal or specimen symmetry
%   sFs = symmetrise(sF,cs)
%   sFs = symmetrise(sF,ss)
%
%   % symmetrise with respect to an axis
%   [sFs,psi] = symmetrise(sF,d)
%
% Input
%  sF    - @S2FunHarmonic
%  cs,ss - @crystalSymmetry, @specimenSymmetry
%  d     - @vector3d
%
% Output
%  sFs - @S2FunHarmonic
%  psi - @S2Kernel

if (nargin==1 || ~isa(varargin{1},'vector3d')) && isempty(getClass(varargin,'symmetry'))
  sym = getSym(sF);
  if isempty(sym), sym = specimenSymmetry.default; end
  sFs = sF.symmetrise(sym);
  return
end

% symmetrise with respect to an axis
if isa(varargin{1},'vector3d')

  center = vector3d(varargin{1});

  if isa(sF,'S2FunHarmonicSym') && center ~= zvector
    sF = S2FunHarmonic(sF);
  end

  % start with a zero function
  sFs = sF; sFs.fhat = 0;
  
  % rotate sF such that varargin{1} -> z
  if center ~= zvector
    rot = rotation.byAxisAngle(cross(center,zvector),angle(center,zvector));
    sF = rotate(sF,rot);
  end
  
  % set all Fourier coefficients f_hat(l,k)=0 for k ~= 0
  M = sF.bandwidth;
  sFs.bandwidth = M;
  sFs.fhat((0:M).^2+(1:M+1)) = sF.fhat((0:M).^2+(1:M+1));
  %psi = S2Kernel(real(sF.fhat((0:M).^2+(1:M+1))));
  m = 0:M;
  psi = S2Kernel(sqrt((2*m.'+1)).*real(sF.fhat((0:M).^2+(1:M+1)))./sqrt(4*pi));
  
  % rotate sF back
  if center ~= zvector
    sFRot = rotate(sFs,inv(rot));
    sFs.fhat = sFRot.fhat;
  end
    
  return;
end


% extract symmetry
sym = getClass(varargin,'symmetry');

% maybe there is nothing to do
if sF.bandwidth == 0 || numSym(sym) == 1
  sFs = S2FunHarmonicSym(sF.fhat, sym,'skipSymmetrise');
  return;
end

% The mean of f(g v) over the group is, degree by degree, the projection
% P_l of the rotations R_g applied to the coefficients. An improper element
% acts as v -> -R_g v and contributes (-1)^l, so in odd degrees the proper
% elements H count once and all rotation parts K once negatively:
%   P_l = P_l(K) for even l,  P_l = 2|H|/|G| P_l(H) - P_l(K) for odd l
R = rotation(sym.rot);
isImproper = R.i(:);
R.i = false(size(R));
L = sF.bandwidth;
K = degreeBlocks(sym.WignerD('bandwidth',L,'rotations',R(:)),L);
if any(isImproper)
  H = degreeBlocks(sym.WignerD('bandwidth',L,'rotations',R(~isImproper)),L);
end

sFs = sF;
for l = 0:L
  P = K{l+1};
  if any(isImproper) && mod(l,2), P = 2*mean(~isImproper) * H{l+1} - P; end
  sFs.fhat(l^2+1:(l+1)^2,:) = (P./sqrt(2*l+1)) * sF.fhat(l^2+1:(l+1)^2,:);
end

end
