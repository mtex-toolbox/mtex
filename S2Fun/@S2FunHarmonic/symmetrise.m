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

if (nargin==1 || ~isa(varargin{1},'vector3d')) && isempty(getClass(varargin,'referenceFrame'))
  sym = getSym(sF);
  if isempty(sym), sym = specimenFrame.default; end
  sFs = sF.symmetrise(sym);
  return
end

% symmetrise with respect to an axis
if isa(varargin{1},'vector3d')

  center = vector3d(varargin{1});

  % about any axis but z nothing of the group survives, so the frame the
  % result is written in must not claim one
  if hasSymmetry(sF) && center ~= zvector
    sF = S2FunHarmonic(sF);
    sF.framePrivate = stripSym(sF.frame);
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
sym = getClass(varargin,'referenceFrame');

% maybe we can set antipodal and save some time
if sym.isLaue
  symX = sym.properSubGroup;
  varargin = [varargin,'antipodal'];
else
  symX = sym;
end

% maybe there is nothing to do
if sF.bandwidth == 0 || numSym(symX) == 1
  sFs = S2FunHarmonicSym(sF.fhat, sym,'skipSymmetrise');
  return;
end

% define a symmetrised evaluation function
f = @(v) sF.eval(v);
fsym = @(v) mean(reshape(f(symX * v),numSym(symX),[]));

% compute Fourier coefficients by quadrature - naming the group here would
% send the quadrature back into this function, which is doing the work
[~,args] = getClass(varargin,'referenceFrame');
sFsym = S2FunHarmonic.quadrature(fsym, 'bandwidth', sF.bandwidth,args{:});

sFs = sF;
sFs.fhat = sFsym.fhat;
sFs.framePrivate = sym;


end
