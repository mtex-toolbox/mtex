function psi = symmetrise(psi, varargin)
% symmetries a kernel function with respect to given symmetries
%
% Syntax
%   psi = symmetrise(psi,cs)
%   psi = symmetrise(psi,'antipodal')
%
% Input
%  psi - @S2Kernel
%  cs  - @crystalSymmetry, @specimenSymmetry
%
% Output
%  psi - @S2Kernel
%


if check_option(varargin,'antipodal')
  psi.A(2:2:end) = 0;
end

cs = getClass(varargin,'symmetry');

if isempty(cs)
  return
end


sF = S2FunHarmonic(psi);
psi = sF.symmetrise(cs);

end