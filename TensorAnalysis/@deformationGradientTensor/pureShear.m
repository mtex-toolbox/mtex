function F = pureShear(exp,compr,lambda)
% deformationGradientTensor representing pure shear
%
% Syntax
%
%   F = velocityGradientTensor.pureShear(exp,compr,lambda)
%
% Input
%  exp    - @vector3d expansion direction
%  compr  - @vector3d compression direction
%  lambda - stretch ratio
%
% Output
%  F - @deformationGradientTensor
%

if nargin < 2, lambda = 2; end


rot = orientation.map(xvector,exp,zvector,compr);

F = deformationGradientTensor(diag([lambda,1,1./lambda]));

F = rotate(F,inv(rot));

end