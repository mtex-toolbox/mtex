function L = simpleShear(d,n,e)
% defines velocity gradient tensors representing simple shear
%
% Syntax
%   L = velocityGradientTensor.simpleShear(d,n)
%
% Input
%  d - @vector3d shear direction
%  n - @vector3d normal direction ???
%  e - strain rate
%
% Output
%  L - @velocityGradientTensor
%

if nargin == 2, e = 1; end

L = 2*velocityGradientTensor(e .* dyad(d.normalize,n.normalize));

end
    