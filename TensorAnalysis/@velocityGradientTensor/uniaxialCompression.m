function L = uniaxialCompression(d,e)
% defines uniaxial compression tensors
%
% Syntax
%   L = velocityGradientTensor.uniaxialCompression(d,r)
%
% Input
%  d - compression direction @vector3d
%  e - strain rate
%
% Output
%  L - @velocityGradientTensor
%

if nargin == 0, d = vector3d.Z; end
if nargin <= 1, e = 1; end

rot = rotation.map(d,xvector);

L = e .* (inv(rot) * velocityGradientTensor(diag([-1,0.5,0.5]))); %#ok<MINV>

end