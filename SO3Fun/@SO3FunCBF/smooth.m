function CBF = smooth(CBF,psi)
% smooth SO3FunCBF
%
% Input
%  CBF - @SO3FunCBF
%  res - resolution
%
% Output
%  component - smoothed @SO3FunCBF
%

CBF.psi = conv(CBF.psi , psi);

