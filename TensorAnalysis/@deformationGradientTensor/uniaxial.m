function F = uniaxial(d,rate)
% deformationGradientTensor representing uniaxial compression / tension
%
% Syntax
%
%   F = velocityGradientTensor.uniaxial(d,rate)
%
% Input
%  d - @vector3d expansion direction
%  rate - deformation rate
%
% Output
%  F - @deformationGradientTensor
%

if nargin < 2, rate = 2; end

rot = orientation.map(xvector,d);

F = deformationGradientTensor(diag([rate,1./sqrt(rate),1./sqrt(rate)]));

F = rotate(F,inv(rot));

end



