function L = uniaxial(d,q)
% defines uniaxial tension/compression tensors
%
% Syntax
%
%   % axi symmetric uniaxial tension
%   L = r .* velocityGradientTensor.uniaxial(d,q)
%
%   % uniaxial compression
%   L = -velocityGradientTensor.uniaxial(d,q)
%
% Input
%  d - tension direction @vector3d
%  q - [0 .. 1] non axial symmetric portion (0.5 is symmetric and default)
%  r - strain rate
%
% Output
%  L - @velocityGradientTensor
%

if nargin == 0, d = vector3d.Z; end
if nargin <= 1, q = 0.5; end

rot = rotation.map(d,xvector);

M = zeros([3,3,size(q)]);
M(1,1,:,:) = 1;
M(2,2,:,:) = -q;
M(3,3,:,:) = q-1;

L = inv(rot) .* velocityGradientTensor(M);

end