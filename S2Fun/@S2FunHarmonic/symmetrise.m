function [sFs,psi] = symmetrise(sF, varargin)
% symmetrises a function with respect to a symmetry or a direction
%
% Syntax
%
%   % symmetrise with respect to a crystal or specimen symmetry
%   sFs = symmetrise(sF,cs)
%   sFs = symmetrise(sF,ss)
%   [sFs,psi] = symmetrise(sF,d)
%
%   % symmetrise with respect to an axis
%   sFs = symmetrise(sF,d)
%
% Input
%  sF    - @S2FunHarmonic
%  cs,ss - @crystalSymmetry, @specimenSymmetry
%  d     - @vector3d
%
% Output
%  sFs - symmetrised @S2FunHarmonic
%  psi - @S2Kernel

% symmetrise with respect to an axis
if isa(varargin{1},'vector3d')

  center = vector3d(varargin{1});
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
  %psi = kernel(real(sF.fhat((0:M).^2+(1:M+1))));
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

% maybe we can set antipodal and save some time
if sym.isLaue
  symX = sym.properSubGroup;
  varargin = [varargin,'antipodal'];
else
  symX = sym;
end

% maybe there is nothing to do
if sF.bandwidth == 0 || numSym(symX) == 1
  sFs = S2FunHarmonicSym(sF.fhat, sym);
  return;
end

% define a symmetrized evaluation function
f = @(v) sF.eval(v);
fsym = @(v) mean(reshape(f(symX * v),numSym(symX),[]));

% compute Fourier coefficients by quadrature
sF = S2FunHarmonic.quadrature(fsym, 'bandwidth', sF.bandwidth,varargin{:});

% set up S2FunHarmonicSym
sFs = S2FunHarmonicSym(sF.fhat,sym);

end
