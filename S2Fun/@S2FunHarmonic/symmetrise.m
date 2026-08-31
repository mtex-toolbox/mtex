function [sF, psi] = symmetrise(sF, sym)
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
%  cs,ss - @crystalFrame, @specimenFrame
%  d     - @vector3d
%
% Output
%  sFs - @S2FunHarmonic
%  psi - @S2Kernel

% the frame the function is written in already names the group
if nargin==1, sym = sF.frame; end

% symmetrise with respect to an axis
if isa(sym,'vector3d')
  
  % rotate sF such that the axis points to z
  if ~eq(sym,zvector,'antipodal')
    rot = rotation.byAxisAngle(cross(sym,zvector),angle(sym,zvector));
    sF = rotate(sF,rot);
  end
  
  % set all Fourier coefficients f_hat(l,k)=0 for k ~= 0
  M = sF.bandwidth;

  fhatTrace = sF.fhat((0:M).^2+(1:M+1),:,:);
  sF.fhat = zeros(size(sF.fhat));
  sF.fhat((0:M).^2+(1:M+1),:,:) = fhatTrace;
    
  psi = S2Kernel(sqrt((2*(0:M).'+1)).*real(fhatTrace)./sqrt(4*pi));
  
  % rotate sF back
  if ~eq(sym,zvector,'antipodal'), sF = rotate(sF,inv(rot)); end

  % strip symmetry
  if hasSymmetry(sF) && sym ~= zvector
    sF.framePrivate = stripSym(sF.framePrivate);
  end
    
  return;
end

% the function is stated in the given frame
if isa(sym,'referenceFrame'), sF.framePrivate = sym; end

% maybe there is nothing to do
if isempty(sym) || sF.bandwidth == 0 || numSym(sym) == 1, return; end

% the symmetrised function as handle
if sym.isLaue % maybe we can set antipodal and save some time
  fsym = S2FunHandle(@sF.eval,sym.properSubGroup,'antipodal','symmetrise');
else
  fsym = S2FunHandle(@sF.eval,sym,'symmetrise');
end

% turn back into a harmonic function, written in the frame it is symmetric in
sF = S2FunHarmonic.quadrature(fsym,'bandwidth',sF.bandwidth,sym);

end
