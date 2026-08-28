function sF = S2FunHarmonicSym(fhat, s, varargin)
% a spherical function that is symmetric under a point group
%
% A symmetric spherical function is an <S2FunHarmonic.S2FunHarmonic.html
% S2FunHarmonic> written in a frame that carries a group: the frame says
% which symmetry the function has, exactly as it does for a direction. Use
% it to give an existing function such a frame, or to symmetrise
% coefficients that are not symmetric yet.
%
% Syntax
%   sF = S2FunHarmonicSym(fhat,s)
%   sF = S2FunHarmonicSym(fun,s)
%
% Input
%  fhat - harmonic coefficients, ordered by degree
%  fun  - @S2Fun or @S2Kernel to be written in the frame of s
%  s    - @crystalFrame or @specimenFrame carrying the group
%
% Output
%  sF - @S2FunHarmonic in the frame of s
%
% Options
%  skipSymmetrise - take the coefficients as already symmetric
%
% Example
%
%   sF = S2FunHarmonic.quadrature(@(v) dot(v,vector3d.Z).^2);
%   sF = S2FunHarmonicSym(sF,crystalSymmetry('432'))
%
% See also
% S2FunHarmonic S2Fun hasSymmetry S2FunHarmonic/symmetrise

if nargin == 0, sF = S2FunHarmonic; return; end

% a function keeps its coefficients and is restated in the frame of s
if isa(fhat,'S2FunHarmonic')

  sF = S2FunHarmonic(fhat.fhat, s);
  return

elseif isa(fhat,'S2Fun')

  sF = S2FunHarmonicSym(S2FunHarmonic.quadrature(fhat), s);
  return

elseif isa(fhat,'S2Kernel')

  psi = fhat;
  bw = psi.bandwidth;
  fhat = zeros((bw+1)^2,1);
  for l = 0:bw
    fhat(l^2+1+l) = 2*sqrt(pi)./sqrt(2*l+1)*psi.A(l+1);
  end
  sF = S2FunHarmonicSym(fhat,s);
  return

end

% bare coefficients are symmetrised, since nothing says they are symmetric
sF = S2FunHarmonic(fhat, s);
if ~check_option(varargin,'skipSymmetrise'), sF = sF.symmetrise; end

end
