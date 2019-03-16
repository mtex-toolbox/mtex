function L = pureShear(exp,comp,e)
% defines velocityGradientTensor representing pure shear
%
% Syntax
%   L = velocityGradientTensor.uniaxialCompression(exp,comp)
%
% Input
%  exp  - @vector3d expansion direction
%  comp - @vector3d compression direction
%  e - strain rate
%
% Output
%  L - @velocityGradientTensor
%

if nargin == 2, e = 1; end

v1 = normalize(exp - comp);
v2 = normalize(exp + comp);

L = 2*velocityGradientTensor(e .* (dyad(v1,v2) + dyad(v1,v2)'));

end