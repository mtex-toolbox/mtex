function L = uniaxial(d,r)
% defines uniaxial tension/compression tensors
%
% Syntax
%
%   % uniaxial tension
%   L = velocityGradientTensor.uniaxial(d,r)
%
%   % uniaxial compression
%   L = velocityGradientTensor.uniaxial(d,-r)
%
% Input
%  d - tension direction @vector3d
%  r - strain rate
%
% Output
%  L - @velocityGradientTensor
%

if nargin == 0, d = vector3d.Z; end
if nargin <= 1, r = 1; end

rot = rotation.map(d,xvector);

L = r .* (inv(rot) * velocityGradientTensor(diag([1,-0.5,-0.5]))); %#ok<MINV>

end